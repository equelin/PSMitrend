<#
	.SYNOPSIS
	Create an assessment.
	.DESCRIPTION
	Create an assessment, attache files to it and submit it.
	.NOTES
	Written by Erwan Quelin under MIT licence - https://github.com/equelin/PSMitrend/blob/master/LICENSE
	.LINK
	https://github.com/equelin/PSMitrend
	.PARAMETER Credentials
	Mitrend Credential object.
	.PARAMETER Company
	The name of the company being assessed.
	.PARAMETER AssessmentName
	The name of the assessment.
	.PARAMETER City
	The city of customer being assessed.
	.PARAMETER State
	The state of the customer being assessed. Use 2 letter code.
	.PARAMETER Country
	The country of the customer being assessed. Use 2 letter code.
	.PARAMETER Timezone
	The timezone of the customer being assessed.
	.PARAMETER Attributes
	An hashtable representing any extra attributes.
	.PARAMETER Tags
	A list of strings to use as tags for this assessment.
	.PARAMETER DeviceType
    Device Type.
	.PARAMETER File
	Path to the file to upload.
	.EXAMPLE
	PS C:\>Request-Assessment

	Submit a new assessment. Ask for all mandatory parameters.
	.EXAMPLE
	PS C:\> $Cred = Get-Credential
	PS C:\> $Tags = @(Tag1,Tag2)
	PS C:\> $Attributes = @{Attrib1 = 'Value1'; Attrib2 = 'Value2'}
	PS C:\> $File = 'C:\Unity.zip'
	PS C:\> $deviceType = 'Unity'
	PS C:\> Request-Assessment -Credentials $cred -company 'MyCompany' -assessmentName 'Test' -timezone EUROPE\Paris -city 'Paris' -country 'FR' -Tags $Tags -attributes $Attrib -File $File -deviceType $deviceType

	Submit a new assessment without prompting questions (except for credentials).
#>

Function Request-Assessment {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $false,HelpMessage = 'Credential object .')]
		[PSCredential]$Credentials,

		[Parameter(Mandatory = $true,HelpMessage = 'The name of the company being assessed.')]
		[string]$Company,

		[Parameter(Mandatory = $true,HelpMessage = 'The name of the assessment.')]
		[string]$AssessmentName,

		[Parameter(Mandatory = $false,HelpMessage = 'The city of customer being assessed.')]
		[string]$City,

		[Parameter(Mandatory = $false,HelpMessage = 'The state of the customer being assessed. Use 2 letter code.')]
		[string]$State,

		[Parameter(Mandatory = $false,HelpMessage = 'The country of the customer being assessed. Use 2 letter code.')]
		[string]$Country,

		[Parameter(Mandatory = $false,HelpMessage = 'The timezone of the customer being assessed.')]
		[string]$Timezone,

		[Parameter(Mandatory = $false,HelpMessage = 'An hashtable representing any extra attributes.')]
		[System.Collections.Hashtable]$Attributes,

		[Parameter(Mandatory = $false,HelpMessage = 'A list of strings to use as tags for this assessment.')]
        [string[]]$Tags,

		[Parameter(Mandatory = $true,HelpMessage = 'Type of device.')]
        [validateset('ArcServe', 'Avamar', 'Backup_Exec', 'Clariion', 'CommVault', 'Compellent', 'Data Analyzer', 'Data Domain', 'Data_Protector', 'DD_AutoSupports', 'DPM', 'EMC_Grab', 'EqualLogic', 'HDS', 'HDS_AMS', 'HP_3PAR', 'HP_EVA', 'IBM_DS', 'IBM_Storage', 'IBM_v7000', 'IBM_XIV', 'IOSTAT', 'Isilon', 'Mitrend', 'Scanner', 'NetApp', 'NetBackup', 'NetWorker', 'Oracle_AWR', 'Oracle_RMAN', 'PerfCollect', 'RecoverPoint', 'SAN_Health', 'Symmetrix', 'TSM', 'Unity', 'Veeam', 'VMware', 'VNX_File', 'VNX_Skew', 'VPLEX', 'XtremIO')]
        [string]$DeviceType,

		[Parameter(Mandatory = $true,HelpMessage = 'Path to the file(s) to upload.')]
		[ValidateScript({Foreach ($f in $_) {Test-Path $f}})]
		[string[]]$File
	)

	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

	#Ask for credential if not provided as parameters
	If (-not ($PSBoundParameters.ContainsKey('Credentials'))) {
		$Credentials = Get-Credential -Message 'Please enter your Mitrend credentials'
	}

	If ($Credentials) {

		#Build request body
		$AssessmentParameters = @{}

		$AssessmentParameters["Credentials"] = $Credentials

		$AssessmentParameters["company"] = $company

		$AssessmentParameters["assessmentName"] = $assessmentName

		If ($PSBoundParameters.ContainsKey('city')) {
			$AssessmentParameters["city"] = $city
		}

		If ($PSBoundParameters.ContainsKey('state')) {
			$AssessmentParameters["state"] = $state
		}

		If ($PSBoundParameters.ContainsKey('country')) {
			$AssessmentParameters["country"] = $country
		}

		If ($PSBoundParameters.ContainsKey('timezone')) {
			$EscapeTimezone = [uri]::EscapeDataString($timezone)
			$AssessmentParameters["timezone"] = $EscapeTimezone
		}

		If ($PSBoundParameters.ContainsKey('attributes')) {
			$AssessmentParameters["attributes"] = @{}
			$AssessmentParameters["attributes"] = $attributes
		}

		If ($PSBoundParameters.ContainsKey('tags')) {
			$AssessmentParameters["tags"] = @()
			$AssessmentParameters["tags"] += $tags
		}

		Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Assessment parameters: $($AssessmentParameters | Out-String)"

		#Create a new assessment
		Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Creating a new assessment"
		$Assessment = New-Assessment @AssessmentParameters

		#Test if everything works well
		If ($Assessment) {

			#Attach file(s) to assessment
			Foreach ($F in $File) {
				Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Attach file: $F to assessment: $($Assessment.id)"
				Send-File -Credentials $Credentials -Assessment $Assessment.id -DeviceType $DeviceType -File $F | Out-Null
			}

			#Submit the assessment
			Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Submit assessment: $($Assessment.id)"
			Submit-Assessment -Credentials $Credentials -Assessment $Assessment.id

		} else {
			Throw "Error while creating an assessment."
		}
    }
}
