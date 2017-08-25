# PSMitrend
Powershell module for creating and submitting Mitrend assessments

# Requirements

- Powershell 4 (If possible get the latest version available)
- A valid Mitrend account

# Usage Instructions
### Install the module
```powershell
#Automated installation (Powershell 5):
    Install-Module PSMitrend

# Or manual setup
    # Download the repository
    # Unblock the zip
    # Extract the PSMitrend folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

# Import the module
    Import-Module PSMitrend  #Alternatively, Import-Module \\Path\To\PSMitrend

# Get commands in the module
    Get-Command -Module PSMitrend

# Get help
    Get-Help New-Assessment -Full #Get help for a specific command
    Get-Help PSMitrend
```

### How to submit an assessment

> You can find a more detailed script [here](./Examples/Assessment.ps1)

1- Follow the mitrend documentation to gather all relevent files

2- Open a Powershell console and load the module

```Powershell
> Import-Module PSMitrend
```

3- Get your Mitrend credentials

```Powershell
> $Credentials = Get-Credential
```

4- Create an assessment

```Powershell
> $Assessment = New-Assessment -Credentials $Credentials -Company 'MyCompany' -AssessmentName 'MyAssessment'
```

5- Attach files to your assessment (This will upload the file to the Mitrend's servers)

```Powershell
> Send-File -Credentials $Credentials -Assessment $Assessment.id -DeviceType 'Unity' -File C:\Myfile.zip
```

6- Submit the assessment (You will not be able to attach new files after that)

```Powershell
> Submit-Assessment -Credentials $Credentials -Assessment $Assessment.id
```

7- If everything goes well, you should receive emails from Mitrend stating that they are processing the data

8- You can request Mitrend to send you an email with the assessment in xml format with the command `Request-EmailReport`. I you need powerpoint's reports, you will have to download them from the Mitrend website

```Powershell
> Request-EmailReport -Credentials $Credentials -Assessment $Assessment.id
```

# Author

**Erwan Quélin**
- <https://github.com/equelin>
- <https://twitter.com/erwanquelin>

# Special Thanks

- Mitrend for providing [powershell's script examples ](https://github.com/Mitrend/APISamples/blob/master/createAssessment.ps1)

# License

Copyright 2016-2017 Erwan Quelin and the community.

Licensed under the MIT License.
