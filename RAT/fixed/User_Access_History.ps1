# Friendly status message
Write-Host "Gathering user logon history (Event IDs 4625, 4648)..."

# 1. Define the event IDs to look for
$eventIDs = 4625, 4648

# 2. Use the modern, faster Get-WinEvent command.
#    - REMOVED the hard-coded "-ComputerName Dark-web"
#    - Filter for the specific Event IDs in the "Security" log
#    - This requires Admin rights, which the master script provides
$logonEvents = Get-WinEvent -LogName Security -FilterHashtable @{ID = $eventIDs} -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, ID, LevelDisplayName, Message -First 100 # Get the most recent 100 events

# 3. Pipe the results to ConvertTo-Html and save with a RELATIVE path
$logonEvents |
    ConvertTo-Html -Title "User Logon History (Failed & Explicit)" |
    Out-File -FilePath .\PS_AUDITY_OUTPUT\User_Access_History.html -Force

# 4. REMOVED Out-GridView

Write-Host "User logon history report saved."
