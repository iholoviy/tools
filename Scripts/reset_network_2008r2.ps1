#Get-WmiObject -Class Win32_NetworkAdapter | Format-Table `
#Name, NetEnabled, NetConnectionStatus, DeviceId -auto
$Nic = Get-WmiObject win32_networkadapter -computerName LocalHost `
-filter "DeviceId = 7"
$Nic.disable()
Start-Sleep -Seconds 420
$Nic.enable()