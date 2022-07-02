### Scripts for Windows
#### MKV Scripts

If the filename starts with **Remove_** is used for removing a track from all MKVs in a folder and saving the result
If the filename starts with **Remove-** is used for removing Intro(s) from all MKVs in a folder and saving the result

**Dual_audio.ps1** is used to merge matching mkv and mka files in a folder
**merge_srt.ps1** is used to merge matching mkv and srt files (along with .en.srt files) in a folder

**transcode-** is used to transcode all video files (mkv, mp4, wmv, avi, divx, mpg, m4v) in a folder from original codec to h265 using the bitrates setup at the beginning of the file. If a file is less than or equal to 3/4 of the chosen bitrate, then it uses 3/4 of the bitrate of the file

#### AudioBook Scripts
**m4b_converter.ps1** is used to convert all mp3 audiobooks to m4b (aac). It works recursively through a directory, so it can be used at top level and work through *ALL* AudioBooks.

### Scripts for Linux
#### MKV Scripts

**(Broken)** scripts are just that, broken

If the filename starts with **Remove_** is used for removing a track from all MKVs in a folder and saving the result
If the filename starts with **Remove-** is used for removing Intro(s) from all MKVs in a folder and saving the result

**Dual_audio.sh** is used to merge matching mkv and mka files in a folder
**Dual_audio_with_transcode.sh** is used to merge matching mkv and mka files in a folder then transcodes the resulting mkv into h265 with preferred settings

**fix-audio-ja.sh** is used to set track 2 to japanese (used because some anime mkvs had bad lang data)

**transcode-** is used to transcode all video files (mkv, mp4, wmv, avi, divx, mpg, m4v) in a folder from original codec to h265 using the bitrates setup at the beginning of the file. If a file is less than or equal to 3/4 of the chosen bitrate, then it uses 3/4 of the bitrate of the file

**remux.sh** remuxes containers from mp4 to mkv

**temp.sh** was used as a scratch file for testing script ideas