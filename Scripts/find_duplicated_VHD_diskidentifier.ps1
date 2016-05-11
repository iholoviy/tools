$VHDlocation="D:\hyperv-machines"

$VMDisks=Get-ChildItem $VHDlocation -Include *vhdx -Recurse |foreach { $_.FullName}
$hash =@{}

foreach ($VMDisk in $VMDisks) {
$VMDiskID=Get-VHD -Path $VMDisk |foreach { $_.DiskIdentifier}
$VMDiskID | % {$hash[$_] = $hash[$_] + 1 }
$hash.getenumerator() | ? { $_.value -gt 1 }

}