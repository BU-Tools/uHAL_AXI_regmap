from lxml import etree
import argparse
import os
import copy

from node import Node


addressMap = dict()


def writeMap(m, path="tempDupError.txt"):
    """
    helper function to log a map to a text file
    """
    f = open(path, "w")

    for addr in m.keys():
        for mask in m[addr].keys():
            f.write(hex(addr) + " " + hex(mask) + '\n')
            for item in m[addr][mask]:
                f.write('\t')
                f.write("{: <50} {: <100}\n".format(
                    item.getName(), item.getFilePath()))


def buildTree(parentNode, filepath, currentElement=None):
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
    else:
        root = currentElement

    queue = []
    for child in root:
        queue.append(child)

    while (len(queue) > 0):
        current = queue.pop(0)
        currAttr = current.attrib

        # create childNode from
        # print(currAttr)
        childNode = Node(name=currAttr.get("id"), parentNode=parentNode, address=currAttr.get("address"),
                         mask=currAttr.get("mask"), base=16, description=currAttr.get("description"), path=filepath)
        childNode.setParameters(currAttr.get("parameters"))
        childNode.setFwinfo(currAttr.get("fwinfo"))
        childNode.setAttrib(currAttr)
        # add childNode to parent
        parentNode.addChild(childNode)

        #
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


def main(inFile):
    root = Node(name='Root')
    buildTree(root, inFile)

    Node.writeNode(root, path="temp.txt")
    # writeTree(root)
    dupMap = dupAddress()
    warningMap = dupAddress(permission='r')
    writeMap(dupMap, path="error.txt")
    writeMap(warningMap, path="warning.txt")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='')
    parser.add_argument(
        "-ifs", help='addressTable/address_appolo.xml')

    inFile = parser.parse_args().ifs

    # if inFile is None or not path.exists(inFile):
    #     print('invalid input filename')
    #     exit
    # else:
    #     main(inFile)

    main(inFile)
