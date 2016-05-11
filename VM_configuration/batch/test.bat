@ECHO off
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

FOR /f "tokens=1,2* delims=." %%a IN ('ver') DO (

SET WVer=%%a
SET WVer=!WVer:~-1!
SET WVer=!WVer!.%%b.%%c
SET WVer=!WVer:]=!
)

ECHO Current Windows version is %WVer%

set result=false
if %WVer%==5.1.2600 set result=true
if %WVer%==5.2.3790 set result=true
if "%result%" == "true" (
    GOTO  XPor2003
)
if "%result%" == "false" (
 GOTO  nope
)

:XPor2003
echo "XP or 2003"
GOTO prerequsities_for_XP

:nope
::echo "neither XP or 2003"
GOTO prerequsities_for_others

:prerequsities_for_XP
::Password never expires
echo Setting passwords for user Administrator and AppAssure...
net user administrator 123asdQ /active:yes  /add /passwordreq:yes 2>nul
net user administrator 123asdQ >nul
WMIC USERACCOUNT WHERE "Name='Administrator'" SET PasswordExpires=FALSE >nul
net localgroup "Administrators" /add Administrator 2>nul

net user appassure 123asdQ /active:yes  /add /passwordreq:yes 2>nul
WMIC USERACCOUNT WHERE "Name='appassure'" SET PasswordExpires=FALSE >nul
net localgroup "Administrators" /add appassure 2>nul

::Disable Automatic updates
echo Disabling Automatic updates... 
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 1 /f  >nul

::To enable remote desktop.
echo Enabling RPD access.. 
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f >nul
net localgroup "Remote Desktop Users" administrator /ADD >nul
net localgroup "Remote Desktop Users" appassure /ADD >nul

::enable ping
echo Enabling ping...
netsh firewall set icmpsetting 8 enable >nul

::enable num lock
echo Enabling Num Lock...
reg add "HKEY_CURRENT_USER\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2 /f >nul

::Disable sleep mode
echo Disabling sleep mode... 
POWERCFG /CREATE Custom1 >nul
POWERCFG /CHANGE Custom1 /monitor-timeout-ac 0 >nul
POWERCFG /CHANGE Custom1 /monitor-timeout-dc 0 >nul
POWERCFG /CHANGE Custom1 /disk-timeout-ac 0 >nul
POWERCFG /CHANGE Custom1 /disk-timeout-dc 0 >nul
POWERCFG /CHANGE Custom1 /standby-timeout-ac 0 >nul
POWERCFG /CHANGE Custom1 /standby-timeout-dc 0 >nul
POWERCFG /CHANGE Custom1 /hibernate-timeout-ac 0 >nul
POWERCFG /CHANGE Custom1 /hibernate-timeout-dc 00 >nul
POWERCFG /CHANGE Custom1 /processor-throttle-ac ADAPTIVE >nul
POWERCFG /CHANGE Custom1 /processor-throttle-dc ADAPTIVE >nul
POWERCFG /SETACTIVE Custom1 >nul

::Turn off Screen saver
echo Disabling Screen saver...
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveActive" /t REG_SZ /d "0" /f >nul

::Add Windows Management Instrumentation and RDP to Windows Firewall exceptions
echo Adding Windows Management Instrumentation and RDP to Windows Firewall exceptions... 
netsh firewall set service remoteadmin enable  >nul 
netsh firewall set service remoteadmin enable subnet >nul
netsh firewall set service remoteadmin enable custom  >nul
netsh firewall set service remotedesktop enable >nul

::start WMI-related services 
echo starting WMI-related services... 
sc config "EventSystem" start= auto 2>nul
sc start "EventSystem" 2>nul

sc config "RasAuto" start= auto  2>nul
sc start "RasAuto" 2 >nul

sc config "RasMan" start= auto 2>nul
sc start "RasMan" 2>nul

sc config "RpcSs" start= auto 2>nul
sc start "RpcSs" 2>nul

sc config "RpcLocator" start= auto 2>nul
sc start "RpcLocator" 2>nul

sc config "RemoteRegistry" start= auto 2>nul
sc start "RemoteRegistry" 2>nul

sc config "lanmanserver" start= auto  2>nul
sc start "lanmanserver" 2>nul

sc config "wmimgmt" start= auto  2>nul
sc start "wmimgmt" 2>nul

sc config "wmi" start= auto 2>nul
sc start "wmi" 2>nul

sc config "WmiApSrv" start= auto 2>nul
sc start "WmiApSrv" 2>nul

sc config "lanmanworkstation" start= auto 2>nul
sc start "lanmanworkstation" 2>nul

::enable DCOM
echo enabling DCOM... 
reg add HKLM\Software\Microsoft\OLE /v EnableDCOM /t REG_SZ /d "Y" /f >nul

:: Network access: Sharing and security model for local accounts. Select Classic - local users authenticate as themselves, and restart computer.  WMI is configured. 
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa /v forceguest /t REG_DWORD /d "1" /f >nul

:: show hidden and system files
echo Enabling dispay hidden and system files...
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d 1 /f >nul
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f >nul


@echo off
SET /P PCNAME=Please enter new hostname: 
wmic computersystem where name="%COMPUTERNAME%" call rename name="%PCNAME%" >nul
echo New hostname is %PCNAME%

@echo off 
netsh interface set interface name="Local Area Connection 2" newname="Local Area Connection 100" 2>nul
netsh interface set interface name="Local Area Connection 3" newname="Local Area Connection 100" 2>nul
netsh interface set interface name="Ethernet" newname="Local Area Connection 100" 2>nul
netsh interface set interface name="Ethernet0" newname="Local Area Connection 100" 2>nul
echo Please enter Static IP Address Information 
echo Static IP Address: 
set /p IP_Addr=

echo Setting Static IP Information... 
netsh interface ip set address name="Local Area Connection" static %IP_Addr% 255.255.0.0 10.10.10.99  1 >nul
netsh interface ip set dns "Local Area Connection" static 10.10.10.23 >nul
netsh interface ip add dns "Local Area Connection" 10.10.10.10 >nul

ECHO Here are the new settings for %computername%: 
netsh int ip show config

echo Would you like to create a volumes for databases (Y/N)?
:choice 
SET /P C=[Y,N]? 
for %%? in (Y) do if /I "%C%"=="%%?" goto Diskpart_xp 
for %%? in (N) do if /I "%C%"=="%%?" goto choice1 

:Diskpart_xp
echo Creating volumes...
diskpart.exe /s c:\batch\xp\script.txt
start /wait cmd /q /c format e: /fs:ntfs /v:exchange /a:4096 /q /y
start /wait cmd /q /c format f: /fs:ntfs /v:SG12Logs /a:512 /q /y
start /wait cmd /q /c format g: /fs:ntfs /v:SG12 /a:8192 /q /y
start /wait cmd /q /c mkdir f:\StorageGroup3
start /wait cmd /q /c mkdir g:\StorageGroup3
diskpart.exe /s c:\batch\xp\script2.txt
start /wait cmd  /q /c format f:\StorageGroup3 /fs:ntfs /v:SG3Logs /a:64K /q /y
start /wait cmd  /q /c format g:\StorageGroup3 /fs:ntfs /v:SG3 /a:32K /q /y
diskpart.exe /s c:\batch\xp\script3.txt
start /wait cmd  /q /c format h: /fs:ntfs  /a:16K /q /y
start /wait cmd /q /c mkdir h:\Data\SG4
start /wait cmd /q /c mkdir h:\Logs\SG4
diskpart.exe /s c:\batch\xp\script4.txt
start /wait cmd  /q /c format h:\Logs\SG4 /fs:ntfs /v:SG4Logs /a:2048 /q /y
start /wait cmd  /q /c format h:\Data\SG4 /fs:ntfs /v:SG4Logs /a:1024 /q /y

:choice1
echo Reboot is required. Reboot the machine (Y/N)?
SET /P C=[Y,N]? >nul
for %%? in (Y) do if /I "%C%"=="%%?" goto reboot_xp 
for %%? in (N) do if /I "%C%"=="%%?" goto end 

:reboot_xp
shutdown -r -f -t 0
GOTO :EXIT

:prerequsities_for_others
@echo off 
::Password never expires
echo Setting passwords for user Administrator and AppAssure...
net user administrator /active:yes >nul
net user administrator  123asdQ >nul
WMIC USERACCOUNT WHERE "Name='Administrator'" SET PasswordExpires=FALSE >nul
net localgroup "Administrators" administrator /ADD >nul

net user appassure /add /active:yes >nul
net user appassure  123asdQ >nul
WMIC USERACCOUNT WHERE "Name='appassure'" SET PasswordExpires=FALSE >nul
net localgroup "Administrators" appassure /ADD >nul

::disable uac
echo Disabling UAC...
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f >nul

::Do not start server manager automatically at logon
echo Disabling automatic start of server manager at logon...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager" /v DoNotOpenServerManagerAtLogon /t  REG_DWORD /d 1 /f >nul

::Disable Automatic updates
echo Disabling Automatic updates... 
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 1 /f  >nul

::To enable remote desktop.
echo Enabling RPD access.. 
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f >nul
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f >nul
net localgroup "Remote Desktop Users" administrator /ADD >nul
net localgroup "Remote Desktop Users" appassure /ADD >nul

::enable ping
echo Enabling ping...
netsh advfirewall firewall add rule name="All ICMP V4" dir=in action=allow protocol=icmpv4 >nul

::enable num lock
echo Enabling Num Lock...
reg add "HKEY_CURRENT_USER\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2 /f >nul

::Disable sleep mode
echo Disabling sleep mode... 
powercfg.exe -change -monitor-timeout-ac 0 >nul
powercfg.exe -change -disk-timeout-ac 0 >nul
powercfg.exe -change -standby-timeout-ac 0 >nul
powercfg.exe -change -hibernate-timeout-ac 0 >nul

::Turn off Screen saver
echo Disabling Screen saver... 
REG ADD "HKCU\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d 0 /f >nul
 
::Add Windows Management Instrumentation and RDP to Windows Firewall exceptions
echo Adding Windows Management Instrumentation and RDP to Windows Firewall exceptions... 
netsh advfirewall firewall set rule group="windows management instrumentation (wmi)" new enable=yes >nul
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes >nul

:: disables IE ESC for Admins and for users
echo Disabling IE ESC for Admins and for users...
REG ADD "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" /v IsInstalled /t REG_DWORD /d 00000000 /f >nul
REG ADD "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /v IsInstalled /t REG_DWORD /d 00000000 /f >nul

:: show hidden and system files
echo Enabling dispay hidden and system files...
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d 1 /f >nul
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f >nul


@echo off
SET /P PCNAME=Please enter new hostname: 
wmic computersystem where name="%COMPUTERNAME%" call rename name="%PCNAME%" >nul
echo New hostname is %PCNAME%

@echo off
netsh interface set interface name="Local Area Connection 2" newname="Local Area Connection 100" 2>nul
netsh interface set interface name="Local Area Connection 3" newname="Local Area Connection 100" 2>nul
netsh interface set interface name="Ethernet" newname="Local Area Connection 100" 2>nul
netsh interface set interface name="Ethernet0" newname="Local Area Connection 100" 2>nul
echo Please enter Static IP Address Information 
echo Static IP Address: 
set /p IP_Addr=

echo Setting Static IP Information... 
netsh interface ip set address name="Local Area Connection" source=static addr=%IP_Addr% mask=255.255.0.0 gateway=10.10.10.99  >nul
netsh interface ip set dns "Local Area Connection" static 10.10.10.23 >nul
netsh interface ip add dns "Local Area Connection" 10.10.10.10 >nul

ECHO Here are the new settings for %computername%: 
netsh int ip show config

pause 

echo Would you like to create a volumes for databases (Y/N)?
SET /P C=[Y,N]? 
for %%? in (Y) do if /I "%C%"=="%%?" goto Diskpart 
for %%? in (N) do if /I "%C%"=="%%?" goto choice2 

:Diskpart
echo Creating volumes...
diskpart.exe /s c:\batch\script.txt
start cmd /q /c mkdir f:\StorageGroup3
start cmd /q /c mkdir g:\StorageGroup3
diskpart.exe /s c:\batch\script2.txt
start cmd /q /c mkdir h:\Data\SG4
start cmd /q /c mkdir h:\Logs\SG4
diskpart.exe /s c:\batch\script3.txt

:choice2
echo Reboot is required. Reboot the machine (Y/N)?
SET /P C=[Y,N]? >nul
for %%? in (Y) do if /I "%C%"=="%%?" goto reboot
for %%? in (N) do if /I "%C%"=="%%?" goto end 

:reboot
shutdown /r /f /t 0
GOTO :EXIT

:end
echo Done. Please reboot you machine manually.
pause
EXIT