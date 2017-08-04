$MaxSegmentSize = "1048576"
$MaxConcurrentStreams = "1"
Get-ChildItem HKLM:\software\apprecovery\core\Agents -Recurse | where {$_.pspath -match "Transfer"} |  where {$_.Property -contains "MaxSegmentSize"} | foreach {Set-ItemProperty -Name MaxSegmentSize -Path $_.pspath -Value $MaxSegmentSize }
Get-ChildItem HKLM:\software\apprecovery\core\Agents -Recurse | where {$_.pspath -match "Transfer"} |  where {$_.Property -contains "MaxConcurrentStreams"} | foreach {Set-ItemProperty -Name MaxConcurrentStreams -Path $_.pspath -Value $MaxConcurrentStreams }
