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

Write-host "Deleting registry hive..."
Remove-Item -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\AppRecovery' -Recurse


Write-host "Deleting AppAssure and Dell certificates..."
$certs=Get-Childitem cert:CurrentUser -Recurse  | Where-Object {$_.Subject -like "*AppRecovery*" -or $_.Subject -like "*Dell*"  } | Remove-Item
$version=Get-WmiObject -Class Win32_Product | Where-object {$_.Name -eq "AppRecovery Core"} | foreach {$_.Version}


if ($version -eq "6.0.2.144")
{
Write-Host "Downloading P-1897 and P-1859 to C:\"
wget https://s3.amazonaws.com/appassure_patches/P-1897/P-1897.msi -OutFile c:\P-1897.msi
wget https://s3.amazonaws.com/appassure_patches/P-1859/P-1859.msi -OutFile c:\P-1859.msi
}

if ($version -eq "6.0.1.609")
{
Write-Host "Downloading P-1957 and P-1898 to C:\"
wget https://s3.amazonaws.com/appassure_patches/P-1957/P-1957.msi -OutFile c:\P-1957.msi
wget https://s3.amazonaws.com/appassure_patches/P-1898/P-1898.msi -OutFile c:\P-1898.msi
}

elseIf ($version -eq "5.4.3.106")
{
Write-Host "Downloading P-1612 and P-1899 to C:\"
wget https://s3.amazonaws.com/appassure_patches/P-1612/P-1612.msi -OutFile c:\P-1612.msi
wget https://s3.amazonaws.com/appassure_patches/P-1899/P-1899.msi -OutFile c:\P-1899.msi
}

elseIf  ($version -eq "6.0.2.177")
{
Write-Host "Downloading P-1918 and P-1945 to C:\"
wget https://s3.amazonaws.com/appassure_patches/P-1918/P-1918.msi -OutFile c:\P-1918.msi
wget https://s3.amazonaws.com/appassure_patches/P-1945/P-1945.msi -OutFile c:\P-1945.msi
}

elseIf  ($version -eq "6.1.0.645")
{
Write-Host "Downloading P-1986 to C:\"
wget https://s3.amazonaws.com/appassure_patches/P-1986/P-1986.msi -OutFile c:\P-1986.msi
}

elseIf  ($version -eq "6.1.0.653")
{
Write-Host "Downloading P-2013 to C:\"
wget https://s3.amazonaws.com/appassure_patches/P-2013/P-2013.msi -OutFile c:\P-2013.msi
}

elseIf  ($version -eq "6.1.1.137")
{
Write-Host "Downloading P-2025 to C:\"
wget https://s3.amazonaws.com/appassure_patches/P-2025/P-2025.msi -OutFile c:\P-2025.msi
}


else
{Write-Host "No patches for current Core version"}


Write-host "Changing hostname..."
$newname=Read-Host -Prompt 'Enter new hostname'
RENAME-COMPUTER –newname $newname
Restart-Computer -Force