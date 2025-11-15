# Friendly status message
Write-Host "Gathering network adapter status..."

Param(
    [string]$computer = $env:COMPUTERNAME
)

# Helper function to convert status codes to human-readable text
function Get-StatusFromValue {
    Param($SV)
    switch ($SV) {
        0 { "Disconnected" }
        1 { "Connecting" }
        2 { "Connected" }
        3 { "Disconnecting" }
        4 { "Hardware not present" }
        5 { "Hardware disabled" }
        6 { "Hardware malfunction" }
        7 { "Media disconnected" }
        8 { "Authenticating" }
        9 { "Authentication succeeded" }
        10 { "Authentication failed" }
        11 { "Invalid Address" }
        12 { "Credentials Required" }
        Default { "Not connected" }
    }
} #end Get-StatusFromValue function

# 1. Get adapter status, convert to HTML, and save to RELATIVE path
Get-WmiObject -Class win32_networkadapter -computer $computer |
    Select-Object Name, @{LABEL = "Status"; EXPRESSION = { Get-StatusFromValue $_.NetConnectionStatus } } |
    ConvertTo-Html -Title "Network Adapter Status" |
    Out-File -FilePath .\PS_AUDITY_OUTPUT\Network_History.html -Force

# 2. REMOVED the first Out-GridView

Write-Host "Network Adapter report saved."
Write-Host "Generating WLAN (Wi-Fi) history report..."

# 3. Generate the system's WLAN report. REMOVED Out-GridView
netsh wlan show wlanreport duration="30" | Out-Null

# Give the system a moment to generate the file
Start-Sleep -Seconds 2

# 4. COPY the generated report to your audit folder
#    The original script just tried to open the file, which is not silent.
$sourceReport = "C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html"
$destinationReport = ".\PS_AUDITY_OUTPUT\WLAN_Report.html"

if (Test-Path $sourceReport) {
    Copy-Item -Path $sourceReport -Destination $destinationReport -Force
    Write-Host "WLAN (Wi-Fi) report successfully copied."
}
else {
    Write-Host "Could not find WLAN report. (This is normal for PCs without Wi-Fi)."
}
