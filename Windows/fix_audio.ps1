[string[]]$Files = Get-Content -Path 'C:\temp\files.txt'

foreach ($file in $Files)
{
    mkvpropedit.exe "$file" --edit track:a1 --set flag-default=0 --edit track:a3 --set flag-default=1
}