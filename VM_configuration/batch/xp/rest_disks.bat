diskpart.exe /s c:\batch\xp\rest_disks.txt

start /wait cmd /q /c format R: /fs:ntfs /v:Repo /a:4096 /q /y
start /wait cmd /q /c format I: /fs:ntfs /v:mirrored /a:4096 /q /y
start /wait cmd /q /c format K: /fs:ntfs /v:spanned /a:4096 /q /y
start /wait cmd /q /c format L: /fs:ntfs /v:striped /a:4096 /q /y
start /wait cmd /q /c format M: /fs:ntfs /v:simple /a:4096 /q /y

diskpart.exe /s c:\batch\xp\rest_disks2.txt
start /wait cmd /q /c format N: /fs:ntfs /a:4096 /q /y
start /wait cmd /q /c format O: /fs:ntfs /a:4096 /q /y
start /wait cmd /q /c format P: /fs:ntfs /a:4096 /q /y
start /wait cmd /q /c format Q: /fs:ntfs /a:4096 /q /y
start /wait cmd /q /c format S: /fs:ntfs /a:4096 /q /y


diskpart.exe /s c:\batch\xp\rest_disks3.txt