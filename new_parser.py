from lxml import etree
import argparse
import os
import copy


addressMap = dict()


class Node:
    def __init__(self, name, depth=0, address=0, relativeAddress=0):
        self.parent = None
        self.children = []
        self.attrib = dict()

        self.name = name
        self.depth = depth
        self.address = address
        self.relativeAddress = relativeAddress
        self.filePath = ""


def printTree(node):
    stack = [node]
    while (len(stack) > 0):
        current = stack.pop(0)
        for x in range(current.depth):
            print("\t", end="")
        print(current.name)
        for child in current.children:
            stack.insert(0, child)


def writeTree(node):
    """
    write tree to log.txt
    """

    f = open("log.txt", "w")
    stack = [node]
    while (len(stack) > 0):
        current = stack.pop(0)
        for x in range(current.depth):
            f.write("|\t")
        f.write('|-->')
        f.write("id: " + current.name)
        f.write(" address: " + hex(current.address))
        f.write(" relative address: " + hex(current.relativeAddress))
        f.write('\n')
        block = []
        for child in current.children:
            block.append(child)
        stack = block + stack


def writeMap(m):
    f = open("dupError.txt", "w")
    for key in m.keys():
        f.write(hex(key) + '\n')
        for item in m[key]:
            f.write('\t')
            f.write("{: <50} {: <100}\n".format(item.name, item.filePath))


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
        currentAttr = current.attrib

        childNode = Node(currentAttr['id'], parentNode.depth+1)
        parentNode.children.append(childNode)
        childNode.parent = parentNode
        childNode.filePath = filepath
        childNode.attrib = copy.deepcopy(currentAttr)
        childNode.attrib.pop('id', None)

        if "address" in currentAttr:
            addr = int(currentAttr["address"], 16)
            childNode.address = parentNode.address + addr
            childNode.relativeAddress = addr
            childNode.attrib.pop('address', None)
        else:
            childNode.address = parentNode.address

        addressMap.setdefault(childNode.address, []).append(childNode)

        if "module" in currentAttr:
            modulePath = currentAttr["module"].replace("file://", "")
            nextPath = os.path.join(os.path.dirname(
                filepath), modulePath)
            # generate rest of tree from reference path
            buildTree(childNode, nextPath)
        else:
            # generate rest of tree from child nodes
            buildTree(childNode, filepath, current)


def dupAddress():
    dupMap = dict()
    for key in addressMap.keys():
        write = 0
        writeNodes = []
        for item in addressMap[key]:
            perm = item.attrib.get('permission', None)
            if perm is not None and 'w' in perm:
                writeNodes.append(item)
        if len(writeNodes) > 1:
            dupMap[key] = writeNodes
    return dupMap


def main(inFile):
    root = Node('Root')
    inFile = os.path.join(dirName, inFile)
    buildTree(root, inFile)

    writeTree(root)
    dupMap = dupAddress()
    writeMap(dupMap)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='')
    parser.add_argument(
        "-ifs", help='address_appolo.xml')
    parser.add_argument(
        "-dir", help='address table directory path')

    inFile = parser.parse_args().ifs
    global dirName
    dirName = parser.parse_args().dir

    # if inFile is None or not path.exists(inFile):
    #     print('invalid input filename')
    #     exit
    # else:
    #     main(inFile)

    main(inFile)


"""
keep track of all attributes in the node

"""
