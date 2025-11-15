# Friendly status message for the console
Write-Host "Gathering OS Details..."

# 1. Get OS information ONCE using the modern Get-CimInstance
#    and store it in a variable.
$osInfo = Get-CimInstance -ClassName win32_operatingsystem

# 2. Select ONLY the useful properties for a clean report
$osInfo | Select-Object Caption, CSName, Version, BuildNumber, OSArchitecture, RegisteredUser, Organization, LastBootUpTime, InstallDate, WindowsDirectory |
    
    # 3. Convert to HTML with a clean title
    ConvertTo-Html -Title "Operating System Details" |
    
    # 4. Use a RELATIVE path.
    #    This saves the file to the "PS_AUDITY_OUTPUT" folder 
    #    on the *same drive the script is running from* (your Pi).
    Out-File -FilePath .\PS_AUDITY_OUTPUT\OS_Details.html -Force

# 5. REMOVED "Out-GridView"
#    This is critical. Out-GridView halts the script and is not silent.

Write-Host "OS Details report saved."
