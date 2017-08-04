$downloadfolder="C:\installers"
$limit = (Get-Date).AddDays(-1)
$arguments = "licensekey=c:\installers\QA.lic /silent"

Function Download-Core {

$VersionLocal=(Get-Version).Substring(26) 


[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$wc=new-object system.net.webclient
$wc.UseDefaultCredentials = $true
$wc.Credentials = New-Object System.Net.NetworkCredential("iholoviy","123asdQ!@#")
if ((Test-Path $downloadfolder) -eq 0)
    {
    mkdir $downloadfolder
    }

#loading xml for develop branch
[xml]$xml = $wc.DownloadString("https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Develop20_FullBuild/artifacts/children/installers")


foreach( $link in $xml.files.file.content.href){
      if ($link -like '*Core-X*')
      {        
          $myMatch = ".*id\:([^\/]+)\/.*installers\/(.*)"
          $link -match $myMatch
          $id=$($Matches[1])
          $installer=$($Matches[2])
          $VersionOnTeamcity=$installer.Substring(9,11)
          $dlink=("https://tc.appassure.com/repository/download/AppAssure_Windows_Develop20_FullBuild/${id}:id/installers/$installer")
          $output=Join-Path $downloadfolder -ChildPath $installer
          if ($VersionLocal -lt $VersionOnTeamcity) 
                {
                Write-Host "New verion is avaliabe. Dowloading..."
                #Downloading using basic authentication
                $credCache = new-object System.Net.CredentialCache
                $creds = new-object System.Net.NetworkCredential("iholoviy","123asdQ!@#")
                $credCache.Add($dlink, "Basic", $creds)
                $wc.Credentials = $credCache
                $wc.DownloadFile($dlink, $output)
                wget http://iholoviy.s3.amazonaws.com/QA.lic -OutFile C:\installers\QA.lic
                Write-Host "Dowload completed. Srarting installation"
                #Remove-Item -Path "C:\ProgramData\AppRecovery\Logs\AppRecoveryInstallation.log" -Force -ErrorAction SilentlyContinue
                Get-ChildItem -Path $downloadfolder -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
                $CoreInstaller=Get-ChildItem $downloadfolder -Recurse | % { $_.FullName } | Sort-Object LastAccessTime -Descending | Select-Object -First 1
                start-process $CoreInstaller -ArgumentList $arguments
                exit

                }
            else 
                {
                Write-host "There is no new verion"
                }
                    
        }
}

 
}

Download-Core
