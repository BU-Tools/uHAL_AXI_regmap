
#################################################################################                                                                                                             
## Force python3                                                                                                                                                                              
#################################################################################                                                                                                             
import sys                                                                                                                                                                                    
if not sys.version_info.major == 3:                                                                                                                                                           
    raise BaseException("Wrong Python version detected.  Please ensure that you are using Python 3.")                                                                                         
#################################################################################              

#from __future__ import print_function
from lxml import etree
import os

from os.path import exists


class ParserTree:
    def __init__(self, root=None):
        self.addressMap = dict()
        self.root = root

    def buildTree(self, parentNode, filepath, currentElement=None, init=True):
        """
        recursive function for building the tree
        two scenarios
        with reference from node, currentElement is None
        without reference, currentElement is last parent element
        """                
        if currentElement is None:
            if not exists(filepath):
                raise BaseException("File "+filepath+" not found")
            f = open(filepath, "rb")
            parser = etree.XMLParser(remove_comments=True)
            tree = etree.parse(f, parser=parser)
            root = tree.getroot()
            f.close()
        else:
            root = currentElement
        
        if init:
            parentNode.setName(root.attrib.get("id"))

        #start keeping track of the maximum address seen for this node
        max_end_address = parentNode.getAddress() + parentNode.getSize()
        
        queue = []
        for child in root:
            queue.append(child)

        while (len(queue) > 0):
            current = queue.pop(0)
            currAttr = current.attrib
            
            # create childNode from
            childNode = ParserNode(name=currAttr.get("id"), parentNode=parentNode, address=currAttr.get("address"),
                                   mask=currAttr.get("mask"), description=currAttr.get("description"), permission=currAttr.get("permission"),size=currAttr.get("size"), path=filepath)
            childNode.setParameters(currAttr.get("parameters"))
            childNode.setFwinfo(currAttr.get("fwinfo"))
            childNode.setAttrib(currAttr)
            # add childNode to parent
            parentNode.addChild(childNode)

            # addressMap = {address1: {mask1: [node1, node2], mask2: [node3]}, address2: {mask1: [node4]}}
            self.addressMap.setdefault(childNode.getAddress(), {})
            self.addressMap[childNode.getAddress()].setdefault(
                childNode.getMask(), [])
            self.addressMap[childNode.getAddress()][childNode.getMask()
                                                    ].append(childNode)

            # update the max address for this raw child
            if childNode.getAddress() + childNode.getSize() > max_end_address:
                max_end_address=childNode.getAddress() + childNode.getSize()
                    

            if "module" in currAttr:                
                modulePath = currAttr["module"].replace("file://", "")
                nextPath = os.path.join(os.path.dirname(
                    filepath), modulePath)
                childNode.setModule(currAttr["module"])
                # generate rest of tree from reference path
                new_end_address = self.buildTree(parentNode=childNode,
                                                 filepath=nextPath, init=False)
                # update the max address seen when parsing this module
                if new_end_address > max_end_address:
                    max_end_address = new_end_address
            else:
                childNode.setModule(None)
                # generate rest of tree from child nodes
                new_end_address =self.buildTree(parentNode=childNode, filepath=filepath,
                                                currentElement=current, init=False)
                # update the max address seen when fully parsing this child
                if new_end_address > max_end_address:
                    max_end_address = new_end_address

        #Compute the total size of this node and store it in span
        parentNode.span = max_end_address - parentNode.getAddress()
        return max_end_address
class ParserNode:
    def __init__(self, name=None, parentNode=None, address=None, mask=None, description=None, permission=None, size=None, path=""):
        self.setParent(parentNode)
        self.__children = []

        self.setName(name)
        self.setAddress(address)
        self.setRelativeAddress(address)
        self.setMask(mask)
        self.setDescription(description)
        self.setPermission(permission)
        self.setSize(size)

        self.__parameters = dict()
        self.__module=None
        self.__fwinfo = dict()
        self.__attrib = dict()

        self.setDepth()
        self.setFilePath(path)

    #--------------- accessors ---------------#

    def getParent(self):
        return self.__parent

    def getChildren(self):
        return self.__children

    def getChild(self, childName):
        for child in self.__children:
            if child.getName() == childName:
                return child
        return None

    def getNodes(self):
        names = []
        for child in self.__children:
            names.append(child.getName())
        return names

    def getNode(self, s):
        return self.getChild(s)

    def getName(self):
        return self.__name

    def getId(self):
        return self.getName()

    def getModule(self):
        return self.__module

    def getDepth(self):
        return self.__depth

    def getSize(self, base=10):
        if base == 16:
            return hex(self.__size)
        else:
            return self.__size

    def getAddress(self, base=10):
        if base == 16:
            return hex(self.__address)
        else:
            return self.__address

    def getRelativeAddress(self, base=10):
        if base == 16:
            return hex(self.__relativeAddress)
        else:
            return self.__relativeAddress

    def getMask(self, base=10):
        if base == 16:
            if self.__mask == 0:
                return "NONE"
            else:
                return hex(self.__mask)
        elif base == 2:
            if self.__mask == 0:
                return "NONE"
            else:
                return bin(self.__mask)
        else:
            return self.__mask

    def getDescription(self):
        return self.__description

    def getPermission(self):
        return self.__permission

    def getParameters(self):
        return self.__parameters

    def getFwinfo(self):
        return self.__fwinfo

    def getFwinfoRaw(self):
        return self.__fwinfoRaw

    def getFirmwareInfo(self):
        return self.getFwinfo()

    def getAttrib(self):
        return self.__attrib

    def getFilePath(self):
        return self.__filePath

    def getPath(self, expandArray=False):
        if self.__parent:
            return self.__parent.getPath(expandArray)+'.'+self.__name
        else:
            return self.__name

    def getBitRange(self, mask=None):
        if not mask:
            mask = self.__mask
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

    #--------------- modifiers ---------------#

    def setParent(self, parentNode):
        if parentNode is None:
            self.__parent = None
        elif isinstance(parentNode, ParserNode):
            self.__parent = parentNode
        else:
            self.__parent = None

    def addChild(self, childNode):
        if isinstance(childNode, ParserNode):
            self.__children.append(childNode)

    def setName(self, name):
        if name is None:
            self.__name = 'NONE'
        else:
            self.__name = name

    def setSize(self, size):
        if size is None:
            size = 1
        self.__size=int(str(size),0)

    def setDepth(self, depth=None):
        if depth is None:
            if self.__parent is None:
                self.__depth = 0
            else:
                self.__depth = self.__parent.getDepth() + 1
        else:
            self.__depth = depth

    def setAddress(self, addr):
        
        if addr is None:
            addr = 0
        if addr == "auto":
            addr = 0
        addr=int(str(addr),0)

        if self.__parent is not None:
            self.__address = self.__parent.getAddress() + addr
        else:
            self.__address = addr

    def setRelativeAddress(self, addr):
        if addr is None:
            addr = 0
        if addr == "auto":
            addr = 0
        self.__relativeAddress = int(str(addr),0)

    def setMask(self, mask):
        if mask is None:
            mask = int("0xFFFFFFFF",0)
        self.__mask = int(str(mask),0)

    def setDescription(self, description):
        if description is None:
            description = ""

        self.__description = description

    def setPermission(self, permission):
        if permission is None:
            permission = ""

        self.__permission = permission

    def setParameters(self, eleStr):
        if eleStr is None:
            self.__parameters = dict()
            return

        cpyStr = eleStr.strip("; ")
        try:
            elements = [i.split("=") for i in cpyStr.split(";")]
            self.__parameters = dict(elements)
        except:
            print("invalid parameter string:", eleStr)

    def setModule(self, elestr):
        self.__module = elestr
    def setFwinfo(self, eleStr):
        self.__fwinfoRaw = eleStr
        if eleStr is None:
            self.__fwinfo = dict()
            return


        cpyStr = eleStr.strip("; ")
        try:
            for i in cpyStr.split(";"):
                self.__fwinfo[i.split("=")[0]] = i
        except:
            print("invalid fwinfo string:", eleStr)
            

    def setFilePath(self, path):
        self.__filePath = path

    def setAttrib(self, attrib):
        if attrib is None:
            self.__fwinfo = dict()
            return

        self.__attrib = attrib

    #--------------- static methods ---------------#

    @staticmethod
    def writeNode(node, path="log.txt"):
        if isinstance(node, ParserNode):
            f = open(path, "w")
            stack = [node]
            while (len(stack) > 0):
                current = stack.pop(0)
                for x in range(current.getDepth()):
                    f.write("|\t")
                f.write('|-->')
                f.write("id: " + current.getName())
                f.write(" address: " + current.getAddress(base=16))
                f.write(" relative address: " +
                        current.getRelativeAddress(base=16))
                f.write(" mask: " +
                        current.getMask(base=16))
                f.write('\n')
                block = []
                for child in current.getChildren():
                    block.append(child)
                stack = block + stack
