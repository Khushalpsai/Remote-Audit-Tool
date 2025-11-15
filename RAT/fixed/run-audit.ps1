# -----------------------------------------------------------------
# MASTER AUDIT SCRIPT (run_audit.ps1)
# -----------------------------------------------------------------
# This script is called by the USB gadget.
# It runs all other audit scripts in order.
# -----------------------------------------------------------------

# 1. Set Execution Policy just for this session
# This ensures all our other scripts can run.
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# 2. Find the script's own location
# $PSScriptRoot is an automatic variable that means "the folder this script is in"
$AuditDrive = $PSScriptRoot
Set-Location $AuditDrive

# 3. Create the output directory
# The -Force command prevents errors if the folder already exists.
$ReportFolder = ".\PS_AUDITY_OUTPUT"
New-Item -ItemType Directory -Path $ReportFolder -Force | Out-Null

Write-Host "-------------------------------"
Write-Host "STARTING SYSTEM AUDIT..."
Write-Host "Saving reports to $ReportFolder"
Write-Host "-------------------------------"

# 4. Run all of your audit scripts one by one
# Each script will print its "Write-Host" status message here.

.\OS_Details.ps1
.\Software_Installed.ps1
.\Network_History.ps1
.\Background_Process.ps1
.\User_Access_History.ps1
.\USB_device_history.ps1

# (We do NOT call WIFI_History.ps1 because Network_History.ps1 already does its job)

Write-Host "-------------------------------"
Write-Host "AUDIT COMPLETE."
Write-Host "All reports saved."
Write-Host "This window will close in 10 seconds."
Write-Host "-------------------------------"

# 5. Pause at the end so the user can see it's finished.
Start-Sleep 10
exit
