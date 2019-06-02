import sys
import fileinput

if (len(sys.argv)== 4):
    filename= sys.argv[1]
    originalstr= sys.argv[2]
    finalstr = sys.argv[3]

    finalstr = finalstr.replace("\\t", "    ")
    finalstrArray = finalstr.split('\\n')
    
    with open (filename, "r") as fileRead:
        lstLines = fileRead.readlines()
        for index, item in enumerate(lstLines):
             if (item.find(originalstr)>=0):
                lstLines[index] = item.replace(originalstr,finalstrArray[0])
                if (len(finalstrArray)> 1):
                    offset =1
                    for nextString in finalstrArray[1:]:
                        lstLines.insert(index+offset, nextString)
                        lstLines.insert(index+offset+1, '\n')
                        offset = offset +2
                break
        next
    outF = open(filename, "w")
    outF.writelines(lstLines)
    outF.close()
