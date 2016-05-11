diskpart.exe /s c:\batch\xp\raid.txt

start /wait cmd /q /c format W: /fs:ntfs /v:RAID /a:4096 /q /y
