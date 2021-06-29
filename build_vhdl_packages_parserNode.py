#!/usr/bin/python
from __future__ import print_function
from lxml import etree
import argparse
import os
import copy
from node import node
from tree import tree

from parserNode import ParserNode


addressMap = dict()


def writeMap(m, path="tempDupError.txt"):
    f = open(path, "w")

    for addr in m.keys():
        for mask in m[addr].keys():
            f.write(hex(addr) + " " + hex(mask) + '\n')
            for item in m[addr][mask]:
                f.write('\t')
                f.write("{: <50} {: <100}\n".format(
                    item.getName(), item.getFilePath()))


def buildTree(parentNode, filepath, currentElement=None, init=False):
    """
    recursive function for building the tree
    two scenarios
    with reference from node, currentElement is None
    without reference, currentElement is last parent element
    """

    if currentElement is None:
        f = open(filepath, "rb")
        parser = etree.XMLParser(remove_comments=True)
        tree = etree.parse(f, parser=parser)
        root = tree.getroot()
        f.close()
    else:
        root = currentElement

    if init:
        parentNode.setName(root.attrib.get("id"))

    queue = []
    for child in root:
        queue.append(child)

    while (len(queue) > 0):
        current = queue.pop(0)
        currAttr = current.attrib

        # create childNode from
        # print(currAttr)
        childNode = ParserNode(name=currAttr.get("id"), parentNode=parentNode, address=currAttr.get("address"),
                               mask=currAttr.get("mask"), base=16, description=currAttr.get("description"), permission=currAttr.get("permission"), path=filepath)
        childNode.setParameters(currAttr.get("parameters"))
        childNode.setFwinfo(currAttr.get("fwinfo"))
        childNode.setAttrib(currAttr)
        # add childNode to parent
        parentNode.addChild(childNode)

        # addressMap = {address1: {mask1: [node1, node2], mask2: [node3]}, address2: {mask1: [node4]}}
        addressMap.setdefault(childNode.getAddress(), {})
        addressMap[childNode.getAddress()].setdefault(childNode.getMask(), [])
        addressMap[childNode.getAddress()][childNode.getMask()
                                           ].append(childNode)

        if "module" in currAttr:
            modulePath = currAttr["module"].replace("file://", "")
            nextPath = os.path.join(os.path.dirname(
                filepath), modulePath)
            # generate rest of tree from reference path
            buildTree(childNode, nextPath)
        else:
            # generate rest of tree from child nodes
            buildTree(childNode, filepath, current)


def dupAddress(permission='w'):
    """
    find all node that have the same address, mask and perimission
    so default is 'w' which checks for error
    pass in 'r' which checks for warning
    """
    dupMap = dict()

    for addr in addressMap.keys():
        for mask in addressMap[addr].keys():
            if mask == -1:
                continue

            writeNodes = []
            for item in addressMap[addr][mask]:
                perm = item.getAttrib().get('permission', None)
                if perm is not None and permission in perm:
                    writeNodes.append(item)

            if len(writeNodes) > 1:
                dupMap.setdefault(addr, {})
                dupMap[addr].setdefault(mask, [])
                dupMap[addr][mask] = writeNodes

    return dupMap


def invalidAddress():
    invalidMap = dict()

    for addr in addressMap.keys():
        for mask in addressMap[addr].keys():
            if mask == -1:
                continue

            binMask = bin(mask)

            firstZero = len(binMask) + 1
            for i in range(len(binMask)):
                if(binMask[i] == '1'):
                    firstZero = i
                    break

            lastZero = 0
            for i in range(len(binMask)-1, -1, -1):
                if(binMask[i] == '1'):
                    lastZero = i
                    break

            for i in range(firstZero, lastZero+1):
                if(binMask[i] == '0'):
                    invalidMap.setdefault(addr, {})
                    invalidMap[addr].setdefault(mask, [])
                    invalidMap[addr][mask] = addressMap[addr][mask]
                    break

    return invalidMap


def overlapAddress():
    overlapMap = dict()

    for addr in addressMap.keys():
        nodesInAddr = []

        for mask in addressMap[addr].keys():
            for n in addressMap[addr][mask]:
                nodesInAddr.append(n)

        for i, n1 in enumerate(nodesInAddr):
            for j, n2 in enumerate(nodesInAddr):
                if i == j:
                    continue

                # if n1.getMas

        for i, mask in enumerate(addressMap[addr].keys()):
            for j, mask2 in enumerate(addressMap[addr].keys()):
                if mask == -1 or mask2 == -1 or i == j:
                    continue

                if (mask & mask2) != 0:
                    overlapMap.setdefault(addr, {})
                    overlapMap[addr].setdefault(mask, [])
                    overlapMap[addr][mask] = addressMap[addr][mask]

    return overlapMap


def main(inFile):
    root = ParserNode(name='Root')
    buildTree(root, inFile, init=True)
    ParserNode.writeNode(root, path="temp.txt")

    for child in root.getChildren():
        cwd = os.getcwd()
        child.setParent(None)
        print("Generating:", child.getName())
        mytree = tree(child)
        os.chdir(cwd+"/pkg")
        mytree.generatePkg()
        os.chdir(cwd+"/map")
        mytree.generateRegMap()
        child.setParent(root)

    print("done")

    # # same address and same mask that have permission write
    # dupMap = dupAddress()
    # writeMap(dupMap, path="debug/error.txt")
    # # same address and same mask that have permission read
    # warningMap = dupAddress(permission='r')
    # writeMap(warningMap, path="debug/warning.txt")
    # # masks that have 0 inbetween 1
    # invalidMap = invalidAddress()
    # writeMap(invalidMap, path="debug/invalid.txt")
    # # same address that have mask overlaps in binary
    # overlapMap = overlapAddress()
    # writeMap(overlapMap, path="debug/overlap.txt")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Custom parser similar to uhal parser')
    parser.add_argument(
        "-ifs", help='addressTable/address_apollo.xml')
    inFile = parser.parse_args().ifs

    if inFile is None or not os.path.exists(inFile):
        print('invalid input filename')
        exit

    main(inFile)
