$username="iholoviy"
$password="password"
$downloadFolder="C:\installers"
$release7="https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Release700_FullBuild/artifacts/children/installers"
$develop="https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Develop20_FullBuild/artifacts/children/installers"
$licenseFileUrl="http://host.with.license.key/QA.lic"
$arguments = "licensekey=$env:temp\QA.lic privacypolicy=accept /silent"

if ((Test-Path $downloadfolder) -eq 0) {
    mkdir $downloadfolder
}


Function Download-Core ($branch="develop"){
    if ($branch -eq "develop") {
        Write-Host "Going to check develop branch..."
        $teamcityBranch=$develop
    }
    if ($branch -eq "release7") {
        Write-Host "Going to check release 7.0 branch..."
        $teamcityBranch=$release7
    }
    else {
        Write-Host "Branch was not specified or specified incorrectly. Will use a develop branch..."
        $teamcityBranch=$release7
    }
    $limit = (Get-Date).AddDays(-1)
    $VersionLocal=(Get-Version).Substring(26)
    
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $wc=New-Object system.net.webclient
    $wc.UseDefaultCredentials = $true
    $wc.Credentials = New-Object System.Net.NetworkCredential($username,$password)
    [xml]$xml = $wc.DownloadString($teamcityBranch)
    
foreach( $link in $xml.files.file.content.href) {
        if ($link -like '*Core-X*') {
            $myMatch = ".*installers\/(.*-([\d.]+).exe)"
            $link -match $myMatch | out-null
            $installer=$($Matches[1])
            $version=$($Matches[2])
            if ($VersionLocal -lt $version) {
                Write-Host "Teamcity has latest installer with $version which is newer than installed $VersionLocal. Downloading new version..."
                $dlink="https://tc.appassure.com" + $link
                $output=Join-Path $downloadfolder -ChildPath $installer
                $credCache = new-object System.Net.CredentialCache
                $creds = new-object System.Net.NetworkCredential($username,$password)
                $credCache.Add($dlink, "Basic", $creds)
                $wc.Credentials = $credCache
                $wc.DownloadFile($dlink, $output)
                Invoke-WebRequest $licenseFileUrl -OutFile $env:temp\QA.lic
                Write-Host "Dowload completed. Srarting installation of $version"
                Get-ChildItem -Path $downloadfolder -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
                $CoreInstaller=Get-ChildItem $downloadfolder -Recurse | ForEach-Object { $_.FullName } | Sort-Object LastAccessTime -Descending | Select-Object -First 1
                Start-Process $CoreInstaller -ArgumentList $arguments
                Exit
            }
            else {
                Write-host "There is no newer verion on Teamcity. Installed version $VersionLocal is the same or newer than $version which is on Teamcity"  
            }
        }
    }
}
Download-Core -branch release7
                
                
                
          