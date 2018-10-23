function df {
    $colItems = Get-wmiObject -class "Win32_LogicalDisk" -namespace "root\CIMV2" `
    -computername localhost

    foreach ($objItem in $colItems) {
        write $objItem.DeviceID $objItem.Description $objItem.FileSystem `
            ($objItem.Size / 1GB).ToString("f3") ($objItem.FreeSpace / 1GB).ToString("f3")

    }
}

Function RDP
{
param  
        (  
            [Parameter(
                Position = 0,
                ValueFromPipeline=$true,
                Mandatory=$true,
                HelpMessage="Server Friendly name"
            )]
            [ValidateNotNullOrEmpty()]
            [string]
            $server
        )
    cmdkey /generic:TERMSRV/$server /user:$UserName /pass:($Password.GetNetworkCredential().Password)
    mstsc /v:$Server /f /admin
    Wait-Event -Timeout 10
    cmdkey /Delete:TERMSRV/$server

}