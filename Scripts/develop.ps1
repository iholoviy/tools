[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$wc=new-object system.net.webclient
$wc.UseDefaultCredentials = $true
$wc.Credentials = New-Object System.Net.NetworkCredential("iholoviy","123asdQ!!!")



#loading xml for 5.5.1 branch
[xml]$xml = $wc.DownloadString("https://tc.appassure.com/httpAuth/app/rest/builds/branch:%3Cdefault%3E,status:SUCCESS,buildType:AppAssure_Windows_Develop_FullBuild/artifacts/children/installers")


foreach( $link in $xml.files.file.content.href){
        #Write-Host $link
        
      if ($link -like '*Core-X*' -or $link -like '*Agent-X*' -or $link -like '*CentralConsole-*' -or $link -like '*LocalMountUtility-X*'){
        ##$dlink=("https://iholoviy:123asdQ!@tc.appassure.com" +$link)
        ##Write-Host $dlink         
        $myMatch = ".*id\:([^\/]+)\/.*installers\/(.*)"
        $link -match $myMatch
        $id=$($Matches[1])
        $installer=$($Matches[2])
        $dlink=("https://tc.appassure.com/repository/download/AppAssure_Windows_Develop_FullBuild/${id}:id/installers/$installer")
                    
       $cmd='C:\Program Files (x86)\Free Download Manager\fdm.exe'
       & $cmd "-fs" ""$dlink""
      
        }
}
