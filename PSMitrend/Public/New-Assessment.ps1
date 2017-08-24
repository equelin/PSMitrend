<#
	.SYNOPSIS
	Create an assessment.
	.DESCRIPTION
	Create an assessment, which will provide a grouping for the files that will be uploaded.
	Returns an assessment identifier that is a mandatory parameter to later add file and submit the assessment.
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
	.EXAMPLE
	PS C:\>New-Assessment.ps1

	Submit a new assessment. Ask for all mandatory parameters.
	.EXAMPLE
	PS C:\>$Cred = Get-Credential
	PS C:\>$Tags = @(Tag1,Tag2)
	PS C:\>$Attributes = @{Attrib1 = 'Value1'; Attrib2 = 'Value2'}
	PS C:\>New-Assessment.ps1 -Credentials $cred -company Cheops -assessmentName Test -timezone EUROPE\Paris -city Nantes -country FR -Verbose -Tags toto -attributes $Attrib

	Submit a new assessment without prompting questions.
#>

Function New-Assessment {
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
		[string[]]$Tags
	)

	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

	# Mitrend API URL
	$apiBase="https://app.mitrend.com/api"

	#Ask for credential if not provided as parameters
	If (-not ($PSBoundParameters.ContainsKey('Credentials'))) {
		$Credentials = Get-Credential -Message 'Please enter your Mitrend credentials'
	}

	If ($Credentials) {

		#Build basic authentication header (Convert to base64)
		$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Credentials.username,$Credentials.GetNetworkCredential().Password)))

		#Build request body
		$body = @{}

		$body["company"] = $company

		$body["assessment_name"] = $assessmentName

		If ($PSBoundParameters.ContainsKey('city')) {
			$body["city"] = $city
		}

		If ($PSBoundParameters.ContainsKey('state')) {
			$body["state"] = $state
		}

		If ($PSBoundParameters.ContainsKey('country')) {
			$body["country"] = $country
		}

		If ($PSBoundParameters.ContainsKey('timezone')) {
			$EscapeTimezone = [uri]::EscapeDataString($timezone)
			$body["timezone"] = $EscapeTimezone
		}

		If ($PSBoundParameters.ContainsKey('attributes')) {
			$body["attributes"] = @{}
			$body["attributes"] = $attributes
		}

		If ($PSBoundParameters.ContainsKey('tags')) {
			$body["tags"] = @()
			$body["tags"] += $tags
		}

		# Convert $body to json data format. Has to do this to be able to provide tags et attributes params
		$Json = $body | ConvertTo-Json -Depth 10

		Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Request body: $Json"

		#Build Invoke-RestMethod parameters
		$Parameters = @{
			Uri = "$apiBase/assessments"
			ContentType = "application/json"
			Headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}
			Method = 'Post'
			Body = $Json
		}

		Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Request parameters: $($Parameters | Out-String)"

		# Send request
		try {
			$response =  Invoke-RestMethod @Parameters
		}
		catch [System.Net.WebException] {
			Throw $_
		}

		return $response

	} else {
		Throw "Please provide credentials"
	}
}
