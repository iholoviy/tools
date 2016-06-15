<#
    - Create a new archive from a random file in folders;
    - Generate hash of archive;
    - Copy archive to VM;
    - Force transfer;
    - Mount last recovery point;
    - Compare hash of archive in mountpoint with original hash which was written to file

#>

#load script for archiving
."C:\Users\admin\Downloads\Script\Zip.ps1"

#Declare variables
$VMname="Win10x64-gen1"
$FolderWithFiles="C:\files\"
$FolderWithArchiveOnHost="C:\Archives\"
$VolumeOnVM="Hard disk 0_Volume 1"
$ArchiveName="archive.zip"
$LocationOfArchiveOnVM="C:\"
$PathToMountPoint="C:\mnt\"


#Creating of archive using Zip.ps1 from random file in folder
$File=Get-ChildItem $FolderWithFiles | Get-Random | foreach {$_.FullName}
$ArchivePath=Join-path $FolderWithArchiveOnHost -ChildPath $ArchiveName
if(!(Test-Path -Path $FolderWithArchiveOnHost ))
{
    New-Item -ItemType directory -Path $FolderWithArchiveOnHost
}
New-ArchiveFromFile -Source $File -Destination $ArchivePath
 
#Generating hash
(Get-FileHash $ArchivePath).hash |Out-File (Join-Path $FolderWithArchiveOnHost -ChildPath "md5.txt")

#Copying files to VM
Enable-VMIntegrationService –Name "Guest Service Interface" -VMName $VMname
Copy-VMFile $VMname -SourcePath $ArchivePath -DestinationPath (Join-Path $LocationOfArchiveOnVM -ChildPath $ArchiveName) -FileSource Host -CreateFullPath -Force
Copy-VMFile $VMname -SourcePath (Join-Path $FolderWithArchiveOnHost -ChildPath "md5.txt") -DestinationPath (Join-Path $LocationOfArchiveOnVM -ChildPath "md5.txt") -FileSource Host -CreateFullPath -Force

#Transfer, Mount and compare hash
New-Snapshot -ProtectedServer $VMname
do 
{
    $job=Get-Activejobs -ProtectedServer $VMname
    Write-Host "Jobs are still in progress"
    Start-Sleep -Seconds 10
}

While 
(
    $job.Status -ne $null
)

New-Mount -ProtectedServer $VMname -Path $PathToMountPoint -ShowProgress
$PathToMD5InFile=Join-Path $PathToMountPoint -ChildPath $VolumeOnVM |Join-Path -ChildPath "md5.txt"
$PathToArchiveInMountpoint=Join-Path $PathToMountPoint -ChildPath $VolumeOnVM |Join-Path -ChildPath $ArchiveName
$HashInFile=Get-Content $PathToMD5InFile.ToString()
$HashInMountPoint=(Get-FileHash $PathToArchiveInMountpoint).hash

if($HashInFile -ne $HashInMountPoint) 
{
    Write-Host "Files are different.$HashInMountPoint is not equal to $HashInFile"  -foregroundcolor "Red"
}

Else 
{
    Write-Host "Files are the same. $HashInMountPoint is equal to $HashInFile"  -foregroundcolor "Green"
}

#Cleaning up
Remove-Item $FolderWithArchiveOnHost -Recurse -Force
Remove-Mount -Path $PathToMountPoint

