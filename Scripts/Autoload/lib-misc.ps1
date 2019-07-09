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

function Get-ProceedConfirmation
{
    param([Parameter(Mandatory=$false)][string]$Title="Confirm?")    

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Continue'
    $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Abort'
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice($Title, 'Would you like to continue?', $options, 1)
    return ($result -eq 0)
}

function runScriptBlock($scriptBlock) 
{
    Invoke-Command -ComputerName $server -Credential $MySecureCreds -ScriptBlock $scriptBlock
}

Function IIf($If, $Then, $Else) {
    If ($If -IsNot "Boolean") {$_ = $If}
    If ($If) {If ($Then -is "ScriptBlock") {&$Then} Else {$Then}}
    Else {If ($Else -is "ScriptBlock") {&$Else} Else {$Else}}
}

#=====================================================================
# Export-Credential
# Usage: Export-Credential $CredentialObject $FileToSaveTo
#=====================================================================
function Export-Credential($cred, $path) {
    $cred = $cred | Select-Object *
    $cred.password = $cred.Password | ConvertFrom-SecureString
    $cred | Export-Clixml $path
}

#=====================================================================
# Get-MyCredential
#=====================================================================
function Get-MyCredential
{
param(
$CredPath,
[switch]$Help
)
$HelpText = @"

    Get-MyCredential
    Usage:
    Get-MyCredential -CredPath `$CredPath

    If a credential is stored in $CredPath, it will be used.
    If no credential is found, Export-Credential will start and offer to
    Store a credential at the location specified.

"@
    if($Help -or (!($CredPath))){write-host $Helptext; Break}
    if (!(Test-Path -Path $CredPath -PathType Leaf)) {
        Export-Credential (Get-Credential) $CredPath
    }
    $cred = Import-Clixml $CredPath
    $cred.Password = $cred.Password | ConvertTo-SecureString
    $Credential = New-Object System.Management.Automation.PsCredential($cred.UserName, $cred.Password)
    Return $Credential
}

