$services=  Get-Service | Where-Object {$_.Name -like "AppAssure*" -or $_.Name -like "RapidRecovery*"} | select -expand name
Write-host "Stopping services..."
foreach ($service in $services)
{
    do
        {
               $checkService = Get-Service $service -ErrorAction SilentlyContinue
               $serviceStatus = $checkService.status
       
               if($serviceStatus -eq "Running")
               {
                                   Stop-Service $service
               }
       
               Sleep -s 1
        } until($serviceStatus -eq "Stopped")
    }


Set-ItemProperty -Path HKLM:\SOFTWARE\AppRecovery\Core\LicenseInfo -Name GroupKey -Value "AMZY9-7AFJG-LVZ93-96V47-K3VBA-86XV9"

[xml] $CoreServiceXml = Get-Content "C:\Program Files\AppRecovery\Core\CoreService\Core.Service.exe.config"
$CoreServiceXml.configuration.'system.serviceModel'.client.endpoint.address="http://testlp.licenseportal.co:81/PhoneHome"
$nodeToRemove=$CoreServiceXml.configuration.'system.serviceModel'.bindings.webHttpBinding.binding.SelectSingleNode("security")
$nodeToRemove
$CoreServiceXml.configuration.'system.serviceModel'.bindings.webHttpBinding.binding.RemoveChild($nodeToRemove)
$CoreServiceXml.Save("C:\Program Files\AppRecovery\Core\CoreService\Core.Service.exe.config")

[xml] $PortalPluginXml = Get-Content "C:\Program Files\AppRecovery\Core\CoreService\RRPortal.PortalPlugin.exe.Config"
$RRPortalUrl=$PortalPluginxml.configuration.appSettings.add | where {$_.key -eq 'RRPortalUrl'}
$RRPortalUrl.value="https://rrportal.licenseportal.co:443/"
$PortalPluginXml.Save("C:\Program Files\AppRecovery\Core\CoreService\RRPortal.PortalPlugin.exe.Config")





$services=  Get-Service | Where-Object {$_.Name -like "AppAssure*" -or $_.Name -like "RapidRecovery*"} | select -expand name
Write-host "Starting services..."
foreach ($service in $services)
{
    do
        {
               $checkService = Get-Service $service -ErrorAction SilentlyContinue
               $serviceStatus = $checkService.status
       
               if($serviceStatus -eq "Stopped")
               {
                                   Start-Service $service
               }
       
               Sleep -s 1
        } until($serviceStatus -eq "Running")
    }


    New-Repository -Name repo -Size 99GB -DataPath f:\repo\data -MetadataPath f:\repo\metadata
    Start-Protect -Repository repo -AgentName $env:computername -AgentUserName administrator -AgentPassword 123asdQ -Volumes "e:"
    New-VMVirtualStandby -ProtectedServer $env:computername -TargetPath c:\export -VMName $env:computername -Version 11 -UseSourceRam
    
