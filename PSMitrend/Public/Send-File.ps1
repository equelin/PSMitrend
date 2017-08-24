<#
	.SYNOPSIS
	Attache input file to an assessment.
	.DESCRIPTION
	Attache input file to an assessment.
	.NOTES
	Written by Erwan Quelin under MIT licence - https://github.com/equelin/PSMitrend/blob/master/LICENSE
	.LINK
	https://github.com/equelin/PSMitrend
	.PARAMETER Credentials
	Mitrend Credential object.
	.PARAMETER Assessment
    Assessment ID.
    .PARAMETER DeviceType
    Device Type.
	.PARAMETER File
	Path to the file to upload.
	.EXAMPLE
	PS C:\>Send-File -Assessment '123456' -DeviceType 'Unity -File C:\myfile.zip

	Attach file myfile.zip to assessment '123456'
#>

Function Send-File {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $false,HelpMessage = 'Credential object .')]
		[PSCredential]$Credentials,

		[Parameter(Mandatory = $true,HelpMessage = 'Assessment ID.')]
		[string]$Assessment,

		[Parameter(Mandatory = $true,HelpMessage = 'Device Type')]
		[validateset('ArcServe', 'Avamar', 'Backup_Exec', 'Clariion', 'CommVault', 'Compellent', 'Data Analyzer', 'Data Domain', 'Data_Protector', 'DD_AutoSupports', 'DPM', 'EMC_Grab', 'EqualLogic', 'HDS', 'HDS_AMS', 'HP_3PAR', 'HP_EVA', 'IBM_DS', 'IBM_Storage', 'IBM_v7000', 'IBM_XIV', 'IOSTAT', 'Isilon', 'Mitrend', 'Scanner', 'NetApp', 'NetBackup', 'NetWorker', 'Oracle_AWR', 'Oracle_RMAN', 'PerfCollect', 'RecoverPoint', 'SAN_Health', 'Symmetrix', 'TSM', 'Unity', 'Veeam', 'VMware', 'VNX_File', 'VNX_Skew', 'VPLEX', 'XtremIO')]
		[string]$DeviceType,

		[Parameter(Mandatory = $true,HelpMessage = 'Path to the file to upload.')]
		[ValidateScript({Test-Path $_})]
		[string]$File
	)

	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] Executing function"
	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
	Write-Debug -Message "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

	#Mitrend API URL
	$apiBase="https://app.mitrend.com/api"

	#Ask for credential if not provided as parameters
	If (-not ($PSBoundParameters.ContainsKey('Credentials'))) {
		$Credentials = Get-Credential -Message 'Please enter your Mitrend credentials'
	}

	If ($Credentials) {

		#Build basic authentication header (Convert to base64)
		$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Credentials.username,$Credentials.GetNetworkCredential().Password)))

		#Get $file full path
		$FileFullpath = Get-ChildItem $File

		#Create multipart form for uploading file
		$boundary,$bodyLines = New-MultipartForm -file $FileFullpath.FullName -deviceType $deviceType

		#Build Invoke-RestMethod parameters
		$Parameters = @{
			Uri = "$apiBase/assessments/$Assessment/files"
			ContentType = "multipart/form-data; boundary=`"$boundary`""
			Headers = @{Authorization=("Basic {0}" -f $base64AuthInfo)}
			Method = 'Post'
			TimeoutSec = 3600
			Body = $bodyLines
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
