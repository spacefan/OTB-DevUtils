import os
import os.path as op
import re

def updateModuleDependencies(path,dep,opt_dep,test_dep):
  isInModDef = False
  lineBuffer = ""
  lineList = []
  keywords = ["DEPENDS", "OPTIONAL_DEPENDS", "TEST_DEPENDS","EXAMPLE_DEPENDS","DESCRIPTION"]
  
  modname  = ""
  desc = ""
  
  fd = open(path,'rb')
  for line in fd:
    cleanLine = (line.replace("\t"," ")).strip(" \n\r")
    
    # skip commented line
    idx=cleanLine.find('#')
    if idx != -1:
      cleanLine=cleanLine[0:idx]
      
    if not cleanLine:
      continue
    
    # collapse multi-spaces
    sizeChanged = True
    while (sizeChanged):
      sizeBefore = len(cleanLine)
      cleanLine = cleanLine.replace('  ',' ')
      sizeAfter = len(cleanLine)
      if (sizeBefore == sizeAfter):
        sizeChanged = False
        
    if cleanLine.startswith("otb_module("):
      isInModDef = True
    
    if isInModDef:
      lineBuffer = lineBuffer + cleanLine + " "
    
    if cleanLine.endswith(')'):
      # parse buffer
      if isInModDef:
        words = (lineBuffer[11:-2]).split(' ')
        modname = words[0]
        if "DESCRIPTION" in words:
          pos = words.index("DESCRIPTION") + 1
          desc = words[pos]
    if not isInModDef:
      lineList.append(line)

  fd.close()

  lineList.append("\notb_module("+modname+"\n")
  if len(dep) > 0:
    lineList.append("  DEPENDS"+"\n")
    for d in dep:
      lineList.append("    OTB"+d+"\n")
  if len(opt_dep) > 0:
    lineList.append("\n  OPTIONAL_DEPENDS"+"\n")
    for d in opt_dep:
      lineList.append("    OTB"+d+"\n")
  if len(test_dep) > 0:
    lineList.append("\n  TEST_DEPENDS"+"\n")
    for d in test_dep:
      lineList.append("    OTB"+d+"\n")
  if len(desc) > 0:
    lineList.append("\n  DESCRIPTION"+"\n")
    lineList.append("    "+desc+"\n")
  lineList.append(")"+"\n")
  
  fd = open(path,'w')
  fd.writelines(lineList)
  fd.close()

def parseModuleDefinition(path):
  depList = {}
  optDepList = {}
  testDepList = {}
  isInModDef = False
  lineBuffer = ""
  lineList = []
  keywords = ["DEPENDS", "OPTIONAL_DEPENDS", "TEST_DEPENDS","EXAMPLE_DEPENDS","DESCRIPTION"]
  
  fd = open(path,'rb')
  for line in fd:
    cleanLine = (line.replace("\t"," ")).strip(" \n\r")
    
    # skip commented line
    idx=cleanLine.find('#')
    if idx != -1:
      cleanLine=cleanLine[0:idx]
    
    if not cleanLine:
      continue
    
    # collapse multi-spaces
    sizeChanged = True
    while (sizeChanged):
      sizeBefore = len(cleanLine)
      cleanLine = cleanLine.replace('  ',' ')
      sizeAfter = len(cleanLine)
      if (sizeBefore == sizeAfter):
        sizeChanged = False
    
    if cleanLine.startswith("otb_module("):
      isInModDef = True
    
    if isInModDef:
      lineBuffer = lineBuffer + cleanLine + " "
      lineList.append(line)
    
    if cleanLine.endswith(')'):
      # parse buffer
      if isInModDef:
        words = (lineBuffer[11:-2]).split(' ')
        modName = words[0]
        if modName.startswith('OTB'):
          modName = modName[3:]
        if "DEPENDS" in words:
          pos = words.index("DEPENDS") + 1
          while (pos < len(words)):
            if words[pos] in keywords:
              break
            curDep = (words[pos])[3:]
            depList[curDep] = []
            pos += 1
        if "OPTIONAL_DEPENDS" in words:
          pos = words.index("OPTIONAL_DEPENDS") + 1
          while (pos < len(words)):
            if words[pos] in keywords:
              break
            curDep = (words[pos])[3:]
            optDepList[curDep] = []
            pos += 1
        if "TEST_DEPENDS" in words:
          pos = words.index("TEST_DEPENDS") + 1
          while (pos < len(words)):
            if words[pos] in keywords:
              break
            curDep = (words[pos])[3:]
            testDepList[curDep] = []
            pos += 1
        isInModDef = False
        lineBuffer = ""
        lineList = []
  
  fd.close()
  return [depList , optDepList, testDepList]

def parseOTBModuleCmake(path):
  depends = {}
  optDepends = {}
  testDepends = {}
  for grpDir in os.listdir(path):
    grpPath = op.join(path,grpDir)
    if not op.isdir(grpPath):
      continue
    for modDir in os.listdir(grpPath):
      modPath = op.join(grpPath,modDir)
      if not op.isdir(modPath):
        continue
      otbModuleCmake = op.join(modPath,"otb-module.cmake")
      if not op.isfile(otbModuleCmake):
        # not a valid OTB module
        continue
      # parse module declaration
      [depList , optDepList, testDepList] = parseModuleDefinition(otbModuleCmake)
      depends[modDir] = depList
      optDepends[modDir] = optDepList
      testDepends[modDir] = testDepList
  return [depends , optDepends, testDepends]

def parseModuleRoot(path):
  sourceList = {}
  testList = {}
  moduleList = {}
  groups = {}
  codeExt = [".h",".hpp",".hxx",".c",".cpp",".cxx",".txx"]
  
  for grpDir in os.listdir(path):
    grpPath = op.join(path,grpDir)
    if not op.isdir(grpPath):
      continue
    for modDir in os.listdir(grpPath):
      modPath = op.join(grpPath,modDir)
      if not op.isdir(modPath):
        continue
      if not grpDir in groups:
        groups[grpDir] = {}
      groups[grpDir][modDir] = 1
      moduleList[modDir] = []
      testList[modDir] = []
      # parse sources
      subDir_src = op.join(modPath,'src')
      subDir_inc = op.join(modPath,'include')
      subDir_app = op.join(modPath,'app')
      subDir_test = op.join(modPath,'test')
      for dirPath, dirNames, fileNames in os.walk(modPath):
        for fileName in fileNames:
          ext = (op.splitext(fileName))[1]
          if not ext in codeExt:
            continue
          shortPath = dirPath.replace(path,'Modules',1)
          if  dirPath.startswith(subDir_test):
            testList[modDir].append(op.join(shortPath,fileName))
          else:
            # check for duplicated source names
            if fileName in sourceList:
              print "Warning : duplicated source name : "+fileName
            sourceList[fileName] = modDir
            moduleList[modDir].append(op.join(shortPath,fileName))

  return [groups,moduleList,sourceList,testList]

def searchAllIncludes(path):
  includes = []
  
  ifstream = open(path)
  lines = ifstream.readlines()
  ifstream.close()
  
  search_string=r'^\s{0,}#include *([<"])([^<"]+)([>"])'
  includeRegexp=re.compile(search_string)
  
  for line in lines:
    gg = includeRegexp.match(line)
    if (gg != None) and (len(gg.groups()) == 3):
      includes.append(gg.group(2))
  return includes

def analyseInclude(inc,sourceList):
  result = "other"
  systemInc = ["string.h","stdio.h","stdint.h","ctype.h","dirent.h",  \
    "assert.h","sys/types.h","stdlib.h","time.h","memory.h","math.h",\
    "io.h","signal.h","fcntl.h","mex.h","winsock2.h","pmmintrin.h",\
    "emmintrin.h","windows.h","unistd.h","errno.h","stddef.h","float.h",\
    "string","iostream","vector","fstream","map","algorithm","typeinfo",\
    "cassert","iterator","complex","numeric","iomanip","cmath","stdio",\
    "cstdlib","cstdio","iosfwd","sstream","limits","utility","exception",\
    "list","deque","set","cstring","stdexcept","clocale","ostream","cfloat",\
    "cstddef","stdarg.h","cctype","malloc.h"]
  
  baseInc = op.basename(inc)
  hasUnderScore = bool(baseInc.count("_"))
  extInc = (op.splitext(baseInc))[1]
  
  if (inc in systemInc) or inc.startswith("sys/"):
    result = "system"
  elif baseInc.startswith("otb") and (not hasUnderScore) and (extInc in [".h",".txx"]):
    if baseInc in sourceList:
      result = sourceList[baseInc]
    elif baseInc == "otbConfigure.h":
      result = "Common"
    else:
      print "OTB header not found : "+inc
  elif baseInc.startswith("itk"):
    if baseInc in sourceList:
      result = sourceList[baseInc]
    else:
      result = "ITK"
  elif baseInc[0:3] in ["vcl","vnl"]:
    result = "ITK"
  elif inc.startswith("itksys"):
    result = "ITK"
  elif (inc.find("gdal") == 0) or (inc.find("ogr") == 0) or (inc.find("cpl_") == 0):
    result = "GDAL"
  elif (inc.find("ossim") == 0):
    result = "Ossim"
  elif (inc.find("opencv") == 0):
    result = "OpenCV"
  elif (inc == "otb_muparser.h" or inc.find("muParser") == 0):
    result = "MuParser"
  elif (inc.find("mpParser") == 0):
    result = "MuParserX"
  elif (inc.find("boost") == 0):
    if (inc == "boost/type_traits/is_contiguous.h"):
      result = "BoostAdapters"
    else:
      result = "Boost"
  elif (inc.find("tinyxml") == 0) or (inc == "otb_tinyxml.h"):
    result = "TinyXML"
  elif (inc.find("mapnik") == 0):
    result = "Mapnik"
  elif (inc.find("kml") == 0):
    result = "libkml"
  elif (inc.find("curl") == 0) or (inc == "otb_curl.h"):
    result = "Curl"
  elif (inc.find("msImageProcessor") == 0):
    result = "Edison"
  elif (inc.find("openjpeg") == 0) or inc.startswith("opj_"):
    result = "OpenJPEG"
  elif (inc.find("siftfast") == 0):
    result = "SiftFast"
  elif (inc.find("svm") == 0):
    result = "LibSVM"
  elif (inc.find("expat") >= 0):
    result = "Expat"
  elif ((inc.lower()).find("6s") >= 0):
    result = "6S"
  elif (inc.find("openthread") == 0) or inc.startswith("OpenThreads/"):
    result = "OpenThreads"
  elif (baseInc == "ConfigFile.h"):
    result = "ConfigFile"
  elif inc in ["QtCore","QtGui","QString","QObject"]:
    result = "Qt4"
  elif inc in ["geovalues.h"]:
    result = "GeoTIFF"
  elif inc in ["Python.h","lua.h","lualib.h","lauxlib.h"]:
    result = "SWIG"
  elif baseInc in sourceList:
    result = sourceList[baseInc]
  
  return result

def buildModularDep(otbDir,moduleList,sourceList):
  depList = {}
  for mod in moduleList.keys():
    dependance = {}
    for src in moduleList[mod]:
      srcFullPath = op.join(otbDir,src)
      srcIncludes = searchAllIncludes(srcFullPath)
      for inc in srcIncludes:
        res = analyseInclude(inc,sourceList)
        if res == "system":
          continue
        if (res in moduleList):
          if res == mod:
            continue
          if not dependance.has_key(res):
            dependance[res] = []
          dependance[res].append({"from":op.basename(src) , "to":inc})
        else:
          print "Unknown dependency : "+inc
    
    depList[mod] = dependance
  # Some adjustments
  for mod in depList:
    if mod == "OSSIM":
      if not "OpenThreads" in depList[mod]:
        depList[mod]["OpenThreads"] = []
  
  return depList

# def buildModularTestDep(otbDir,moduleList,testList):
#   depList = {}
#   for mod in moduleList.keys():
#     for src in testList[mod]:
#       srcFullPath = op.join(otbDir,src)
#       srcIncludes = searchAllIncludes(srcFullPath)
#       for inc in srcIncludes:
#         res = analyseInclude(inc,sourceList)
#         if res == "system":
#           continue
#         if (res in moduleList):
#           if res == mod:
#             continue
#           if not dependance.has_key(res):
#             dependance[res] = []
#           dependance[res].append({"from":op.basename(src) , "to":inc})
#         else:
#           print "Unknown dependency : "+inc
    
#     depList[mod] = dependance
#   # Some adjustments
#   for mod in depList:
#     if mod == "OSSIM":
#       if not "OpenThreads" in depList[mod]:
#         depList[mod]["OpenThreads"] = []
  
#   return depList

def cleanDepList(depList,fullDepList):
  # clean full dependencies : 
  # - if module 'a' depends on 'b' 'c' and 'd'
  # - if module 'b' depens on 'd'
  # - if 'b' and 'd' are clean
  #   -> then remove 'd' from 'a' dependency list
  # it will be considered as inherited from 'b'
  cleanDepList = {}
  for mod in depList.keys():
    cleanDepList[mod] = {}
    depListToRemove = []
    for dep1 in depList[mod]:
      for dep2 in depList[mod]:
        if dep2 == dep1:
          continue
        if not dep1 in fullDepList:
          continue
        if (dep2 in fullDepList[dep1]) and \
           (not dep2 in depListToRemove):
          depListToRemove.append(dep2)
    for dep in depList[mod]:
      if not dep in depListToRemove:
        cleanDepList[mod][dep] = 1
  return cleanDepList
  
def updateSourceList(path,varName,added,removed,fname="set"):  
  fd = open(path,'rb')
  newContent = []
  indent = "  "
  isInSetSrc = False
  for line in fd:
    cleanLine = line.strip(' \n\t\r')
    if isInSetSrc and line.count(')') == 1:
      # detect indentation
      pos = line.find(cleanLine)
      if indent != line[0:pos]:
        indent = line[0:pos]
      # append new entries
      for item in added:
        newContent.append(indent+item+"\n")
      isInSetSrc = False
    
    if isInSetSrc:
      if cleanLine in removed:
        continue
    
    if line.startswith(fname+"("+varName):
      isInSetSrc = True
    
    newContent.append(line)
  fd.close()
  
  fd = open(path,'wb')
  fd.writelines(newContent)
  fd.close()

def ParseTestCode(path):
  functions = []
  fd = open(path,'rb')
  #search_string1=" *\( *int +(itkNotUsed\()? *(/\*)? *(argc)? *(\*/)? *\)? *, *char *\*+ *(itkNotUsed\()? *(/\*)? *(argv)? *(\*/)? *\)? *(\[ *\])? *\)"
  search_string1=" *\( *int *[A-Za-z0-9_ /\*\(\)]*, *char *\*[A-Za-z0-9_ /\*\(\)\[\]]*\) *"
  regex1 = re.compile(search_string1)
  searcg_string2=" *int +"
  regex2 = re.compile(searcg_string2)
  searcg_string3=" *void +"
  regex3 = re.compile(searcg_string3)
  
  for line in fd:
    cleanline = (line.replace("\t"," ")).strip(" \n\r")
    if regex1.search(cleanline):
      # avoid commented lines
      if not re.match("^ *//",cleanline):
        name = regex3.sub('',regex2.sub('',regex1.sub('',cleanline)))
        functions.append(name)
  fd.close()  
  return functions

def updateTestDriver2(path,functions):
  fd = open(path,'rb')
  registered_tests = []
  indent = "  "
  content = []
  isInRegister = False

  search_string1=" *REGISTER_TEST *\( *";
  regex1 = re.compile(search_string1)

  for line in fd:
    cleanLine = line.strip(' \n\t\r')
    if regex1.match(cleanLine):
      name = re.sub(" *\) *;",'',regex1.sub('',cleanLine))
      registered_tests.append(name)

  fd.close()

  in_set = set(functions)
  cur_set = set(registered_tests)

  to_add = in_set - cur_set
  to_remove = cur_set - in_set

  if len(to_add) == 0 and len(to_remove) == 0:
    return False

  for f in to_remove:
    registered_tests.remove(f)
  registered_tests+=sorted(to_add)

  content.append("#include \"otbTestMain.h\"\n")
  content.append("void RegisterTests()\n")
  content.append("{\n")
  
  for t in registered_tests:
    content.append(indent+"REGISTER_TEST("+t+");\n")
  content.append("}\n")

  fd = open(path,'wb')
  fd.writelines(content)
  fd.close()
  
  return True
  
def updateTestDriver(path,added,removed):
  fd = open(path,'rb')
  newContent = []
  indent = "  "
  isInRegister = False
  previousLine = ""
  for line in fd:
    cleanLine = line.strip(' \n\t\r')
    if isInRegister and line.count('}') == 1:
      # append new entries
      for item in added:
        registerItem = item.replace(".cxx","")
        registerItem = "REGISTER_TEST("+registerItem+");"
        newContent.append(indent+registerItem+"\n")
      isInRegister = False
    
    if isInRegister:
      curSourceTest = cleanLine.replace("REGISTER_TEST(","")
      curSourceTest = curSourceTest.replace(");","")
      curSourceTest = curSourceTest+".cxx"
      if curSourceTest in removed:
        continue
    
    if line.count('{') and \
      (("RegisterTests()" in line) or ("RegisterTests()" in previousLine)):
      isInRegister = True
    
    previousLine = line
    newContent.append(line)
  fd.close()
  
  fd = open(path,'wb')
  fd.writelines(newContent)
  fd.close()

def setTargetLinkLibs(path,varName,depList):
  fd = open(path,'rb')
  newContent = []
  indent = "  "
  isInSetSrc = False
  for line in fd:
    cleanLine = line.strip(' \n\t\r')
    if line.startswith("target_link_libraries("+varName):
      isInSetSrc = True
    
    if not isInSetSrc:
      newContent.append(line)
    
    if isInSetSrc and line.count(')') == 1:
      # set target_link bloc
      newContent.append("target_link_libraries("+varName+"\n")
      for item in depList:
        newContent.append(indent+"${OTB"+item+"_LIBRARIES}\n")
      newContent.append(indent+")\n")
      isInSetSrc = False
    
  fd.close()
  
  fd = open(path,'wb')
  fd.writelines(newContent)
  fd.close()

def initializeSrcCMakeLists(path,modName):
  fd = open(path,'wb')
  fd.write("set(OTB"+modName+"_SRC\n")
  fd.write("  )\n")
  fd.write("\n")
  fd.write("add_library(OTB"+modName+" ${OTB"+modName+"_SRC})\n")
  fd.write("target_link_libraries(OTB"+modName+"\n")
  fd.write("# Fill with libraries from DEPENDS list\n")
  fd.write(")\n")
  fd.write("\n")
  fd.write("otb_module_target(OTB"+modName+")\n")
  fd.close()

def initializeTestCMakeLists(path,modName):
  fd = open(path,'wb')
  fd.write("otb_module_test()\n")
  fd.write("set(OTB"+modName+"Tests\n")
  fd.write("  otb"+modName+"TestDriver.cxx")
  fd.write("  )\n")
  fd.write("\n")
  fd.write("add_executable(otb"+modName+"TestDriver ${OTB"+modName+"Tests})\n")
  fd.write("target_link_libraries(otb"+modName+"TestDriver ${OTB"+modName+"-Test_LIBRARIES})\n")
  fd.write("otb_module_target_label(otb"+modName+"TestDriver)\n")
  fd.close()

def initializeAppCMakeLists(path,modName):
  fd = open(path,'wb')
  fd.write("set(OTB"+modName+"_LINK_LIBS\n")
  fd.write("  )\n")
  fd.write("\n")
  fd.close()

def initializeTestDriver(path):
  fd = open(path,'wb')
  fd.write("#include \"otbTestMain.h\"\n")
  fd.write("void RegisterTests()\n")
  fd.write("{\n")
  fd.write("}\n")
  fd.close()

def initializeOTBModuleCmake(path,modName):
  fd = open(path,'wb')
  fd.write("set(DOCUMENTATION \"TODO\")\n")
  fd.write("\n")
  fd.write("otb_module(OTB"+modName+"\n")
  fd.write("  DESCRIPTION\n")
  fd.write("    \"${DOCUMENTATION}\"\n")
  fd.write("  )\n")
  fd.close()

def initializeOTBModuleCMakeLists(path,modName,with_lib = False):
  fd = open(path,'wb')
  fd.write("project(OTB"+modName+")\n\n")
  
  if with_lib:
    fd.write("set(OTB"+modName+"_LIBRARIES OTB"+modName+")\n\n")

  fd.write("otb_module_impl()\n")
  fd.close()

def moveTestCode(srcPath,dstPath,testCode,testProp={}):
  
  # First, process destination CMakeLists.txt
  dst = open(dstPath,'rb')
  new_dst_content = dst.readlines()
  
  for test,test_body in testCode.iteritems():
    for line in test_body['code']:
      new_dst_content.append(line)
    if testProp.has_key(test):
      for prop in testProp[test]:
        new_dst_content.append(prop)
  dst.close()

  dst = open(dstPath,'w')
  dst.writelines(new_dst_content)
  dst.close()

  # Second, process source CMakeLists.txt

  src = open(srcPath,'rb')
  new_src_content = src.readlines()

  for test,test_body in testCode.iteritems():
    id = 0
    start = -1
    for line in new_src_content:
      if line == test_body['code'][0]:
        start = id
        break
      id+=1
    if start > 0:
      del new_src_content[start:start+len(test_body['code'])]
  
  for test,test_prop in testProp.iteritems():
    for prop in test_prop:
      id = 0
      start = -1
      for line in new_src_content:
        if line == prop:
          start = id
          break
        id+=1
      if start > 0:
        del new_src_content[start:start+1]
  
  src.close()

  src = open(srcPath,'w')
  src.writelines(new_src_content)
  src.close()

def moveAppBloc(srcPath,dstPath,srcName):
  src = open(srcPath,'rb')
  dst = open(dstPath,'ab')
  newContent = []
  tmpAppBloc = []
  appName = ""
  tmpAppName = ""
  isInOTBCreateApp = False
  blocFound = False
  for line in src:
    pos = line.find('#')
    cleanLine = line
    if pos >= 0:
      cleanLine=cleanLine[0:pos]
    cleanLine = cleanLine.strip(' \n\t\r')
    cleanLine = cleanLine.replace('\t',' ')
    
    # collapse multi-spaces
    sizeChanged = True
    while (sizeChanged):
      sizeBefore = len(cleanLine)
      cleanLine = cleanLine.replace('  ',' ')
      sizeAfter = len(cleanLine)
      if (sizeBefore == sizeAfter):
        sizeChanged = False
    
    if cleanLine.startswith('otb_create_application('):
      isInOTBCreateApp = True
    
    if isInOTBCreateApp:
      tmpAppBloc.append(line)
      words = cleanLine.split(' ')
      if srcName in words:
        blocFound = True
      if "NAME" in words:
        tmpAppName = words[words.index("NAME")+1]
    else:
      newContent.append(line)
    
    if isInOTBCreateApp and cleanLine.endswith(')'):
      if blocFound:
        appName = tmpAppName
        dst.write('\n')
        dst.writelines(tmpAppBloc)
      else:
        newContent += tmpAppBloc
      blocFound = False
      isInOTBCreateApp = False
      tmpAppBloc = []
      tmpAppName = ""
  
  src.close()
  dst.close()
  
  src = open(srcPath,'w')
  src.writelines(newContent)
  src.close()
  
  return appName

def extractAppTestBlocs(path,appName):
  res = {}
  newContent = []
  tmpAppBloc = []
  isInOTBTestApp = False
  blocFound = False
  testName = ""
  fd = open(path,'rb')
  for line in fd:
    pos = line.find('#')
    cleanLine = line
    if pos >= 0:
      cleanLine=cleanLine[0:pos]
    cleanLine = cleanLine.strip(' \n\t\r')
    cleanLine = cleanLine.replace('\t',' ')
    
    # collapse multi-spaces
    sizeChanged = True
    while (sizeChanged):
      sizeBefore = len(cleanLine)
      cleanLine = cleanLine.replace('  ',' ')
      sizeAfter = len(cleanLine)
      if (sizeBefore == sizeAfter):
        sizeChanged = False
    
    if cleanLine.startswith('otb_test_application('):
      isInOTBTestApp = True
    
    if isInOTBTestApp:
      tmpAppBloc.append(line)
      words = cleanLine.split(' ')
      if "APP" in words:
        curApp = words[words.index("APP")+1]
        if curApp in appName:
          blocFound = True
      if "NAME" in words:
        testName = words[words.index("NAME")+1]
    else:
      if line.startswith('#') and line.find(appName+" TESTS") >= 0:
        # skip this comment
        pass
      else:
        newContent.append(line)
    
    if isInOTBTestApp and cleanLine.endswith(')'):
      if blocFound:
        res[testName] = tmpAppBloc
      else:
        newContent += tmpAppBloc
      blocFound = False
      isInOTBTestApp = False
      testName = ""
      tmpAppBloc = []
  
  fd.close()
  
  fd = open(path,'w')
  fd.writelines(newContent)
  fd.close()
  
  return res

def getCyclicDep(mod,depList):
  paths = []
  max_iter = 1000
  it = 0

  for m in depList[mod]:
    if m == mod:
      return [m]
    paths.append([m])

  while it < max_iter:
    new_paths = []
    for path in paths:
      for m in depList[path[-1]]:
        if m == mod:
          return path+[m]
        new_paths.append(path+[m])
    paths = new_paths
    it+=1
    
    return []
  
def ModuleHasLibrary(group,module,otb_root):
  if op.isdir(op.join(otb_root,"Modules",group,module,"src")):
    return True
  else:
    return False

def UpdateLibraryExport(group,module,otb_root):
  has_library =  ModuleHasLibrary(group,module,otb_root)

  cmake = op.join(otb_root,"Modules",group,module,"CMakeLists.txt")

  fd = open(cmake,'rb')
  lines = fd.readlines()
  fd.close()

  has_library_export = False
    
  for line in lines:
    if line.startswith("set(OTB"+module):
      has_library_export = True
  
  if not has_library_export and has_library:

    out_lines = []
      
    for line in lines:
      cleanline = line.strip(' \n\t\r')
      if cleanline.startswith("otb_module_impl()"):
        out_lines.append("\nset(OTB"+module+"_LIBRARIES OTB"+module+")\n\n")
      out_lines.append(line)
    fd = open(cmake,'w')
    fd.writelines(out_lines)
    fd.close()
    return True

  elif has_library_export and not has_library:
    out_lines = []
    for line in lines:
      if not line.find("set(OTB"+module+"_LIBRARIES"):
        out_lines.append(line)
    fd = open(cmake,'w')
    fd.writelines(out_lines)
    fd.close()
    return True

  return False

def CheckTestDriverInTestCMakeLists(path,module):
  fd = open(path,'rb')
  lines = fd.readlines()
  fd.close()

  out_lines = []

  search_string = "otb[A-Za-z0-9]+TestDriver"

  patched = False

  for line in lines:
    if re.search(search_string,line):
      out_lines.append(re.sub(search_string,"otb"+module+"TestDriver",line))
      if line.count("otb"+module+"TestDriver") == 0:
        patched = True
    else:
      out_lines.append(line)

  fd = open(path,'wb')
  fd.writelines(out_lines)
  fd.close()

  return patched

def removeApplicationSource(path,srcName):
  appName = ""
  fd = open(path,'rb')
  newContent = []
  indent = "  "
  isInSetSrc = False
  for line in fd:
    cleanLine = line.strip(' \n\t\r')
    if line.startswith("target_link_libraries("+varName):
      isInSetSrc = True
    
    if not isInSetSrc:
      newContent.append(line)
    
    if isInSetSrc and line.count(')') == 1:
      # set target_link bloc
      newContent.append("target_link_libraries("+varName+"\n")
      for item in depList:
        newContent.append(indent+"${OTB"+item+"_LIBRARIES}\n")
      newContent.append(indent+")\n")
      isInSetSrc = False
    
  fd.close()
  
  fd = open(path,'wb')
  fd.writelines(newContent)
  fd.close()
  return appName
  
