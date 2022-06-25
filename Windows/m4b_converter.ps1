### Automated Script for Merging mp3 audiobooks into a m4b 
### REQUIRES FFMPEG IN $PATH ###
### if it's not in $path, then you could create a variable $ffmpeg = <path>\<to>\<ffmpeg.exe> and then add a $ before ffmpeg in line 50 ###

## removing brackets from directories and file names (used in mp3tag automatic renaming) ##
(Get-ChildItem -Directory -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }

## Collects all directories and iterates through them.
#$gathering   = "C:\temp"
$directories = Get-ChildItem -Recurse -Directory 
ForEach ($directory in $directories)
{
    #Changes to the each directory in turn 
    $rtfm = "$($directory.FullName)"    
    cd "$rtfm"
    
    ##DEBUG STATEMENT##
    ## Write-Host $rtfm ##
    
    #checks for mp3 files and adds the count of mp3 files to use to see if any exist
    $results    = Get-ChildItem -recurse -depth 1 | Where-Object { ".mp3" -contains $_.extension}
    $count      = $results.count

    ##DEBUG STATEMENT##
    ## Get-ChildItem -recurse ##
    ## Write-Host $count ##
    
    #If count is greater than 0 then it enters the if statement, otherwise it goes into the next directory
    if ($count -gt 0)
    {
        ##DEBUG STATEMENT##
        ## Write-Host "Made it into if loop" ##

        #Variables used, both a filename for combined mp3 files and for the finalized m4b file
        $filename   = $directory.name+".mp3"
        $newname    = $directory.name+".m4b"
        
        ##DEBUG STATEMENTS##
        ## $folder     = $directory.name ##
        ## Write-Host $folder   ##
        ## Write-Host $filename ##
        ## Write-Host $newname  ##
        ## Write-Host $PWD      ##

        #Calls command prompt to copy all files into a single file
        cmd /c copy /b *.mp3 "$($filename)"

        #
        ffmpeg  -i "$($filename)" -c:a aac -vn "$($newname)"
        #move-item $newname $gathering
        Remove-Item *.mp3 
    }
}

<#Other AudioBook Tools #>
<#MP3Tag - used to tag the audiobooks - https://www.mp3tag.de/en/ #>
<#MP3Tag Audible Audobook tag scrapper - https://github.com/seanap/Audible.com-Search-by-Album #>
<#MP3Tag Goodreads book tag scrapper (For when a book isn't in audible) - https://community.mp3tag.de/t/ws-goodreads-for-audiobooks/52147 #>
<#MP3Tag Tag -> Filename <Audiobook Shared Folder>\<Path>\%albumartist%\%series%\[ '['%series% %series-part%,2']']%album%\['['%series% %series-part%,2']' ]%album% #>
<#                                                  [path]\[Author of book]\[Series Name]\[Series Name - Part ##] [Book Title]\[Series Name - Part ##] Album.m4b #> 