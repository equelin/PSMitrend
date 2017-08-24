<#
    .SYNOPSIS
    Handcraft the multipart/form-data body.
    .NOTES 
    https://stackoverflow.com/questions/25075010/upload-multiple-files-from-powershell-script
#>

Function New-MultipartForm {
    [CmdletBinding()]
    Param (
        [string]$file,
        [string]$deviceType
    )

    If (Test-Path $file) {

        $fileBin = [IO.File]::ReadAllBytes($file)
        
        $fileEnc = [System.Convert]::ToBase64String($fileBin)
        
        $boundary = [System.Guid]::NewGuid().ToString()
        
        $LF = "`r`n"
        $bodyLines = (
            "--$boundary",
            "content-transfer-encoding: base64",
            "Content-Disposition: form-data; content-transfer-encoding: `"base64`"; name=`"file`"; filename=`" [System.IO.Path]::GetFileName $file`"$LF",
            $fileEnc,
            "--$boundary",
            "Content-Disposition: form-data; name=`"device_type`"$LF",
            $deviceType,
            "--$boundary--$LF"
            ) -join $LF
        
        return $boundary,$bodyLines

    } else {
        Throw "Can't find file $file"
    }
}
