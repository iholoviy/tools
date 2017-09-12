$username="iholoviy"
$password="password"
$downloadFolder="C:\installers"
$teamcityBranch="https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Develop20_FullBuild/artifacts/children/installers"
$licenseFileUrl="http://host,with.license/QA.lic"
$arguments = "licensekey=$env:temp\QA.lic privacypolicy=accept /silent"

Function Download-Core {
    $limit = (Get-Date).AddDays(-1)
    $VersionLocal=(Get-Version).Substring(26)
    
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $wc=New-Object system.net.webclient
    $wc.UseDefaultCredentials = $true
    $wc.Credentials = New-Object System.Net.NetworkCredential($username,$password)
    [xml]$xml = $wc.DownloadString($teamcityBranch)
    
    foreach( $link in $xml.files.file.content.href) {
        if ($link -like '*Core-X*') {
            $myMatch = ".*installers\/(.*-([\d.]+).exe)"  > $null
            $link -match $myMatch | out-null
            $installer=$($Matches[1])
            $version=$($Matches[2])
            if ($VersionLocal -lt $version) {
                Write-Host "Teamcity has latest installer with $version which is newer than installed $VersionLocal. Downloading..."
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
                Write-host "There is no newer verion Teamcity"  
            }
        }
    }
}
Download-Core