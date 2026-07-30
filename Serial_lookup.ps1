$serverURI = "https://usea1-018.sentinelone.net" 
$userToken = "ADD_YOUR_API_TOKEN"
$accountID = "ADD_YOUR_ACCOUNT_ID" 
$serial = Read-Host "Please Supply Serial to Check"

$apiRequest = "/web/api/v2.1/export/agents?serialNumber__contains=$serial"

## The loop will run as long as $process is not 0 
$process = 1
While ($process -notlike 0) 
{
    ## This is the header information with authorization and parameters 
    ## If you change parameters for other calls, add that info here 
    $params = @{ Uri = ($serverURI + $apiRequest + $callFields + "&accountIds=" + $accountID) 
        Headers = @{'Authorization' = "APIToken $userToken"} 
        Method = 'GET' 
        ContentType = "application/json" } 

    try 
    { 
        ## This is the call to the API 
        $apiCall = Invoke-RestMethod @params
        Write-Host $apiCall 
        $process = 0 
    } 

    Catch 
    { 
        ## This is the message that will be seen if the API call fails 
        Write-Host "An Error occurred while pulling  SentinelOne data" 
        Write-Host $_ 
        $process = 0 
    } 
}

Read-Host "Press Enter to Exit"
