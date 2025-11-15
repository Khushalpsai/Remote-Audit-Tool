$config = Get-Content "config.json" | ConvertFrom-Json
$serverUrl = $config.server_url
$clientId = $config.client_id

$login_history    = .\scripts\login_history.ps1
$usb_history      = .\scripts\usb_history.ps1
$network_info     = .\scripts\network_info.ps1
$software_list    = .\scripts\software_list.ps1
$process_list     = .\scripts\process_list.ps1
$os_details       = .\scripts\os_details.ps1
$ports_list       = .\scripts\ports_list.ps1

$result = @{
    client_id      = $clientId
    hostname       = $env:COMPUTERNAME
    timestamp      = (Get-Date).ToString("s")
    login_history  = $login_history
    usb_history    = $usb_history
    network_info   = $network_info
    software_list  = $software_list
    process_list   = $process_list
    os_details     = $os_details
    ports_list     = $ports_list
}

$json = $result | ConvertTo-Json
Invoke-RestMethod -Uri $serverUrl -Method Post -Body $json -ContentType "application/json"