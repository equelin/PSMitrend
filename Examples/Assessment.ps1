#Require PSMitrend

<#
	.SYNOPSIS
	Example for creating a Mitrend assessment in Powershell with module PSMitrend.
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

#Assessment file
$File = C:\MyFile.zip
$DeviceType = 'Unity'

####### Script ########

#Build credentials object
$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)

#Create a new assessment
Try {
    Request-Assessment -Credentials $Credentials -Company $Company -AssessmentName $AssessmentName -City $City -Timezone $Timezone -Attributes $Attributes -Tags $Tags -File $File -DeviceType $DeviceType
}
Catch {
    Throw "Error while creating an assessment."
}

