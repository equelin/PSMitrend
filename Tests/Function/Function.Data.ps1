$Data = @{}

$Data.function1 = @{
    Name = 'New-Assessment'
    Parameters = @(
        @{'Name' = 'Credentials'; 'type' = 'PSCredential'},
        @{'Name' = 'Company'; 'type' = 'string'},
        @{'Name' = 'AssessmentName'; 'type' = 'string'},
        @{'Name' = 'City'; 'type' = 'string'},
        @{'Name' = 'State'; 'type' = 'string'},
        @{'Name' = 'Country'; 'type' = 'string'},
        @{'Name' = 'Timezone'; 'type' = 'string'},
        @{'Name' = 'Attributes'; 'type' = 'Hashtable'},
        @{'Name' = 'Tags'; 'type' = 'string[]'}
    )
}

$Data.function2 = @{
    Name = 'Request-EmailReport'
    Parameters = @(
        @{'Name' = 'Credentials'; 'type' = 'PSCredential'},
        @{'Name' = 'Assessment'; 'type' = 'string'}
    )
}

$Data.function3 = @{
    Name = 'Send-File'
    Parameters = @(
        @{'Name' = 'Credentials'; 'type' = 'PSCredential'},
        @{'Name' = 'Assessment'; 'type' = 'string'},
        @{'Name' = 'DeviceType'; 'type' = 'string'},
        @{'Name' = 'File'; 'type' = 'string'}
    )
}

$Data.function4 = @{
    Name = 'Submit-Assessment'
    Parameters = @(
        @{'Name' = 'Credentials'; 'type' = 'PSCredential'},
        @{'Name' = 'Assessment'; 'type' = 'string'}
    )
}

$Data.function1 = @{
    Name = 'Request-Assessment'
    Parameters = @(
        @{'Name' = 'Credentials'; 'type' = 'PSCredential'},
        @{'Name' = 'Company'; 'type' = 'string'},
        @{'Name' = 'AssessmentName'; 'type' = 'string'},
        @{'Name' = 'City'; 'type' = 'string'},
        @{'Name' = 'State'; 'type' = 'string'},
        @{'Name' = 'Country'; 'type' = 'string'},
        @{'Name' = 'Timezone'; 'type' = 'string'},
        @{'Name' = 'Attributes'; 'type' = 'Hashtable'},
        @{'Name' = 'Tags'; 'type' = 'string[]'}
        @{'Name' = 'DeviceType'; 'type' = 'string'},
        @{'Name' = 'File'; 'type' = 'string[]'}
    )
}





