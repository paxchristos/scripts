function GenerateM3U {
    param(
        [System.IO.DirectoryInfo] $directory,
        [string] $playlistFileName = "",
        [string] $pattern = "*.mp3"
    )

    # make sure we add m3u as an extension
    if ( "$playlistFileName" -eq "" ) {
        $playlistFileName = $directory.Name + ".m3u"
    }
    elseif ( ! $playlistFileName.EndsWith("m3u") ) {
        $playlistFileName = "$playlistFileName.m3u"
    }

    # store relative paths in the same directory
    if ( ! [System.IO.Path]::IsPathRooted($playlistFileName) ) {
        $playlistFileName = Join-Path -Path $directory -ChildPath $playlistFileName
    }

    # remove old file
    if ( Test-Path $playlistFileName -PathType Leaf ) {
        Remove-Item $playlistFileName
    }

    # only read mp3 files
    if ( ! $pattern.EndsWith(".mp3") ) {
        $pattern = "$pattern*.mp3"
    }

    # write m3u
    $directory.GetFiles($pattern) |
        ForEach-Object { $_.Name } | 
        Sort-Object |
        Out-File -Encoding UTF8 -FilePath $playlistFileName
}

<# linux code#>
<#
import re

chapters = list()

with open('chapters.txt', 'r') as f:
   for line in f:
      x = re.match(r"(\d):(\d{2}):(\d{2}) (.*)", line)
      hrs = int(x.group(1))
      mins = int(x.group(2))
      secs = int(x.group(3))
      title = x.group(4)

      minutes = (hrs * 60) + mins
      seconds = secs + (minutes * 60)
      timestamp = (seconds * 1000)
      chap = {
         "title": title,
         "startTime": timestamp
      }
      chapters.append(chap)

text = ""

for i in range(len(chapters)-1):
   chap = chapters[i]
   title = chap['title']
   start = chap['startTime']
   end = chapters[i+1]['startTime']-1
   text += f"""
[CHAPTER]
TIMEBASE=1/1000
START={start}
END={end}
title={title}
"""


with open("FFMETADATAFILE", "a") as myfile:
    myfile.write(text)#>

<#Get runtime#>

<#$path = 'M:\Musikk\awesome_song.mp3'
$shell = New-Object -COMObject Shell.Application
$folder = Split-Path $path
$file = Split-Path $path -Leaf
$shellfolder = $shell.Namespace($folder)
$shellfile = $shellfolder.ParseName($file)

write-host $shellfolder.GetDetailsOf($shellfile, 27); #>