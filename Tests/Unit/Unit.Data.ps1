$secpasswd = ConvertTo-SecureString 'Password123#' -AsPlainText -Force
$MockCredentials = New-Object System.Management.Automation.PSCredential ('MyUser', $secpasswd)

$MockAssessmentName = 'MyAssessment'
$MockCompany = 'MyCompany'
$MockAssessmentID = '12345'
$MockdeviceType = 'Unity'

$Global:RequestResponse = @"
{
    'id': '$MockAssessmentID',
    'assessment_name': '$MockAssessmentName',
    'company': '$MockCompany',
    'city': 'Marlborough',
    'state': 'MA',
    'country': 'US',
    'timez1': null,
    'status': 'Draft',
    'attributes': {
        'First Attribute': 'First Value',
        'Second Attribute': 'Second Value',
        'sfdc_account_id': 'MY_SALESFORCE_ID',
        'opportunity_number': 'MY_OPPORTUNITY_NUMBER'
    },
    'tags': [
        'FIRST TAG',
        'ANOTHER TAG'
    ],
    'files': []
}
"@ | ConvertFrom-JSON

$Global:FileResponse = @"
{
    'id': 54321,
    'deleted': false,
    'assessment_id': '$MockAssessmentID',
    'file': 'Unity.zip',
    'device_type': 'Unity'
}
"@ | ConvertFrom-JSON

$Global:SubmitResponse = @"
{
    'id': '$MockAssessmentID',
    'assessment_name': '$MockAssessmentName',
    'company': '$MockCompany',
    'city': 'Marlborough',
    'state': 'MA',
    'country': 'US',
    'timez1': null,
    'status': 'Submitted',
    'attributes': {
       'First Attribute': 'First Value',
       'Second Attribute': 'Second Value',
       'sfdc_account_id': 'MY_SALESFORCE_ID',
       'opportunity_number': 'MY_OPPORTUNITY_NUMBER'
    },
    'tags': [
       'FIRST TAG',
       'ANOTHER TAG'
    ],
    'files': [
       {
          'id': 54321,
          'deleted': false,
          'assessment_id': '$MockAssessmentID',
          'file': 'MyFile01.zip',
          'device_type': '$MockdeviceType'
       },
       {
          'id': 4532,
          'deleted': false,
          'assessment_id': '$MockAssessmentID',
          'file': 'MyFile02.zip',
          'device_type': '$MockdeviceType'
       }
    ]
 }
"@ | ConvertFrom-JSON
