$StartTime = Get-Date
choco upgrade all -y 
$Desktops = "$env:PUBLIC\Desktop", "$env:USERPROFILE\Desktop"
$ICONSTOREMOVE=$($Desktops | Get-ChildItem -Filter "*.lnk" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $StartTime })
$Desktops | Get-ChildItem -Filter "*.lnk" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $StartTime } | Remove-Item