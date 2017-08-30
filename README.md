# PSMitrend
Powershell module for creating and submitting Mitrend assessments

# Requirements

- Powershell 4 (If possible get the latest version available)
- A valid Mitrend account

# Usage Instructions
### Install the module
```powershell
#Automated installation from the Powershell Gallery (Powershell 5):
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
    Get-Help Request-Assessment -Full #Get help for a specific command
    Get-Help PSMitrend
```

### How to submit an assessment

> You can find a more detailed script [here](./Examples/Assessment.ps1)

1- Follow the mitrend documentation to gather all relevant files

2- Open a Powershell console and import the PSMitrend module

```Powershell
> Import-Module PSMitrend
```

3- Get your Mitrend credentials

```Powershell
> $Credentials = Get-Credential
```

4- Request an assessment

```Powershell
> $Assessment = Request-Assessment -Credentials $Credentials -Company 'MyCompany' -AssessmentName 'MyAssessment' -DeviceType 'Unity' -File 'C:\Myfile.zip'
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
