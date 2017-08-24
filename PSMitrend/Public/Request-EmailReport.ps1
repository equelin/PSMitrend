<#
	.SYNOPSIS
	Triggered the XML report bundle email.
	.DESCRIPTION
	Triggered the XML report bundle email. The email will be send to the one attached to the Mitrend account.
	.NOTES
	Written by Erwan Quelin under MIT licence - https://github.com/equelin/PSMitrend/blob/master/LICENSE
	.LINK
	https://github.com/equelin/PSMitrend
	.PARAMETER Credentials
	Mitrend Credential object.
	.PARAMETER Assessment
	Assessment ID
	.EXAMPLE
	PS C:\>Request-EmailReport -Assessment '123456'

	Triggered the XML report bundle email for assessment '123456'
#>

Function Request-EmailReport {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $false,HelpMessage = 'Credential object .')]
		[PSCredential]$Credentials,

		[Parameter(Mandatory = $false,HelpMessage = 'Assessment ID.')]
		[string]$Assessment
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

		#Build Invoke-RestMethod parameters
		$Parameters = @{
			Uri = "$apiBase/assessments/$Assessment/report"
			Headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}
			Method = 'Post'
		}

		Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Request parameters: $($Parameters | Out-String)"

		# Send request
		try {
			$response =  Invoke-RestMethod @Parameters
		}
		catch [System.Net.WebException] {
			Throw $_
		}

		return $response.data

	} else {
		Throw "Please provide credentials"
	}
}
