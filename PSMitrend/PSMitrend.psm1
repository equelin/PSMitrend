# To enable debugging - Import-Module path\to\Module -ArgumentList $true

param (
    [bool]$DebugModule = $false
)

#Get Class, public and private function definition files
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\ -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.name -like '*.ps1'})
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\ -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.name -like '*.ps1'})

#Dot source the files - idea from https://becomelotr.wordpress.com/2017/02/13/expensive-dot-sourcing/
Foreach($import in @($Public + $Private))
{
  If ($DebugModule) {
    Write-Verbose "Import file in debug mode: $($import.fullname)"
    . $import.fullname
  } Else {
    Try {
      Write-Verbose "Import file: $($import.fullname)"
      $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($import.fullname))), $null, $null)
    }
    Catch {
      Write-Error -Message "Failed to import file $($import.fullname): $_"
    }
  }
}

# Export public functions
Export-ModuleMember -Function $Public.Basename

