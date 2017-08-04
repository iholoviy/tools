do{$memory=Get-Process VMProxy* |foreach {$_.WS} | measure-object -sum |foreach {$_.sum} 
filter timestamp {"$(Get-Date -Format G): $_"}
$memoryMB=$memory/1024/1024 | timestamp |Out-File c:\memory-02-14.txt -Append
Start-Sleep -Seconds 60
}
while ($true)
 
