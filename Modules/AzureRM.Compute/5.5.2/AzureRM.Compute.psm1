#  
# Module manifest for module 'AzureRM.Compute'  
#  
# Generated by: Microsoft Corporation  
#  
# Generated on: 08/29/2018 10:22:26
#  

$PSDefaultParameterValues.Clear()
Set-StrictMode -Version Latest

$module = Get-Module AzureRM.Profile 
if ($module -ne $null -and $module.Version.ToString().CompareTo("5.5.1") -lt 0) 
{ 
    Write-Error "This module requires AzureRM.Profile version 5.5.1. An earlier version of AzureRM.Profile is imported in the current PowerShell session. Please open a new session before importing this module. This error could indicate that multiple incompatible versions of the Azure PowerShell cmdlets are installed on your system. Please see https://aka.ms/azps-version-error for troubleshooting information." -ErrorAction Stop 
} 
elseif ($module -eq $null) 
{ 
    Import-Module AzureRM.Profile -MinimumVersion 5.5.1 -Scope Global 
}
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath Microsoft.Azure.Commands.Compute.dll)


if (Test-Path -Path "$PSScriptRoot\StartupScripts")
{
    Get-ChildItem "$PSScriptRoot\StartupScripts" | ForEach-Object {
        . $_.FullName
    }
}

$FilteredCommands = @('Remove-AzureRmAvailabilitySet:ResourceGroupName','New-AzureRmAvailabilitySet:ResourceGroupName','Get-AzureRmVMADDomainExtension:ResourceGroupName','Set-AzureRmVMADDomainExtension:ResourceGroupName','Get-AzureRmVMAEMExtension:ResourceGroupName','Remove-AzureRmVMAEMExtension:ResourceGroupName','Set-AzureRmVMAEMExtension:ResourceGroupName','Test-AzureRmVMAEMExtension:ResourceGroupName','Set-AzureRmVMBginfoExtension:ResourceGroupName','Get-AzureRmVMCustomScriptExtension:ResourceGroupName','Remove-AzureRmVMCustomScriptExtension:ResourceGroupName','Set-AzureRmVMCustomScriptExtension:ResourceGroupName','Get-AzureRmVMDiagnosticsExtension:ResourceGroupName','Remove-AzureRmVMDiagnosticsExtension:ResourceGroupName','Set-AzureRmVMDiagnosticsExtension:ResourceGroupName','Set-AzureRmVMExtension:ResourceGroupName','Remove-AzureRmVMExtension:ResourceGroupName','Get-AzureRmVMExtension:ResourceGroupName','Get-AzureRmVMSqlServerExtension:ResourceGroupName','New-AzureRmVMSqlServerAutoBackupConfig:ResourceGroupName','New-AzureRmVMSqlServerKeyVaultCredentialConfig:ResourceGroupName','Remove-AzureRmVMSqlServerExtension:ResourceGroupName','Set-AzureRmVMSqlServerExtension:ResourceGroupName','Get-AzureRmVMAccessExtension:ResourceGroupName','Remove-AzureRmVMAccessExtension:ResourceGroupName','Set-AzureRmVMAccessExtension:ResourceGroupName','Get-AzureRmRemoteDesktopFile:ResourceGroupName','Get-AzureRmVMBootDiagnosticsData:ResourceGroupName','Set-AzureRmVmssVM:ResourceGroupName','Set-AzureRmVmss:ResourceGroupName','Update-AzureRmVmss:ResourceGroupName','Get-AzureRmVMDscExtensionStatus:ResourceGroupName','Remove-AzureRmVMDscExtension:ResourceGroupName','Set-AzureRmVMDscExtension:ResourceGroupName','Get-AzureRmVMDscExtension:ResourceGroupName','Get-AzureRmVMChefExtension:ResourceGroupName','Remove-AzureRmVMChefExtension:ResourceGroupName','Set-AzureRmVMChefExtension:ResourceGroupName','Remove-AzureRmVMBackup:ResourceGroupName','Disable-AzureRmVMDiskEncryption:ResourceGroupName','Get-AzureRmVMDiskEncryptionStatus:ResourceGroupName','Remove-AzureRmVMDiskEncryptionExtension:ResourceGroupName','Set-AzureRmVMDiskEncryptionExtension:ResourceGroupName','Set-AzureRmVMBackupExtension:ResourceGroupName','Disable-AzureRmVmssDiskEncryption:ResourceGroupName','Get-AzureRmVmssVMDiskEncryption:ResourceGroupName','Set-AzureRmVmssDiskEncryptionExtension:ResourceGroupName')

if ($Env:ACC_CLOUD -eq $null)
{
    $FilteredCommands | ForEach-Object {
        if (!$global:PSDefaultParameterValues.Contains($_))
        {
            $global:PSDefaultParameterValues.Add($_,
                {
                    $context = Get-AzureRmContext
                    if (($context -ne $null) -and $context.ExtendedProperties.ContainsKey("Default Resource Group")) {
                        $context.ExtendedProperties["Default Resource Group"]
                    } 
                })
        }
    }
}

# SIG # Begin signature block
# MIIplQYJKoZIhvcNAQcCoIIphjCCKYICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDnDKKALMePu9m9
# pNoZrXotpIn05NruTdEnTT/YVvjiO6CCDYEwggX/MIID56ADAgECAhMzAAABA14l
# HJkfox64AAAAAAEDMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMTgwNzEyMjAwODQ4WhcNMTkwNzI2MjAwODQ4WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDRlHY25oarNv5p+UZ8i4hQy5Bwf7BVqSQdfjnnBZ8PrHuXss5zCvvUmyRcFrU5
# 3Rt+M2wR/Dsm85iqXVNrqsPsE7jS789Xf8xly69NLjKxVitONAeJ/mkhvT5E+94S
# nYW/fHaGfXKxdpth5opkTEbOttU6jHeTd2chnLZaBl5HhvU80QnKDT3NsumhUHjR
# hIjiATwi/K+WCMxdmcDt66VamJL1yEBOanOv3uN0etNfRpe84mcod5mswQ4xFo8A
# DwH+S15UD8rEZT8K46NG2/YsAzoZvmgFFpzmfzS/p4eNZTkmyWPU78XdvSX+/Sj0
# NIZ5rCrVXzCRO+QUauuxygQjAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUR77Ay+GmP/1l1jjyA123r3f3QP8w
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDM3OTY1MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAn/XJ
# Uw0/DSbsokTYDdGfY5YGSz8eXMUzo6TDbK8fwAG662XsnjMQD6esW9S9kGEX5zHn
# wya0rPUn00iThoj+EjWRZCLRay07qCwVlCnSN5bmNf8MzsgGFhaeJLHiOfluDnjY
# DBu2KWAndjQkm925l3XLATutghIWIoCJFYS7mFAgsBcmhkmvzn1FFUM0ls+BXBgs
# 1JPyZ6vic8g9o838Mh5gHOmwGzD7LLsHLpaEk0UoVFzNlv2g24HYtjDKQ7HzSMCy
# RhxdXnYqWJ/U7vL0+khMtWGLsIxB6aq4nZD0/2pCD7k+6Q7slPyNgLt44yOneFuy
# bR/5WcF9ttE5yXnggxxgCto9sNHtNr9FB+kbNm7lPTsFA6fUpyUSj+Z2oxOzRVpD
# MYLa2ISuubAfdfX2HX1RETcn6LU1hHH3V6qu+olxyZjSnlpkdr6Mw30VapHxFPTy
# 2TUxuNty+rR1yIibar+YRcdmstf/zpKQdeTr5obSyBvbJ8BblW9Jb1hdaSreU0v4
# 6Mp79mwV+QMZDxGFqk+av6pX3WDG9XEg9FGomsrp0es0Rz11+iLsVT9qGTlrEOla
# P470I3gwsvKmOMs1jaqYWSRAuDpnpAdfoP7YO0kT+wzh7Qttg1DO8H8+4NkI6Iwh
# SkHC3uuOW+4Dwx1ubuZUNWZncnwa6lL2IsRyP64wggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIbajCCG2YCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAQNeJRyZH6MeuAAAAAABAzAN
# BglghkgBZQMEAgEFAKCBzDAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg35dr8BBV
# crdE7JhJSDBdXh85xYauFLn4RUca9jqGPg8wYAYKKwYBBAGCNwIBDDFSMFCgNoA0
# AE0AaQBjAHIAbwBzAG8AZgB0ACAAQQB6AHUAcgBlACAAUABvAHcAZQByAFMAaABl
# AGwAbKEWgBRodHRwOi8vQ29kZVNpZ25JbmZvIDANBgkqhkiG9w0BAQEFAASCAQAz
# UYm6+oyncNswRI6fDbVUpgUMmuDxmriVvfHX2lbto/beJyFiAf6rY1dWVZlkTX6p
# YEHAwtSSe4r2IuXcsmtk1L0ZKm2l6Hmh9grErpZTlZ1OlzJtZKw2ogU+clS1j5qj
# Ng9lL9T5C8AokmvJBgQDcIa+Cqkka8Oz61U9ECJMvrNih/yXbEYcu5MyWmBaBjUW
# 89noZNXnmxkivvv03rURfyJ3zCo1QHTcEoqm2sldYe7PYwnm8EBH4xq5zpgOx6Nb
# f+LYq74VA5563MlqxfxEDVx5Cji2kQptiO2lKxuLdjg3QQM57+hrofJGwyRH1tKV
# 7LbP2b4gOS1KFPr9fOxnoYIY1jCCGNIGCisGAQQBgjcDAwExghjCMIIYvgYJKoZI
# hvcNAQcCoIIYrzCCGKsCAQMxDzANBglghkgBZQMEAgEFADCCAVEGCyqGSIb3DQEJ
# EAEEoIIBQASCATwwggE4AgEBBgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIBBQAE
# IMNvMn8BJNELYurda0Z+qDfLWmxKFZ6E1ZPqU7I3zvSKAgZbcw0bNgQYEzIwMTgw
# ODI5MTAyMzQ2Ljg0N1owBIACAfSggdCkgc0wgcoxCzAJBgNVBAYTAlVTMQswCQYD
# VQQIEwJXQTEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25z
# IExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkZDNDEtNEJENC1EMjIw
# MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBzZXJ2aWNloIIULTCCBPEw
# ggPZoAMCAQICEzMAAADFdzGCFjtxVG8AAAAAAMUwDQYJKoZIhvcNAQELBQAwfDEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWlj
# cm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcNMTgwMTMxMTkwMDQ4WhcNMTgw
# OTA3MTkwMDQ4WjCByjELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAldBMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNV
# BAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UE
# CxMdVGhhbGVzIFRTUyBFU046RkM0MS00QkQ0LUQyMjAxJTAjBgNVBAMTHE1pY3Jv
# c29mdCBUaW1lLVN0YW1wIHNlcnZpY2UwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCq1SLcpF9StcqQhWW95C4UODu1Qh5rIYDkFeqWoEQlNBSSmeaNWFKs
# 7ZLRCe92mXfgRsvDS8uJknuOctrIW0TFFrQqu6JyDlvElbNRmCWbeSgRUyQZ52S3
# ixxzlUCnWhItaozxhWsdE3K3nf2Z7XzFk6eCXTf5Lgcdf92hSu3aFn9j0g/HygI+
# XtK/uNKHfvvjJLu0OHkWBSAmCFHSxvhV507+eLHJIFr46qeG/3RXLZWUX6Psi3Eo
# dfz3bFL7Wz4S1OpUoLwKIIVLu3PpIoHVpRxvAFnla1qjWF9NNCaFrD7D9evsva1A
# djRU4K5CLi4+VSg9LTnWc6IwCzkbsXLrAgMBAAGjggEbMIIBFzAdBgNVHQ4EFgQU
# rOtweNXInveS1OYWHT1d/6+J5YswHwYDVR0jBBgwFoAU1WM6XIoxkPNDe3xGG8Uz
# aFqFbVUwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29t
# L3BraS9jcmwvcHJvZHVjdHMvTWljVGltU3RhUENBXzIwMTAtMDctMDEuY3JsMFoG
# CCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraS9jZXJ0cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcnQwDAYDVR0T
# AQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOCAQEA
# GDot38ilLEE5OwY+voD56ipGSiRYHzc0uERhAS4Gh+M+oiVGcWlSvCiAUvT9qU2F
# JFiZFn6jzI8qsou25xd+TBPnf4lnsYvFyaX4GS3kUdB4Egq6lgDbmsQ0anls1CG9
# ajxaomai48g41dWOFS4sVTgZ3Uk7TX5kW5VpfsoQnd2w8pIbvwLL97IeO4kxDeYl
# 9X2EySWiZaMCq2UWy4UBdYPA3wUcyJUQonvI1Sqr/BHn7AAPg2NGv9Tx3bfo0Tvx
# 29+3t2ss0EukcubqPxluaLllPzvQm8jKZkYuH20HCQwDhHDYtSVmrb1rE8xppL1r
# WSBAkT1EdRl8v+MWAet/VDCCBe0wggPVoAMCAQICECjMOiW/ukSsRJqbWGtDOaow
# DQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhv
# cml0eSAyMDEwMB4XDTEwMDYyMzIxNTcyNFoXDTM1MDYyMzIyMDQwMVowgYgxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jv
# c29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAuQieKOTk7AZOUGizQcV76662jq+BuiJEH2U0
# aUy+cEAX8hZ74nn9hu0NOfQbqK2SkB7LPXaPWtm1kRAuPAWNim0kVOcf7Vatg7RQ
# nBWlF3SIWSD8CMWEdtNo1G8oeM5cuPNQkET/42NfvqGaLJYVBNYH/h6EIeBCMRHE
# KDaUz1CkYp7J1qtxALJbDOaW1AoklvX/xtW3G9fLtyFirxLcoV034xr7GkaYwJvA
# 52MfKgiTAn4eao7ynxiJ5CKForGEV0D/9Q7Yb5zt4kUxAc0X6X+wgUXjqiFAJqFy
# qqdPPAEFfu6DWLFeBmOZYpF4grcNkwwkarQb2yfsX5UEP5NKMPWXGLOn+RmnkzMd
# AcjbIlJc1yXJRvmi+4dZQ76bYrGNLYZEGkaseGF+MAn6ronEQSoiZgOROUWcx4sM
# qMoNL/tS6gz3YzMjnf6wH61n1qdQA8YEcGO1LLGGWkO3+675biluISFBJgaMycPu
# sMKFk6G5hdnmMmxLTD/WXaPltZ13w5zAVbd0AOO4OKuDl1DhmkIkHcbAozDRGlrI
# UjT3c/HHGB8zrXrsy0Fg8yOUIMJIRaxcUcYugMLidxW9hYftNp2Wke4AtaNw7J/j
# jYBog3a6r11wUiIW4mb7urPFwvc+L3emyt7BpsZITMM3USPTJ9e4TnCW8KFEdq94
# z5rhZhMCAwEAAaNRME8wCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHQYD
# VR0OBBYEFNX2VsuP6KJcYmjRPZSQW9fOmhjEMBAGCSsGAQQBgjcVAQQDAgEAMA0G
# CSqGSIb3DQEBCwUAA4ICAQCspZaMv7uupvbXcYdDMVaI/RwycVs1t9TwkfKvN+IU
# 8fMCJgU+FhR/FLq4T/uJsrLn1AnMbblbO2RlcGa38rFa3xoC8/VRuGdtefO/Vnvk
# hLkrHptAnCY0+UcYmGnYHNe20b+PYcJnxLXvYEOOEBs2SeQgyq2nwbEnZQn4zfVb
# KtCEM/PvH/L1nAtYkzegdaDect5sdSpmIvWMBjBWn0C5MKpAdxWC14vswNOyvYPF
# dwwerq8ZU6BNeXGfD68wzmf51izMIkF6B/KXQhjOWXkQVd5vEOS42oNmQBYJaCNb
# ly4mmgK7V4zFuLppYjKAiZ6h/cCSfHsrMxmEKmPFAGhi+p9HjZl6RTqn6e3uaUK1
# 84GbR1YQe/xwNoQYc+rv+ZdNnjMj3SYLuiq3P0Tcgyf/vWFZKxG3yk/bxYsMHDGu
# Mvj4uUL3f9xhmnaxWgThET1mRbcYcb7JJIXW89S6QTRdEi0luY2mE0htS7AHfZmT
# CWGBdFcmiqtp4+TZx4jMJNjsUiRcHryRFOKW3usK2p7dX7Nb29SC7MYgUIclQDr7
# x+7N/jPlbsOECVUDJTnA6TVdZTGo9r+gCc0px7M2Mi7clfODwVrPi4326rMh+KTt
# HjEOtkwRq2ALpBIjIhejNmSCkQQS4KtvHstQBWG0QP9ZhnHR1TNpfKlzijjXZAzx
# aTCCBnEwggRZoAMCAQICCmEJgSoAAAAAAAIwDQYJKoZIhvcNAQELBQAwgYgxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jv
# c29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTEwMDcwMTIx
# MzY1NVoXDTI1MDcwMTIxNDY1NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCpHQ28dxGKOiDs/BOX
# 9fp/aZRrdFQQ1aUKAIKF++18aEssX8XD5WHCdrc+Zitb8BVTJwQxH0EbGpUdzgkT
# jnxhMFmxMEQP8WCIhFRDDNdNuDgIs0Ldk6zWczBXJoKjRQ3Q6vVHgc2/JGAyWGBG
# 8lhHhjKEHnRhZ5FfgVSxz5NMksHEpl3RYRNuKMYa+YaAu99h/EbBJx0kZxJyGiGK
# r0tkiVBisV39dx898Fd1rL2KQk1AUdEPnAY+Z3/1ZsADlkR+79BL/W7lmsqxqPJ6
# Kgox8NpOBpG2iAg16HgcsOmZzTznL0S6p/TcZL2kAcEgCZN4zfy8wMlEXV4WnAEF
# TyJNAgMBAAGjggHmMIIB4jAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU1WM6
# XIoxkPNDe3xGG8UzaFqFbVUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYD
# VR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/oolxi
# aNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3Nv
# ZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMu
# Y3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQw
# gaAGA1UdIAEB/wSBlTCBkjCBjwYJKwYBBAGCNy4DMIGBMD0GCCsGAQUFBwIBFjFo
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vUEtJL2RvY3MvQ1BTL2RlZmF1bHQuaHRt
# MEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAFAAbwBsAGkAYwB5AF8AUwB0
# AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQAH5ohRDeLG4Jg/
# gXEDPZ2joSFvs+umzPUxvs8F4qn++ldtGTCzwsVmyWrf9efweL3HqJ4l4/m87WtU
# VwgrUYJEEvu5U4zM9GASinbMQEBBm9xcF/9c+V4XNZgkVkt070IQyK+/f8Z/8jd9
# Wj8c8pl5SpFSAK84Dxf1L3mBZdmptWvkx872ynoAb0swRCQiPM/tA6WWj1kpvLb9
# BOFwnzJKJ/1Vry/+tuWOM7tiX5rbV0Dp8c6ZZpCM/2pif93FSguRJuI57BlKcWOd
# eyFtw5yjojz6f32WapB4pm3S4Zz5Hfw42JT0xqUKloakvZ4argRCg7i1gJsiOCC1
# JeVk7Pf0v35jWSUPei45V3aicaoGig+JFrphpxHLmtgOR5qAxdDNp9DvfYPw4Ttx
# Cd9ddJgiCGHasFAeb73x4QDf5zEHpJM692VHeOj4qEir995yfmFrb3epgcunCaw5
# u+zGy9iCtHLNHfS4hQEegPsbiSpUObJb2sgNVZl6h3M7COaYLeqN4DMuEin1wC9U
# JyH3yKxO2ii4sanblrKnQqLJzxlBTeCG+SqaoxFmMNO7dDJL32N79ZmKLxvHIa9Z
# ta7cRDyXUHHXodLFVeNp3lfB0d4wwP3M5k37Db9dT+mdHhk4L7zPWAUu7w2gUDXa
# 7wknHNWzfjUeCLraNtvTX4/edIhJEqGCAs4wggI3AgEBMIH4oYHQpIHNMIHKMQsw
# CQYDVQQGEwJVUzELMAkGA1UECBMCV0ExEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IEly
# ZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVT
# TjpGQzQxLTRCRDQtRDIyMDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# c2VydmljZaIjCgEBMAcGBSsOAwIaAxUADVHzUFx5NfnLW5cydXVScad6NGqggYMw
# gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUF
# AAIFAN8wqQ4wIhgPMjAxODA4MjkxMzA5MzRaGA8yMDE4MDgzMDEzMDkzNFowdzA9
# BgorBgEEAYRZCgQBMS8wLTAKAgUA3zCpDgIBADAKAgEAAgIlhQIB/zAHAgEAAgIR
# SzAKAgUA3zH6jgIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAow
# CAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBAGv6GIBQdH7U
# GAa1gVNWvXaSq6rdpG2A4sBJB4y3E1EB5krYpqpHTPJlHulxnp6lgo1X7oeEQ4MJ
# X3rxNCwb2Y08AYrFvD9s9itTDbHqo1zOKc3Eu7ScO0bdFYoIMTlPcs/8q+vsFIqy
# v/3jPD1LOqdnVYrq4CRdZvVg811y8s8rMYIDDTCCAwkCAQEwgZMwfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAADFdzGCFjtxVG8AAAAAAMUwDQYJYIZI
# AWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG
# 9w0BCQQxIgQg43ZXeVk3Q1V/WzHIdalKzlKgkQdwUmZvJWcNjPzzmrgwgfoGCyqG
# SIb3DQEJEAIvMYHqMIHnMIHkMIG9BCBLUK6woqXFe445fgnLcmNnGqAoOXVOinBx
# Kqk3qerMRDCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMz
# AAAAxXcxghY7cVRvAAAAAADFMCIEIN8YYMWJEZTXWk1pq1Lct7l2lfumpli3juhW
# nsoNsyrlMA0GCSqGSIb3DQEBCwUABIIBAGqjpq1KuJARrXAqo6sZykkaUADUWIXP
# 8Dzn8nb2EoXW6AMVByNTt8OxBpfY/jZ/qZQRXhDxlyGvDYBlZRzgeKEMtuxX3DN1
# wd2V4ngbVgYp5xuZAtcl/+Fp/AK9UOy+prvrKwQbCiXm3sowt+/h65amh9d4SXDu
# ll/KMdW3hHklYnNjAyCPdXaj+45OQO+UpjqoBa+W9LQsvQukFHS5bcGBxlv+sBdg
# Iyws0WySp1NwBOkztnd+tbJaybGbFkCaD2/+PAv30tgM8rlzbzGFTrkyhIhYWzni
# cS3SQ8zlxVaJSjszYtAZdtcaYbMc/nXLnqc54HGvO0Y7AW22scxztb8=
# SIG # End signature block
