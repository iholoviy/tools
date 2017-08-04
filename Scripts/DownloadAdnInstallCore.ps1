Write-Host "Downloading Core to C:\installers"
if ((Test-Path c:\installers) -eq 0)
{
mkdir c:\installers
}

wget http://iholoviy.s3.amazonaws.com/Core-X64-6.1.1.137.exe -OutFile c:\installers\Core-X64-6.1.1.137.exe
$arguments = "licensekey=DGJA9-74VHF-23215-121GB-VCA11-BXX4A /silent" 
start-process c:\installers\Core-X64-6.1.1.137.exe -ArgumentList $arguments