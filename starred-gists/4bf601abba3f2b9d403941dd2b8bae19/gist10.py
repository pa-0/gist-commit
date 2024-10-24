import os,sys,time,string
import struct
import hashlib
from random import randint
import re
import zipfile



def PrintHash(Hash):
    if Hash == "":
        return ""
    HashStr = ""
    HashLen = len(Hash)
    for i in range(0,HashLen):
        A = (hex(ord(Hash[i])).lower())[2:]
        if len(A) == 1:
            A = ("0" + A)
        HashStr += A
    return HashStr

def IsHexChar(CharX):
    if CharX != "0" and CharX != "1" and CharX != "2" and CharX != "3" and CharX != "4" and CharX != "5" and CharX != "6" and CharX != "7" and CharX != "8" and CharX != "9" and CharX != "A" and CharX != "a" and CharX != "B" and CharX != "b" and CharX != "C" and CharX != "c" and CharX != "D" and CharX != "d" and CharX != "E" and CharX != "e" and CharX != "F" and CharX != "f":
        return True
    return False

def Hexify(contentX):
    if len(contentX)==0:
        print "Input content is empty\r\n"
        return ""
    else:
        Second = False
        SkipNext = False
        FinalStr = ""
        NewStr = ""
        for X in contentX:
            if SkipNext == True:
                SkipNext = False
                continue
            if IsHexChar(X)==True:
                SkipNext = True
                continue
            if Second == False:
                NewStr+=X
                Second = True
            else:
                NewStr+=X
                FinalStr += "\\x"
                FinalStr += NewStr
                NewStr = ""
                Second = False
        
        #print FinalStr + "\r\n"
        XXX = "\"" + FinalStr + "\""
        outputX =  eval(XXX)
        return outputX



def GetMyPrintables():
    Printables = string.printable
    NewPrintables = ""
    lenPrintables = len(Printables)
    for i in range(0,lenPrintables):
        if ord(Printables[i]) >= 9 and ord(Printables[i]) <= 13:
            pass
        else:
            NewPrintables += Printables[i]
    return NewPrintables

def GetHexDumpStr(XXX):
    Printables = GetMyPrintables()
    if XXX == "":
        return ""
    lenX = len(XXX)
    if lenX == 0:
        return ""
    NewConn = ""
    i = 0
    while i < lenX:
        XX = XXX[i]
        if Printables.find(XX)==-1:
            NewConn += "."
        else:
            NewConn += XX
        i = i + 1
    return NewConn

def HexDump(Binary,Size=2,Sep=" "):
    if Binary == "":
        return ""
    lenX = len(Binary)
    if lenX == 0:
        return ""
    i = 0
    FinalCon = ""
    RawCon = ""
    HexCon = ""
    StrCon = ""
    c = 0
    d = 0
    while i < lenX:
        X = Binary[i]
        RawCon += X
        XX = struct.unpack("B",X)[0]
        XXX = (hex(XX))[2:]
        if len(XXX)==1:
            XXX = "0" + XXX
        HexCon += XXX
        c = c + 1
        HexCon += Sep
        if c == 8:
            HexCon += Sep
            c = 0
        d = d + 1
        if d == 16 or i == lenX-1:
            StrCon = GetHexDumpStr(RawCon)
            if len(StrCon) < 16:
                ToAdd = 16 - len(StrCon)
                StrCon += (" "*ToAdd)
            RawCon = ""
            if len(HexCon) < 51:
                ToAdd = 51-len(HexCon)
                HexCon += (" "*ToAdd)
            FinalCon += HexCon
            HexCon = ""
            FinalCon += " "
            FinalCon += StrCon
            StrCon = ""
            FinalCon += "\r\n"
            d = 0
        i = i + 1
    return FinalCon


def GetNumberOfNulls(Input):
    if Input == "":
        return 0
    Num = 0;
    InputLen = len(Input)
    for i in range(0,InputLen):
        if Input[i] == "\x00":
            Num += 1
    return Num


#takes input of type string
#returns input without nulls
def EncodeNulls(Key):
    if Key == "":
        return ""
    Num = GetNumberOfNulls(Key)
    if Num == 0:
        return Key

    KK = ""
    KLen = len(Key)
    for i in range(0,KLen):
        if Key[i] == "\x00":
            KK += "\x01"
        else:
            KK += Key[i]
    return KK




def GetGrbit(Input):
    KeyNoNulls = 0xFFFFFFFF
    Num = GetNumberOfNulls(Input)
    if Num == 0:
        return KeyNoNulls
    InputLen = len(Input)
    BinaryStr = ""
    for i in range(0,InputLen):
        if Input[i] == "\x00":
            BinaryStr += "0"
        else:
            BinaryStr += "1"
    KeyNoNulls = int(BinaryStr,2)
    return KeyNoNulls





def CreateHashStructure(Pwd,Key):
    Struc = ""
    Struc += "\xFF"
    sKey = struct.pack("L",Key)
    All = Pwd + sKey
    m = hashlib.sha1()
    m.update( All )
    Hash = m.digest()
    BothGrbits = GetGrbit(sKey + Hash)
    BothGrbits_ = struct.pack("L",BothGrbits)
    Struc += BothGrbits_[2]
    Struc += BothGrbits_[1]
    Struc += BothGrbits_[0]
    
    KeyNoNulls = EncodeNulls(sKey)
    Struc += KeyNoNulls
    PasswordHashNoNulls = EncodeNulls(Hash)
    Struc += PasswordHashNoNulls
    Struc += "\x00"
    if len(Struc) != 29:
        return ""
    return Struc


def GetSeed():
    return randint(0,0xFF) 

def GetSeedX(Len):
    Seed = 0
    while(1):
        Seed = randint(0,0xFF)
        if (Seed & 6) / 2 == Len:
            break
    return Seed


def GetIgnoredLengthGC(Len):
    if Len < 16:
        return 0
    return (Len - 16) / 2

def GetIgnoredLengthCMG(Len):
    if Len < 22:
        return 0
    return (Len - 22) / 2

def GetIgnoredLength(Len):
    if Len < 72:
        return 0
    return (Len - 72) / 2

def GetSeed():
    return randint(0,0xFF) 

def GetSeedX(Len):
    Seed = 0
    while(1):
        Seed = randint(0,0xFF)
        if (Seed & 6) / 2 == Len:
            break
    return Seed


def EncodeGC(Value,Seed,DefaultIgnoredChar):
    GC = ""

    Data = struct.pack("B",Value)
    DataLen = len(Data)
    
    #print "Seed: " + hex(Seed)

    GC += chr(Seed)


    VersionEnc = Seed ^ 2
    #print "VersionEnc: " + hex(VersionEnc)
    GC += chr(VersionEnc)

    ProjId = "{00000000-0000-0000-0000-000000000000}"
    ProjIdLen = len(ProjId)
    ProjKey  = 0
    for i in range(0,ProjIdLen):
        ProjKey += ord(ProjId[i])
    ProjKey = ProjKey & 0xFF
     
    #print "ProjKey: " + hex(ProjKey)

    ProjKeyEnc = ProjKey ^ Seed
    #print "ProjKeyEnc: " + hex(ProjKeyEnc)
    GC += chr(ProjKeyEnc)



    UnencryptedByte1  = ProjKey
    EncryptedByte1  = ProjKeyEnc
    EncryptedByte2 = VersionEnc

    IgnoredLength = (Seed & 6) / 2
    #print "IgnoredLength: " + str(IgnoredLength)


    #IgnoredEnc
    ByteEnc = 0
    IgnoredEnc = ""
    for i in range(0,IgnoredLength):
        TempValue = DefaultIgnoredChar #Any Value
        ByteEnc = ( (TempValue) ^ (EncryptedByte2 + UnencryptedByte1) ) & 0xFF
        IgnoredEnc += chr(ByteEnc)
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1  = ByteEnc
        UnencryptedByte1  = DefaultIgnoredChar #Any Value

    
    GC += IgnoredEnc


    #DataLengthEnc
    DataLengthEnc = ""
    DataLen_ = struct.pack("L",DataLen)
    for i in range(0,4):
        ByteEnc = ((ord(DataLen_[i])) ^ (EncryptedByte2 + UnencryptedByte1)) & 0xFF
        DataLengthEnc += chr(ByteEnc)
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1  = ByteEnc
        UnencryptedByte1  = ord(DataLen_[i])

    GC += DataLengthEnc

    
    #DataEnc
    DataEnc = ""
    Data_ = Data

    for i in range(0,DataLen):
        ByteEnc = ((ord(Data_[i])) ^ (EncryptedByte2 + UnencryptedByte1)) & 0xFF
        DataEnc += chr(ByteEnc)
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1  = ByteEnc
        UnencryptedByte1  = ord(Data_[i])

    GC += DataEnc
    return GC

def EncodeCMG(Value,Seed,DefaultIgnoredChar):
    CMG = ""

    Data = struct.pack("L",Value)
    DataLen = len(Data)
    
    #print "Seed: " + hex(Seed)

    CMG += chr(Seed)


    VersionEnc = Seed ^ 2
    #print "VersionEnc: " + hex(VersionEnc)
    CMG += chr(VersionEnc)

    ProjId = "{00000000-0000-0000-0000-000000000000}"
    ProjIdLen = len(ProjId)
    ProjKey  = 0
    for i in range(0,ProjIdLen):
        ProjKey += ord(ProjId[i])
    ProjKey = ProjKey & 0xFF
     
    #print "ProjKey: " + hex(ProjKey)

    ProjKeyEnc = ProjKey ^ Seed
    #print "ProjKeyEnc: " + hex(ProjKeyEnc)
    CMG += chr(ProjKeyEnc)



    UnencryptedByte1  = ProjKey
    EncryptedByte1  = ProjKeyEnc
    EncryptedByte2 = VersionEnc

    IgnoredLength = (Seed & 6) / 2
    #print "IgnoredLength: " + str(IgnoredLength)


    #IgnoredEnc
    ByteEnc = 0
    IgnoredEnc = ""
    for i in range(0,IgnoredLength):
        TempValue = DefaultIgnoredChar #Any Value
        ByteEnc = ( (TempValue) ^ (EncryptedByte2 + UnencryptedByte1) ) & 0xFF
        IgnoredEnc += chr(ByteEnc)
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1  = ByteEnc
        UnencryptedByte1  = DefaultIgnoredChar #Any Value

    
    CMG += IgnoredEnc


    #DataLengthEnc
    DataLengthEnc = ""
    DataLen_ = struct.pack("L",DataLen)
    for i in range(0,4):
        ByteEnc = ((ord(DataLen_[i])) ^ (EncryptedByte2 + UnencryptedByte1)) & 0xFF
        DataLengthEnc += chr(ByteEnc)
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1  = ByteEnc
        UnencryptedByte1  = ord(DataLen_[i])

    CMG += DataLengthEnc

    
    #DataEnc
    DataEnc = ""
    Data_ = Data

    for i in range(0,DataLen):
        ByteEnc = ((ord(Data_[i])) ^ (EncryptedByte2 + UnencryptedByte1)) & 0xFF
        DataEnc += chr(ByteEnc)
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1  = ByteEnc
        UnencryptedByte1  = ord(Data_[i])

    CMG += DataEnc
    return CMG


def RotateInteger(IntX):
    if IntX == 0:
        return 0
    h = hex(IntX)[2:]
    h_rev = h[::-1]
    return int("0x" + h_rev,0x10)



#return Key and Hash separated by :
def DecodeHashStructure(Struc):
    if Struc == "":
        return ""
    if len(Struc) != 29:
        return ""
    StrucLen = len(Struc)
    Reserved = ord(Struc[0])
    #print "Reserved: " + hex(Reserved)
    if Reserved != 0xFF:
        return ""

    A = Struc[1]
    B = Struc[2]
    C = Struc[3]
    
    BothGrbits = (struct.unpack("=L","\x00" + C + B + A)[0]) >> 8

    
    GrbitKey = ( ord(A) >> 4) & 0xF
    GrbitKey_Again = (BothGrbits >> 20) & 0xF
    #print "GrbitKey: " + hex(GrbitKey)
    #print "GrbitKey_Again: " + hex(GrbitKey_Again)

    GrbitHashNull  = BothGrbits & 0xFFFFF 
    #print "GrbitHashNull: " + hex(GrbitHashNull)

    KeyNoNulls = Struc[4:8]
    #print "KeyNoNulls: " + PrintHash(KeyNoNulls)

    Key = PrintHash(ApplyNulls(KeyNoNulls,GrbitKey))
    #print "Key: " + Key

    HashNoNulls = Struc[8:28]
    #print "HashNoNulls: " + PrintHash(HashNoNulls)
    Hash = PrintHash(ApplyNulls(HashNoNulls,GrbitHashNull))
    #print "Hash: " + Hash

    Terminator = ord(Struc[28:29])
    if Terminator != 0:
        return ""
    return Key + ":" + Hash
    

#returns DPB string
def Encode(Pwd,Key,Seed,DefaultIgnoredChar):
    Data = CreateHashStructure(Pwd,Key)
    if Data == "":
        return ""

    DataLen = len(Data)
    if DataLen != 29:
        return ""


    DPB = ""
    
    #print "Seed: " + hex(Seed)

    DPB += chr(Seed)


    VersionEnc = Seed ^ 2
    #print "VersionEnc: " + hex(VersionEnc)
    DPB += chr(VersionEnc)

    ProjId = "{00000000-0000-0000-0000-000000000000}"
    ProjIdLen = len(ProjId)
    ProjKey  = 0
    for i in range(0,ProjIdLen):
        ProjKey += ord(ProjId[i])
    ProjKey = ProjKey & 0xFF
     
    #print "ProjKey: " + hex(ProjKey)

    ProjKeyEnc = ProjKey ^ Seed
    #print "ProjKeyEnc: " + hex(ProjKeyEnc)
    DPB += chr(ProjKeyEnc)



    UnencryptedByte1  = ProjKey
    EncryptedByte1  = ProjKeyEnc
    EncryptedByte2 = VersionEnc

    IgnoredLength = (Seed & 6) / 2
    #print "IgnoredLength: " + str(IgnoredLength)


    #IgnoredEnc
    ByteEnc = 0
    IgnoredEnc = ""
    for i in range(0,IgnoredLength):
        TempValue = DefaultIgnoredChar #Any Value
        ByteEnc = ( (TempValue) ^ (EncryptedByte2 + UnencryptedByte1) ) & 0xFF
        IgnoredEnc += chr(ByteEnc)
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1  = ByteEnc
        UnencryptedByte1  = DefaultIgnoredChar #Any Value

    
    DPB += IgnoredEnc


    #DataLengthEnc
    DataLengthEnc = ""
    DataLen_ = struct.pack("L",DataLen)
    for i in range(0,4):
        ByteEnc = ((ord(DataLen_[i])) ^ (EncryptedByte2 + UnencryptedByte1)) & 0xFF
        DataLengthEnc += chr(ByteEnc)
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1  = ByteEnc
        UnencryptedByte1  = ord(DataLen_[i])

    DPB += DataLengthEnc

    
    #DataEnc
    DataEnc = ""
    Data_ = Data  

    for i in range(0,DataLen):
        ByteEnc = ((ord(Data_[i])) ^ (EncryptedByte2 + UnencryptedByte1)) & 0xFF
        DataEnc += chr(ByteEnc)
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1  = ByteEnc
        UnencryptedByte1  = ord(Data_[i])

    DPB += DataEnc
        
    return DPB


def ApplyNulls(K,Bitmap):
    if K == "":
        return ""
    
    KLen = len(K)
    KK = ""
    ii = 0
    for i in range(KLen,0,-1):
        Y = 1 << (i-1)
        if Bitmap & Y == 0:
            KK += "\x00"
        else:
            KK += K[ii]
        ii += 1
    return KK

#returns Password Hash Data Structure
def Decode(In,InLen):
    if In == "" or InLen == 0 or len(In) != InLen:
        return ""

    hxIN = Hexify(In)
    if hxIN == "":
        return ""
    hxLength = len(hxIN)
    if hxLength < 3:
        return ""
  
    Seed = ord(hxIN[0])
    print "Seed: " + hex(Seed)


    VersionEnc = ord(hxIN[1])
    print "VersionEnc: " + hex(VersionEnc)
    Version = Seed ^ VersionEnc
    print "Version: " + hex(Version)
    if Version != 2:
        print "Invalid version"
        return ""

    ProjKeyEnc = ord(hxIN[2])
    print "ProjKeyEnc: " + hex(ProjKeyEnc)
    ProjKey = Seed ^ ProjKeyEnc
    print "Project Key: " + hex(ProjKey)


    UnencryptedByte1  = ProjKey
    EncryptedByte1  = ProjKeyEnc
    EncryptedByte2 = VersionEnc

    IgnoredLength = (Seed & 6) / 2
    print "IgnoredLength: " + str(IgnoredLength)
    if IgnoredLength + 3 > hxLength:
        return ""
    Off = 3

    
    IgnoredEnc = hxIN[Off:Off+IgnoredLength]
    Off += IgnoredLength
    
    AllIgnored = []
    for X in IgnoredEnc:
        Byte = ( (ord(X) ) ^ ( (EncryptedByte2 + UnencryptedByte1) & 0xFF))
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1 = ord(X)
        UnencryptedByte1 = Byte
        AllIgnored.append(Byte)
    print "Ignored: " + str(AllIgnored)
    
    Left = hxLength - Off
    #print Left
    if Left < 4:
        return ""
    
    Rest = hxIN[Off:]
    DataLengthEnc = Rest[0:4]
    DataEnc = Rest[4:]

    DataLength = 0
    
    ByteIndex = 0
    
    for ByteEnc  in DataLengthEnc:
        Byte = (  (ord(ByteEnc))   ^ ( (EncryptedByte2 + UnencryptedByte1)& 0xFF ))
        TempValue = int(pow(256, ByteIndex))
        #print TempValue
        #print type(TempValue)
        TempValue = TempValue * Byte
        DataLength += TempValue
        EncryptedByte2  = EncryptedByte1
        EncryptedByte1 = ord(ByteEnc) & 0xFF
        UnencryptedByte1 = Byte
        ByteIndex = ByteIndex + 1



    #print hex(DataLength)
    if DataLength != len(DataEnc):
        print "Invalid data length"
        return ""
    Data = ""
    for ByteEnc in DataEnc:
        Byte =  (  (ord(ByteEnc))    ^ ((EncryptedByte2 + UnencryptedByte1)& 0xFF )  )
        Data += chr(Byte)
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1 = ord(ByteEnc) & 0xFF
        UnencryptedByte1 = Byte
    return Data


#Extract salt
def GetKey(Data):
    if Data == "":
        return ""
    Both_x = Data.split(":")
    if len(Both_x) == 0:
        return ""
    return Both_x[0]
    

#Extract Password Hash
def GetPasswordHash(Data):
    if Data == "":
        return ""
    Both_x = Data.split(":")
    if len(Both_x) < 2:
        return ""
    return Both_x[1]


#The chosen character for Ignored data
def GetIgnoredCharacter(In,InLen):
    if In == "" or InLen == 0 or len(In) != InLen:
        return 0

    hxIN = Hexify(In)
    if hxIN == "":
        return 0
    hxLength = len(hxIN)
    if hxLength < 3:
        return 0
  
    Seed = ord(hxIN[0])


    VersionEnc = ord(hxIN[1])
    Version = Seed ^ VersionEnc


    ProjKeyEnc = ord(hxIN[2])
    ProjKey = Seed ^ ProjKeyEnc


    UnencryptedByte1  = ProjKey
    EncryptedByte1  = ProjKeyEnc
    EncryptedByte2 = VersionEnc

    IgnoredLength = (Seed & 6) / 2
    if IgnoredLength + 3 > hxLength:
        return 0

    IgnoredEnc = hxIN[3:3+IgnoredLength]
    
    AllIgnored = []
    for X in IgnoredEnc:
        Byte = ( (ord(X) ) ^ ( (EncryptedByte2 + UnencryptedByte1) & 0xFF))
        EncryptedByte2 = EncryptedByte1
        EncryptedByte1 = ord(X)
        UnencryptedByte1 = Byte
        AllIgnored.append(Byte)

    if len(AllIgnored) > 0:
        return AllIgnored[0]

    return 0


def CreateZip(inD,Ext="docx"):
    if os.path.exists(inD) != True:
        print "Directory does not exist\r\n"
        return False
    
    if os.path.isfile(inD):
        print "Input is not a directory\r\n"
        return False

    hZip = zipfile.ZipFile(inD + "." + Ext,'w',zipfile.ZIP_DEFLATED)

    for Dir, SubDirs, Files in os.walk(inD):
        for FileX in Files:
            fFile = os.path.join(Dir, FileX)
            fIn = open(fFile,"rb")
            fCon = fIn.read()
            fIn.close()
            NewfFile = fFile[len(inD)+1:]
            hZip.writestr(NewfFile,fCon)
    hZip.close()
    return True

def ExtractOffice2007(inFile):
    if inFile == "":
        return 0
    filenameX,fileextX = os.path.splitext(inFile)
    try:
        ZipZ = zipfile.ZipFile(inFile)
        ZipZ.extractall(filenameX)
        ZipZ.close()
        print "Zip file was successfully extracted to " + "\\" + filenameX +"\\"
    except:
        print "Zip file is corrupt"
        return 0
    return 1


def GetOffice2007VbaBin(inFile):
    if inFile == "":
        return ""
    ret = ExtractOffice2007(inFile)
    if ret == 0:
        return ""
    filenameX,fileextX = os.path.splitext(inFile)
    dirX = filenameX
    for fYf in os.listdir(dirX):
        tgt = dirX + "\\" + fYf
        if os.path.isfile(tgt)==False and os.path.exists(tgt + "\\vbaproject.bin")==True:
            return tgt + "\\vbaproject.bin"
    return ""
    


def IsOffice2007(inFile):
    if inFile == "":
        return False

    if os.path.getsize(inFile) < 4:
        return False
    
    fInZ = open(inFile,"rb")
    fConZ = fInZ.read(4)
    fInZ.close()

    if fConZ[0]!="P" or fConZ[1]!="K":
        return False

    mjv = fConZ[2]
    mnv = fConZ[3]

    v1 = (mjv == "\x03" and mnv == "\x04")
    v2 = (mjv == "\x05" and mnv == "\x06")
    v3 = (mjv == "\x07" and mnv == "\x08")
    if v1 == False and v2 == False and v3 == False:
        return False
    return True


def RemoveProtectionAndUpdatePassword(inDoc,NewPass):
    if inDoc == "":
        return ""
    
    ProjIds = re.findall("ID=\"\{([a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12})\}\"",inDoc,re.I)
    NumProjIds = len(ProjIds)
    ProjIdFound = False
    if  NumProjIds != 0:
        for ProjId in ProjIds:
            if ProjId == "00000000-0000-0000-0000-000000000000":
                ProjIdFound = True
                break
    if ProjIdFound == False:
        print "Input file does not have a password-protected macro.\r\n"
        return ""


    III = re.findall("DPB=\"([0-9a-zA-Z]{72,})\"",inDoc,re.I)
    II = re.findall("CMG=\"([0-9a-zA-Z]{22,})\"",inDoc,re.I)
    I = re.findall("GC=\"([0-9a-zA-Z]{16,})\"",inDoc,re.I)

    if len(III) == 0:
        print "DPB value not found\r\n"
        return ""

    if len(II) == 0:
        print "CMG value not found\r\n"
        return ""

    if len(I) == 0:
        print "GC value not found\r\n"
        return ""

    iDPB = III[0]
    iCMG = II[0]
    iGC = I[0]

    print "## DPB: " + iDPB
    hDPB = Decode(iDPB,len(iDPB))
    print HexDump(hDPB)
    KeyNHash = DecodeHashStructure(hDPB)
    Key = GetKey(KeyNHash)
    print "Key: " + Key
    Hash = GetPasswordHash(KeyNHash)
    print "Hash: " + Hash

    print "\r\n## CMG: " + iCMG
    hCMG = Decode(iCMG,len(iCMG))
    print HexDump(hCMG)

    print "\r\n## GC: "  + iGC
    hGC = Decode(iGC,len(iGC))
    print HexDump(hGC)


    IgnoredChar = GetIgnoredCharacter(iDPB,len(iDPB))
    #print "Ignored Character: " + hex(IgnoredChar)


    print "Using Password: " + NewPass

    #---------- DPB
    III = re.findall("DPB=\"([0-9a-zA-Z]{72,})\"",inDoc,re.I)
    All =  III[0]
    if All == "":
        print "Found DPB value is empty\r\n"
        return ""

    
    print "\r\n\r\n"
    print "Old DPB: " + All
    DPBLen = len(All)
    IgnoredLen = GetIgnoredLength(DPBLen)
    Seed = GetSeedX(IgnoredLen)
    #print "\r\nNew Values: \r\n"
    #print "Seed: " + hex(Seed)
    key = randint(0,0xFFFFFFFF)
    #print "Key: " + hex(key)


    
    PDB = Encode(NewPass,key,Seed,IgnoredChar)
    sDPB = PrintHash(PDB).upper()
    print "New DPB: " + sDPB

    inDocX = re.sub("DPB=\"([0-9a-zA-Z]{72,})\"","DPB=\""+sDPB+"\"",inDoc,re.I)
    #---------- CMG
    III = re.findall("CMG=\"([0-9a-zA-Z]{22,})\"",inDoc,re.I)
    All =  III[0]
    if All == "":
        print "Found CMG value is empty\r\n"
        return ""


    print "Old CMG: " + All
    CMGLen = len(All)
    IgnoredLen = GetIgnoredLengthCMG(CMGLen)
    Seed = GetSeedX(IgnoredLen)

    #print "New Values: \r\n"
    #print "Seed: " + hex(Seed)


    CMG = EncodeCMG(0,Seed,IgnoredChar)
    sCMG = PrintHash(CMG).upper()
    print "New CMG: " + sCMG

    inDocXX = re.sub("CMG=\"([0-9a-zA-Z]{22,})\"","CMG=\""+sCMG+"\"",inDocX,re.I)
    #---------------- GC
    II = re.findall("GC=\"([0-9a-zA-Z]{16,})\"",inDoc,re.I)
    All =  II[0]
    if All == "":
        print "Found GC value is empty\r\n"
        return ""


    print "Old GC: " + All
    GCLen = len(All)
    IgnoredLen = GetIgnoredLengthGC(GCLen)
    Seed = GetSeedX(IgnoredLen)

    #print "New Values: \r\n"
    #print "Seed: " + hex(Seed)


    GC = EncodeGC(0xFF,Seed,IgnoredChar)
    sGC = PrintHash(GC).upper()
    print "New GC: " + sGC

    inDocXXX = re.sub("GC=\"([0-9a-zA-Z]{16,})\"","GC=\""+sGC+"\"",inDocXX,re.I)

    return inDocXXX


argC = len(sys.argv)
if argC != 3:
    print "Usage: \r\n"
    print "RemoveVBAMacroPWD.py input.doc NewPassword\r\n"
    print "RemoveVBAMacroPWD.py input.docx NewPassword\r\n"
    sys.exit(-1)


inF = sys.argv[1]
NewPassX = (sys.argv[2]).rstrip().lstrip()


OrigInf = inF
Office2007 = False
VbaBinFile = ""



if os.path.exists(inF) == False:
    print "Input file does not exist\r\n"
    sys.exit(-2)




if IsOffice2007(inF) == True:
    Office2007 = True


if Office2007 == True:
    VbaBinFile = GetOffice2007VbaBin(inF) #Will also extract zip contents
    if VbaBinFile == "":
        print "VbaProject.bin was not found in input Office2007 file\r\n"
        sys.exit(-3)
    inF = VbaBinFile
    
    
    

fDoc = open(inF,"rb")
inDocX = fDoc.read()
fDoc.close()




NewContent = RemoveProtectionAndUpdatePassword(inDocX,NewPassX)
if NewContent == "":
    print "Error removing protection\r\n"
    sys.exit(-4)





fileN,fileExt = os.path.splitext(inF)
NewFileName = fileN + "_" + fileExt
fOut = open(NewFileName,"wb")
fOut.write(NewContent)
fOut.close()



if Office2007 == True:
    os.remove(inF)
    OldFileName = NewFileName
    NewFileName = inF
    os.rename(OldFileName,NewFileName)
    OrigInfX,OrigInfExtX = os.path.splitext(OrigInf)
    
    NewExt = "doc"
    if OrigInfExtX[1:3].lower() == "xl":
        NewExt = "xls"
    
    ret = CreateZip(OrigInfX,NewExt)
    if ret == True:
        NewFileName = (OrigInfX + "_." + NewExt)
        try:
            os.rename((OrigInfX + "." + NewExt),(OrigInfX + "_." + NewExt))
        except:
            print "Error: file already exists"
            sys.exit(-4)
    else:
        print "Error creating new Office2007 file\r\n"
        sys.exit(-5)
        

print "New unprotected file written to " + NewFileName


    