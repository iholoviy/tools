Write-Host "Wellcome to data generator script"
Write-host "Please make sure that appassure module is imported"
Write-Host "Make sure that path to DDt.exe is C:\ChangeGen\ddt.exe"

While ($true)
{  
$Parameters = Import-Csv "C:\ChangeGen\Parameters.csv"
$location = $Parameters.path
if ((Test-Path $location) -eq 0)
{
mkdir $location
}
$size = $Parameters.size 
$dup_percentage = $Parameters.compression
$blocksize = 512
[int]$Sleep = [convert]::ToInt32($Parameters.Time) * 60
$timeinterval=$parameters.Time
Write-host "Getting new seed"
$Seed = Get-Random
Write-Host "New seed is $Seed" 
Write-Host "Generating data" 
$arguments = "op=write threads=1 filename=$location\$Seed filesize=$size 

blocksize=$blocksize dup-percentage=$dup_percentage buffering=direct 

io=sequential seed=$Seed" 
start-process "C:\ChangeGen\ddt.exe" $arguments
Write-Host "Snapshot is ready. Transferring..."
Write-host "Waiting for a $timeinterval minutes to generate new data"
Start-sleep -Seconds $Sleep
Write-Host "Removing old data"
Remove-Item $location\* -Recurse
Write-Host "Generating new data"
}