#Mount network drive with VHDx
#If you have active connections use following command in cmd to clear them: net use * /d
$net = new-object -ComObject WScript.Network
$net.MapNetworkDrive("Z:", "\\10.35.39.43\VHDx", $false, "administrator", "123asdQ")

#Specify location of folder with VHDx files
$LocationWithVHDx="Z:\Windows\"

#Specify location where you going to store the VMs
$LocationForVMs="D:\hyperv-machines\"
 
#Stop all VMs
$VMs=get-vm |foreach { $_.Name}
foreach ($VM in $VMs) {
    Stop-VM -Name $VM -Force
}

#Delete VMs
$VMs=get-vm |foreach { $_.Name}
foreach ($VM in $VMs) {
    Remove-VM -Name $VM -Force
}

#Delete folder with VMs
if (Test-Path $LocationForVMs) {
    Remove-Item -Recurse -Force $LocationForVMs
 }

#Create directories for VMs
$VMDisks=Get-ChildItem $LocationWithVHDx -Include *vhdx -Recurse -ErrorAction SilentlyContinue |foreach {$_.Name}
$folders=$VMDisks -notlike "*_*"
foreach ($folder in $folders) {
    $foldername=$folder.Substring(0,$folder.length -5)
    $NewFolderPath=Join-Path $LocationForVMs -ChildPath $foldername
    New-Item $NewFolderPath -type directory
}

#Copy VHDx files to VM folders
$VMfolders=Get-ChildItem $LocationForVMs -Recurse | foreach {$_.Name}
$VMDisks=Get-ChildItem $LocationWithVHDx -Include *vhdx -Recurse |foreach {$_.Name}


foreach ($VMDisk in $VMDisks) {
   foreach ( $VMfolder in $VMfolders) {
        if ($VMDisk -match $VMfolder) {
        $FullPathToDisk=Join-Path $LocationWithVHDx -childpath $VMDisk
        $FullPathToFolder=Join-Path $LocationForVMs -childpath $VMFolder
        Write-Host "Copying $VMDisk to $FullPathToFolder "
        Copy-Item $FullPathToDisk -Destination $FullPathToFolder
        }

   }
}

#Create VMs
$VMfolders=Get-ChildItem $LocationForVMs |foreach {$_.Name}
foreach ($VMfolder in $VMfolders) {
$VMfolderPath=Join-Path $LocationForVMs -ChildPath $VMfolder
$WinVersion=(Get-WmiObject win32_operatingsystem).version
    if ($WinVersion -match 6.3 -or 10.0) {
    write-host "This host supports second generation of VMs"
        if ($VMfolder -like "*gen2*")
        {Write-Host "$VMfolder is 2nd gen VM"
        New-VM -Name $VMFolder -MemoryStartupBytes 512MB -Generation 2 -NoVHD -Path $VMfolderPath
        }
        else
        {Write-Host "$VMfolder is 1st gen VM"
        New-VM -Name $VMFolder -MemoryStartupBytes 512MB -Generation 1 -NoVHD -Path $VMfolderPath
        }
    }

    else {
        write-host "This host does not support second generation of VMs"
        if ($VMfolder -like "*gen2*")
        {Write-Host "$VMfolder is 2nd gen VM and will be skipped"

        }
        else
        {Write-Host "$VMfolder is 1st gen VM"
        New-VM -Name $VMFolder -MemoryStartupBytes 512MB -Generation 1 -NoVHD -Path $VMfolderPath
        }
    }
}

#Attach Disks to VMs
$VMs=get-vm |foreach {$_.Name}
$VMDisks=Get-ChildItem $LocationForVMs -Include *vhdx -Recurse |foreach {$_.Name}

foreach ($VM in $VMs) {
    foreach ($VMDisk in $VMDisks) {
        if ($VMDisk.ToString() -match $VM.ToString()){
        $path=Join-Path $LocationForVMs -ChildPath $VM |Join-Path -ChildPath $VMDisk
        Write-Host "Adding $VMDisk to $VM"
        ADD-VMHardDiskDrive -VMName $VM -Path $path
        }
    }
}

#Start all VMs
$VMs=get-vm |foreach { $_.Name}
foreach ($VM in $VMs) {
    Start-VM -Name $VM
}
 
