#Enter the Server URI for your SentinelOne Deployment
$serverURI = "https://MyDeployment.sentinelone.net" 
#Enter your API Token, generated from the SentinelOne Console
$userToken = "YOUR_API_TOKEN"
$apiRequest = "/web/api/v2.1/export/agents?operationalStatesNin=na,fully_disabled,partially_disabled,disabled_error,auto_fully_disabled"
$accountID = "YOUR_S1_ACCOUNT_ID" 
$path = "C:\S1-Reports\"
$apiThreats = "/web/api/v2.1/threats/export?createdAt__gt=2024-12-01T04:49:26.257525Z&confidenceLevelsNin=suspicious&incidentStatusesNin=resolved"

##Create Path for Storage of Output

If (!(test-path $path))
    {
        md $path
    }

Write-Host "Good Morning..."

Start-Sleep -Seconds .5

Read-Host -Prompt "Press Enter to Begin Data Collection"

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
        $apiCall = Invoke-RestMethod @params -OutFile $path\DatabaseStatus.csv
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

Write-Host "Collecting Database Status"

## The loop will run as long as $process is not 0 
$process = 1
While ($process -notlike 0) 
{
    ## This is the header information with authorization and parameters 
    ## If you change parameters for other calls, add that info here 
    $params = @{ Uri = ($serverURI + $apiThreats + $callFields + "&accountIds=" + $accountID) 
        Headers = @{'Authorization' = "APIToken $userToken"} 
        Method = 'GET' 
        ContentType = "application/json" } 

    try 
    { 
        ## This is the call to the API 
        $apiCall = Invoke-RestMethod @params -OutFile $path\UnresolvedThreats.csv
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

Write-Host "Collecting Unresolved Threats"

Start-Sleep -Seconds .6

$h = Import-Csv -Path "C:\S1-Reports\UnresolvedThreats.csv" | Select-Object -ExpandProperty Hash

Write-Host "Beginning VirusTotal Hash Check"

## Get your own VT API key here: https://www.virustotal.com/gui/join-us
    $VTApiKey = "YOUR_VirusTotal_API_key"

## Set TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Function submit-VTHash($VThash)
{
    $VTbody = @{resource = $VThash; apikey = $VTApiKey}
    $VTresult = Invoke-RestMethod -Method GET -Uri 'https://www.virustotal.com/vtapi/v2/file/report' -Body $VTbody

    return $vtResult
}

    if ($h) {$samples = $h}
    else    {$samples = @("ba4038fd20e474c047be8aad5bfacdb1bfc1ddbe12f803f473b7918d8d819436",
                          "614ca7b627533e22aa3e5c3594605dc6fe6f000b0cc2b845ece47ca60673ec7f")}
    foreach ($hash in $samples)
        {
            ## Set sleep value to respect API limits (4/min) - https://developers.virustotal.com/v3.0/reference#public-vs-premium-api
                if ($samples.count -ge 4) {$sleepTime = 15}
                else {$sleepTime = 1 }

                $VTresult = submit-VTHash($hash)
        
                if ($VTresult.positives -ge 1) {
                    $fore = "Magenta"
                    $VTpct = (($VTresult.positives) / ($VTresult.total)) * 100
                    $VTpct = [math]::Round($VTpct,2)
                }
                else {
                    $VTpct = 0
                }

            ## Display results
                Write-Host "==================="
                Write-Host -f Cyan "Resource    : " -NoNewline; Write-Host $VTresult.resource
                Write-Host -f Cyan "Scan date   : " -NoNewline; Write-Host $VTresult.scan_date
                Write-Host -f Cyan "Positives   : " -NoNewline; Write-Host $VTresult.positives
                Write-Host -f Cyan "Total Scans : " -NoNewline; Write-Host $VTresult.total
                Write-Host -f Cyan "Permalink   : " -NoNewline; Write-Host $VTresult.permalink
                Write-Host -f Cyan "Percent     : " -NoNewline; Write-Host $VTpct "%"
                
                Start-Sleep -seconds $sleepTime
        }

Read-Host -Prompt "Hash Report Fetched. Press Enter to Exit"
