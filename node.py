from __future__ import print_function
import getopt
import sys
import copy
import os.path
import time
import logging
import math
# import uhal
from parserNode import ParserNode
try:
    from StringIO import StringIO  # for Python 2
except ImportError:
    from io import StringIO  # for Python 3

EXIT_CODE_INCORRECT_ARGUMENTS = 1
EXIT_CODE_ARG_PARSING_ERROR = 2
EXIT_CODE_NODE_ADDRESS_ERRORS = 3
EXIT_CODE_NODE_INVALID_ARRAY = 4


class node(object):
    def __init__(self, uhalNode, baseAddress, tree=None, parent=None, index=None):
        if isinstance(uhalNode, ParserNode):
            # parser node constructor
            self.parent = parent
            self.tree = tree
            # reference to the tree class through parent
            if self.parent and not self.tree:
                self.tree = self.parent.tree
            self.children = []
            #####
            self.id = uhalNode.getName()
            self.mask = uhalNode.getMask()
            self.description = uhalNode.getDescription()
            self.permission = uhalNode.getPermission()
            self.fwinfo = uhalNode.getFwinfo()
            self.parameters = uhalNode.getParameters()
            absolute_address = uhalNode.getAddress()
            self.address = uhalNode.getRelativeAddress()
            self.array_head = None
        else:
            # uhal node constructor
            self.parent = parent
            self.tree = tree
            # reference to the tree class through parent
            if self.parent and not self.tree:
                self.tree = self.parent.tree
            self.children = []
            #####
            self.id = uhalNode.getId()
            self.mask = uhalNode.getMask()
            self.description = uhalNode.getDescription()
            self.permission = self.readpermission(uhalNode.getPermission())
            self.fwinfo = uhalNode.getFirmwareInfo()
            self.parameters = uhalNode.getParameters()
            absolute_address = uhalNode.getAddress()
            self.address = absolute_address - baseAddress
            self.array_head = None

        # add children
        for childName in uhalNode.getNodes():
            # TODO: are we filtering out registers whose ID contains a '.'?
            if childName.count('.') > 0:
                continue
            childNode = uhalNode.getNode(childName)
            self.addChild(node(childNode, absolute_address, parent=self))
        # validate array type
        for child in self.children:
            if not child.checkContinuity():
                self.tree.log.critical(
                    "Critical: Attempting to register multiple array type registers but the indices are not continuous!")
                sys.exit(EXIT_CODE_NODE_INVALID_ARRAY)
        # sort children by address and mask
        self.children = sorted(
            self.children, key=lambda child: (child.address << 32) + child.mask)

    ### re-implemented in array_node
    def getLocalAddress(self):
        if self.parent:
            return self.address + self.parent.getLocalAddress()
        else:
            return 0

    # usually allow first layer nodes to have different address etc. but require all children to be exactly same
    def isIdentical(self, other, compareAll=False):
        # check attributes for the first level
        if not self.tree == other.tree:
            if self.tree.debug:
                print("Incompatible array: different owner tree")
            return False
        if not self.permission == other.permission:
            if self.tree.debug:
                print("Incompatible array: different permission " +
                      self.permission+" vs "+other.permission)
            return False
        if not self.fwinfo == other.fwinfo:
            if self.tree.debug:
                print("Incompatible array: different fwinfo " +
                      self.fwinfo+" vs "+other.fwinfo)
            return False
        # stricter check for deeper levels
        if compareAll:
            if not self.id == other.id:
                if self.tree.debug:
                    print("Incompatible array: different id " +
                          self.id+" vs "+other.id)
                return False
            if not self.address == other.address:
                if self.tree.debug:
                    print("Incompatible array: different address " +
                          str(self.address)+" vs "+str(other.address))
                return False
            if not self.mask == other.mask:
                if self.tree.debug:
                    print("Incompatible array: different mask " +
                          str(self.mask)+" vs "+str(other.mask))
                return False
            if not self.description == other.description:
                if self.tree.debug:
                    print("Incompatible array: different description " +
                          self.description+" vs "+other.description)
                return False
        # compare children, assuming they are sorted by address and id already!
        if not len(self.children) == len(other.children):
            if self.tree.debug:
                print("Incompatible array: different len children " +
                      str(len(self.children))+" vs "+str(len(other.children)))
            return False
        for i_children in range(len(self.children)):
            if not self.children[i_children].isIdentical(other.children[i_children], compareAll=True):
                return False
        return True

    def addChild(self, child):
        array_index = child.extractIndex()
        if array_index >= 0:  # treat it as an array type
            # check if it should be appended to an existing child
            for other_child in self.children:
                if other_child.isArray() and other_child.checkAppend(child):
                    return
            # otherwise create a new array
            self.children.append(array_node(child))
            return
        self.children.append(child)
        return

    def isArray(self):
        return False

    def getPath(self, includeRoot=True, expandArray=False):
        if self.parent:
            if not includeRoot and not self.parent.parent:
                return self.id
            elif (not expandArray) and self.parent.array_head:
                return self.parent.array_head.getPath(includeRoot, expandArray)+'.'+self.id
            else:
                return self.parent.getPath(includeRoot, expandArray)+'.'+self.id
        else:
            return self.id

    # re-implemented in array_node class
    def checkContinuity(self):
        return True

    # returns the array index if id in the format "name_index" and has "type=array" in fw info, otherwise -1
    # example: <node id="CM_1" fwinfo="type=array">
    def extractIndex(self):
        if not 'type' in self.fwinfo.keys():
            return -1
        if not "array" in self.fwinfo['type']:
            return -1
        index_string = self.id[self.id.rfind('_')+1:]
        try:
            index = int(index_string)
        except ValueError:
            return -1
        return index

    # get child by name, return None if no result found
    def getChild(self, childName):
        for child in self.children:
            if child.id == childName:
                return child
        return None

    @staticmethod
    def readpermission(permission):
        if permission == uhal.NodePermission.READ:
            return 'r'
        elif permission == uhal.NodePermission.READWRITE:
            return 'rw'
        elif permission == uhal.NodePermission.WRITE:
            return 'w'
        else:
            return ""

    def getBitRange(self, mask=None):
        if not mask:
            mask = self.mask
        bits = bin(mask)[2:].zfill(32)[::-1]
        start = -1
        end = -1
        for i in range(len(bits)-1, -1, -1):
            if start == -1:
                if bits[i] == '1':
                    start = i
            elif end == -1:
                if bits[i] == '0':
                    end = i+1
                    break
        if end == -1:
            end = 0
        if start == end:
            return str(start).rjust(2)
        else:
            return str(start).rjust(2, ' ') + " downto "+str(end).rjust(2, ' ')

    # for debugging purposes
    def dump(self, padding=''):
        print(padding+"id="+self.id+" address="+str(self.address) +
              " mask="+str(self.mask)+" permission="+self.permission)
        for child in self.children:
            child.dump(padding+'\t')


class array_node(node):
    # initialized with the first entry
    def __init__(self, first_entry):
        first_index = first_entry.extractIndex()
        assert first_index >= 0
        self.id = first_entry.id[:first_entry.id.rfind('_')]
        first_entry.id = first_entry.id[:first_entry.id.rfind(
            '_')]+'('+str(first_index)+')'
        first_entry.array_head = self
        self.description = "Array of " + self.id
        self.address = first_entry.address
        self.mask = 0xffffffff
        self.fwinfo = first_entry.fwinfo
        self.permission = first_entry.permission
        self.parent = first_entry.parent
        self.tree = first_entry.tree
        self.children = first_entry.children
        self.entries = {first_index: first_entry}

    def isCompatible(self, new_entry):
        if not self.id[:new_entry.id.rfind('_')] == new_entry.id[:new_entry.id.rfind('_')]:
            return False
        new_index = new_entry.extractIndex()
        if (new_index < 0) or (new_index in self.entries.keys()):
            self.tree.log.critical(
                "Critical: Attempting to register multiple array type registers but they are not identical!")
            if not self.tree.debug:
                sys.exit(EXIT_CODE_NODE_INVALID_ARRAY)
            return False
        if not self.isIdentical(new_entry):
            self.tree.log.critical(
                "Critical: Attempting to register multiple array type registers but they are not identical!")
            if not self.tree.debug:
                sys.exit(EXIT_CODE_NODE_INVALID_ARRAY)
            return False
        return True

    # If new entry is compatible, add it to the array and return True, otherwise return False
    def checkAppend(self, new_entry):
        if self.isCompatible(new_entry):
            new_index = new_entry.extractIndex()
            # turn entry's id from XXX_1 into XXX(1)
            new_entry.id = (
                '('+str(new_index)+')').join(new_entry.id.rsplit('_'+str(new_index), 1))
            self.entries[new_index] = new_entry
            self.entries[new_index].array_head = self
            return True
        return False

    def checkContinuity(self):
        keys = list(self.entries.keys())
        return (sorted(keys) == list(range(min(keys), max(keys)+1)))

    # re-implemented from node
    def isArray(self):
        return True

    # for debugging purposes
    def dump(self, padding=''):
        print(padding+"id="+self.id+" address="+str(self.address)+" mask="+str(self.mask) +
              " permission="+self.permission+" array_indices="+str(self.entries.keys()))
        for child in self.children:
            child.dump(padding+'\t')
