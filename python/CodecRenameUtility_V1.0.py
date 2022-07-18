import os
from ffprobe3 import FFProbe
import datetime
from os import rename
import re

VersionNumber = "1.1"

print("CodecRenameUtility Version " + VersionNumber)
print("Developed by DTA.")
program = input('[add] or [remove] codec?')

if program == 'add':
    print('Rename operation started: ' + str(datetime.datetime.now()))

    TotalCount = 0

    path = input('Enter Path: ')

    VideoExtensions = [".mp4", ".mkv", ".avi", ".m4v", ".mpg", ".divx", ".mov"]

    h265Count = 0

    h264Count = 0

    xvidCount = 0

    mpeg4Count = 0

    msmpeg4v3Count = 0

    errorcount = 0

    files = []
    current = 0
if program == 'add':
    while True:
        try:
            for r, d, f in sorted(os.walk(path, topdown=True)):
                for file in f:
                    if '[' not in file:
                        for ex in VideoExtensions:
                            if ex in file:
                                current = os.path.join(r, file)
                                TotalCount += 1
                                metadata = FFProbe(str(current))
                                for stream in metadata.streams:

                                    if '{}'.format(stream.codec()) == 'hevc':
                                        h265Count += 1
                                        rename(current, current[0:-4] + ' [h265]' + current[-4:])
                                        print('New Name: ' + current[0:-4] + ' [h265]' + current[-4:])

                                    if '{}'.format(stream.codec()) == 'h264':
                                        h264Count += 1
                                        rename(current, current[0:-4] + ' [h264]' + current[-4:])
                                        print('New Name: ' + current[0:-4] + ' [h264]' + current[-4:])

                                    if '{}'.format(stream.codec()) == 'xvid':
                                        xvidCount += 1
                                        rename(current, current[0:-4] + ' [xvid]' + current[-4:])
                                        print('New Name: ' + current[0:-4] + ' [xvid]' + current[-4:])

                                    if '{}'.format(stream.codec()) == 'mpeg4':
                                        mpeg4Count += 1
                                        rename(current, current[0:-4] + ' [mpeg4]' + current[-4:])
                                        print('New Name: ' + current[0:-4] + ' [mpeg4]' + current[-4:])

                                    if '{}'.format(stream.codec()) == ' msmpeg4v3':
                                        msmpeg4v3Count += 1
                                        rename(current, current[0:-4] + ' [msmpeg4v3]' + current[-4:])
                                        print('New Name: ' + current[0:-4] + ' [msmpeg4v3]' + current[-4:])
        except:
            errorcount += 1
            print('**ERROR: ' + str(current))
            rename(current, current[0:-4] + ' [ERROR]' + current[-4:])
            print('**Offending File Marked')
            pass
        else:
            print('-' * 20)
            if h265Count != 0:
                print('h265: ' + str(h265Count))
            if h264Count != 0:
                print('h264: ' + str(h264Count))
            if xvidCount != 0:
                print('XVID: ' + str(xvidCount))
            if mpeg4Count != 0:
                print('mpeg4: ' + str(mpeg4Count))
            if msmpeg4v3Count != 0:
                print('msmpeg4v3: ' + str(msmpeg4v3Count))
                print('-' * 20)
            if errorcount != 0:
                print('Errors: ' + str(errorcount))
                print('-' * 20)
            if TotalCount == 0:
                print('*****No Changes Made*****')
                print('-' * 20)

            print('-' * 20)
            if TotalCount != 0:
                print('Total Renamed: ' + str(TotalCount))
                print('-' * 20)
            print('Rename operation finished: ' + str(datetime.datetime.now()))
            print('-' * 20)
            break

if program == 'remove':

    print('Rename operation started: ' + str(datetime.datetime.now()))
    TotalCount = 0

    path = input('Enter Path: ')

    CurrentName = 0

    for r, d, f in sorted(os.walk(path, topdown=True)):
        for file in f:
            CurrentName = os.path.join(r, file)
            BaseName = re.sub("[[@*&?].*[]@*&?]", "", CurrentName)
            if '[' in file:
                rename(CurrentName, BaseName)
                TotalCount += 1
                FinalName = BaseName[:-5] + BaseName[-4:]
                rename(BaseName, FinalName)
                print("New Name: " + str(FinalName))

    print("Files Renamed: " + str(TotalCount))
    if TotalCount == 0:
        print('*****No Changes Made*****')

else:
	print("Invalid input, you invalid.")
