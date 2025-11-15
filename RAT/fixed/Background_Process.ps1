# Friendly status message
Write-Host "Gathering active network connections (netstat)..."
Write-Host "(This command requires Admin rights, which the master script should provide)"

# 1. Run the netstat command.
#    Note: -b (show executable) requires this script to be run as Administrator.
$netstatOutput = netstat -aonb

# 2. Convert the text output to an HTML fragment.
#    We use <pre> tags to preserve the formatting.
$htmlFragment = "<pre>$($netstatOutput | Out-String)</pre>"

# 3. Save it to an HTML file using a RELATIVE path
#    (I'm renaming the output file to be more accurate)
New-Item -Path ".\PS_AUDITY_OUTPUT\Network_Connections.html" -ItemType File -Value $htmlFragment -Force

# 4. REMOVED Out-GridView

Write-Host "Network Connections report saved."
