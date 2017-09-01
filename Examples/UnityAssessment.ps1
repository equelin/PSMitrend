#Requires -Modules PSMitrend,Unity-Powershell

<#
	.SYNOPSIS
	Complete script for generating an Dell EMC Unity data collection file and use it for submitting a Mitrend assessment.
	.NOTES
	Written by Erwan Quelin under MIT licence - https://github.com/equelin/PSMitrend/blob/master/LICENSE
	.LINK
	https://github.com/equelin/PSMitrend
#>

[CmdletBinding()]
Param ()

####### UNITY INFORMATIONS #######
#Credentials
$UnityUsername = 'MyUnityUsername'
$UnityPassword = 'MyUnityPassword'

#Unity IP / FQDN
$Unity = 'unity.example.com'

#File path
$FilePath = 'C:\'

####### MITREND INFORMATIONS #######
#Mitrend Credentials
$Username = 'MyMitrendUsername'
$Password = 'MyMitrendPassword'

#Assessment details
$Company = 'MyCompany'
$AssessmentName = 'MyAssessment'
$City = 'Paris'
$Country = 'FR'
$Timezone = 'EUROPE/Paris'
$Attributes = @{
    RequestID = 'InternalID'
    RequestPurpose = 'Monthly Assessment'
}
$Tags = @(
    'MyTag1',
    'MyTag2'
)

#Assessment device type
$DeviceType = 'Unity'

####### Script ########

## UNITY
# Build Unity credentials object
$Unitysecpasswd = ConvertTo-SecureString $UnityPassword -AsPlainText -Force
$UnityCredentials = New-Object System.Management.Automation.PSCredential ($UnityUsername, $Unitysecpasswd)

Write-Host "[Unity] Connecting to Unity $Unity"
Try {
    $Session = Connect-Unity -Server $Unity -Credentials $UnityCredentials
}
catch {
    Throw $_
}


#Generate a new Unity data collection bundle
Write-Host "[Unity] Generating data collection file"
Try {
    $OutFile = Save-UnityDataCollectionResult -Session $Session -dataCollectionProfile 'Performance_Trace' -Path $FilePath -Compress -Confirm:$false
}
Catch {
    Throw $_
}

If (Test-Path $OutFile) {
    ## MITREND
    #Build Mitrend credentials object
    $secpasswd = ConvertTo-SecureString $MitrendPassword -AsPlainText -Force
    $MitrendCredentials = New-Object System.Management.Automation.PSCredential ($MitrendUsername, $secpasswd)

    #Create a new assessment
    Write-Host "[Mitrend] Creating a new assessment"
    Try {
        Request-Assessment -Credentials $MitrendCredentials -Company $Company -AssessmentName $AssessmentName -City $City -Timezone $Timezone -Attributes $Attributes -Tags $Tags -DeviceType $DeviceType -File $OutFile
    }
    Catch {
        Throw $_
    }
}

Write-Host "[Unity] Disconnecting from Unity $Unity"
Disconnect-unity -Session $Session -Confirm:$false



