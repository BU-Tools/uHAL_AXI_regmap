class Node:
    addressMap = dict()

    def __init__(self, name=None, parentNode=None, address=None, mask=None, base=10, description=None, path=""):
        self.setParent(parentNode)
        self.__children = []

        self.setName(name)
        self.setAddress(address, base)
        self.setRelativeAddress(address, base)
        self.setMask(mask, base)
        self.setDescription(description)

        self.__parameters = dict()
        self.__fwinfo = dict()
        self.__attrib = dict()

        self.setDepth()
        self.setFilePath(path)

    #--------------- accessors ---------------#

    def getParent(self):
        return self.__parent

    def getChildren(self):
        return self.__children

    def getName(self):
        return self.__name

    def getDepth(self):
        return self.__depth

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
            if self.__mask == -1:
                return "NONE"
            else:
                return hex(self.__mask)
        else:
            return self.__mask

    def getDescription(self):
        return self.__description

    def getParameters(self):
        return self.__parameters

    def getFwinfo(self):
        return self.__fwinfo

    def getAttrib(self):
        return self.__attrib

    def getFilePath(self):
        return self.__filePath

    #--------------- modifiers ---------------#

    def setParent(self, parentNode):
        if parentNode is None:
            self.__parent = None
        elif isinstance(parentNode, Node):
            self.__parent = parentNode
        else:
            self.__parent = None

    def addChild(self, childNode):
        if isinstance(childNode, Node):
            self.__children.append(childNode)

    def setName(self, name):
        if name is None:
            self.__name = 'NONE'
        else:
            self.__name = name

    def setDepth(self, depth=None):
        if depth is None:
            if self.__parent is None:
                self.__depth = 0
            else:
                self.__depth = self.__parent.getDepth() + 1
        else:
            self.__depth = depth

    def setAddress(self, addr, base=10):
        if addr is None:
            addr = 0

        if base == 16:
            addr = int(str(addr), 16)
        else:
            addr = int(str(addr))

        if self.__parent is not None:
            self.__address = self.__parent.getAddress() + addr
        else:
            self.__address = addr

    def setRelativeAddress(self, addr, base=10):
        if addr is None:
            addr = 0

        if base == 16:
            addr = int(str(addr), 16)
        else:
            addr = int(str(addr))

        self.__relativeAddress = addr

    def setMask(self, mask, base=10):
        if mask is None:
            mask = -1

        if base == 16:
            mask = int(str(mask), 16)
        else:
            mask = int(str(mask))

        self.__mask = mask

    def setDescription(self, description):
        if description is None:
            description = ""

        self.__description = description

    def setParameters(self, eleStr):
        if eleStr is None:
            self.__parameters = dict()
            return

        try:
            elements = [i.split("=") for i in eleStr.split(";")]
            self.__parameters = dict(elements)
        except:
            print("invalid parameter string:", eleStr)

    def setFwinfo(self, eleStr):
        if eleStr is None:
            self.__fwinfo = dict()
            return

        try:
            elements = [i.split("=") for i in eleStr.split(";")]
            self.__fwinfo = dict(elements)
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
        if isinstance(node, Node):
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
