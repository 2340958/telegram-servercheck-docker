#edit serverlist
$serverList='httpstat.us/200','httpstat.us/301','httpstat.us/307','httpstat.us/404','httpstat.us/500'
$port=443
#add botTocken and chatId
$botToken=""
$chatId=""

foreach ($server in $serverList)
{
    $HTTP_Request = [System.Net.WebRequest]::Create("https://"+$server)
    $HTTP_Response = $HTTP_Request.GetResponse()
    $HTTP_Status = [int]$HTTP_Response.StatusCode
    
    Write-Host $HTTP_Response
        If ($HTTP_Status -eq 200) {
            Write-Host "Site is OK!"
        }
        Else {
            Write-Host "The $server may be down, please check!"
            $postParams = @{chat_id=$chatId;disable_web_page_preview='true';text=$server+' down: '+$HTTP_Status}
            Invoke-WebRequest -Uri https://api.telegram.org/bot$botToken/sendMessage -Method POST -Body $postParams -TimeoutSec 60
        }
    If ($HTTP_Response -ne $null) { $HTTP_Response.Close() }
}
