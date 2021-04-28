class ParserNode:
    addressMap = dict()

    def __init__(self, name=None, parentNode=None, address=None, mask=None, base=10, description=None, permission=None, path=""):
        self.setParent(parentNode)
        self.__children = []

        self.setName(name)
        self.setAddress(address, base)
        self.setRelativeAddress(address, base)
        self.setMask(mask, base)
        self.setDescription(description)
        self.setPermission(permission)

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
        return getChild(childName)

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
        elif base == 16:
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
        elif base == 16:
            addr = int(str(addr), 16)
        else:
            addr = int(str(addr))

        self.__relativeAddress = addr

    def setMask(self, mask, base=10):
        if mask is None:
            mask = 4294967295

        elif base == 16:
            mask = int(str(mask), 16)
        else:
            mask = int(str(mask))

        self.__mask = mask

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

    def setFwinfo(self, eleStr):
        if eleStr is None:
            self.__fwinfo = dict()
            return

        cpyStr = eleStr.strip("; ")
        try:
            elements = [i.split("=") for i in cpyStr.split(";")]
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
