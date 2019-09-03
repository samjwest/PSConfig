
$gitAcct = "https://sg_sam@bitbucket.org/Golflerjp/" 
$appNamePref = "sg-scu-int-"
$resourceGroup="SGSCURG01-INTEGRATION"
$servicePlan = "sg-scu-integration-asp"

$global:currRepo = "https://sg_sam@bitbucket.org/Golflerjp/golfler_asp.git" 

function Set-Repo($repoName)
{
    $global:currRepo = -join($gitAcct, $repoName, ".git")
    Write-Host "Repo updated to: "$global:currRepo
}

function Get-ProceedConfirmation
{
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Continue'
    $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Abort'
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice('Confirm?', 'Would you like to continue?', $options, 1)
    return ($result -eq 0)
}

function New-IntAppService
{
    param(   
        # Parameter help description
        [Parameter(Mandatory=$True)]
        [string]$Name,
        [Parameter(Mandatory=$True)]
        [string]$Branch,
        [switch]$CreateSlots,
        [string]$location="South Central US"        
    )

    $PropertiesObject = @{repoUrl = "$global:currRepo"; branch = "$Branch";}
    $AppName = -join($appNamePref, $Name, "-api")

    Write-Host "Creating $AppName service on the default service plan in $resourceGroup resource group with the following account context:"
    Get-AzureRmContext
    
    if(Get-ProceedConfirmation) {
        Write-Host "Creating $AppName ..."
        New-AzureRmWebApp -Name $AppName -AppServicePlan $servicePlan -ResourceGroupName $resourceGroup -Location $Location
        Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $resourceGroup -ResourceType Microsoft.Web/sites/sourcecontrols -ResourceName $AppName/web -ApiVersion 2018-10-01 -Force

        Get-AzureRmWebApp -ResourceGroupName $resourceGroup -Name $AppName
        if($CreateSlots)
        {
            Write-Host "Creating default deployment slots ..."
            For ($i=1; $i -lt 5; $i++) {
                $slotId = -join("0",$i.ToString())
                if($i -eq 1) # Staging slot
                {
                    New-AzureRmWebAppSlot -Name $AppName -ResourceGroupName $resourceGroup -Slot staging
                    Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $resourceGroup -ResourceType Microsoft.Web/sites/slots/sourcecontrols -ResourceName $webappname/staging/web -ApiVersion 2015-08-01 -Force
                }
                else {
                    New-AzureRmWebAppSlot -Name $AppName -ResourceGroupName $resourceGroup -Slot $slotId # -join("0",$i.ToString())
                    $PropertiesObject.branch = -join($Branch, "-", $slotId)  # -join("-0",$i.ToString()))
                    Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $resourceGroup -ResourceType Microsoft.Web/sites/slots/sourcecontrols -ResourceName $webappname/$slotId/web -ApiVersion 2015-08-01 -Force
                }
            
            }
        }
        

    }
    else {
        Write-Host "Process Aborted"
    }
    

}