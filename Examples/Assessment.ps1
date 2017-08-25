#Require PSMitrend

<#
	.SYNOPSIS
	Example for creating a Mitrend assessment in Powershell with module PSMitrend
	.NOTES
	Written by Erwan Quelin under MIT licence - https://github.com/equelin/PSMitrend/blob/master/LICENSE
	.LINK
	https://github.com/equelin/PSMitrend
#>

[CmdletBinding()]
Param ()

#Mitrend Credentials
$Username = 'MyMitrendUsername'
$Password = 'MyMitrendPassword'

#Assessment details
$Company = 'MyCompany'
$AssessmentName = 'MyAssessment'
$City = 'Paris'
$Timezone = 'EUROPE/Paris'
$Attributes = @{
    RequestID = 'InternalID'
    RequestPurpose = 'Monthly Assessment'
}
$Tags = @(
    'MyTag1',
    'MyTag2'
)

#Assessment file
$File = C:\MyFile.zip
$DeviceType = 'Unity'

####### Script ########

#Build credentials object
$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)

#Create a new assessment
Write-Host "Create a new assessment"
$Assessment = New-Assessment -Credentials $Credentials -Company $Company -AssessmentName $AssessmentName -City $City -Timezone $Timezone -Attributes $Attributes -Tags $Tags

#Test if everything works well
If ($Assessment) {

    #Attach file to assessment
    Write-Host "Attach file: $File to assessment: $($Assessment.id)"
    Send-File -Credentials $Credentials -Assessment $Assessment.id -DeviceType $DeviceType -File $File

    #Submit the assessment
    Write-Host "Submit assessment: $($Assessment.id)"
    Submit-Assessment -Credentials $Credentials -Assessment $Assessment.id
} else {
    Throw "Error while creating an assessment."
}

