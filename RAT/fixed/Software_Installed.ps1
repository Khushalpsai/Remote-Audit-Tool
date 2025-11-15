# Friendly status message
Write-Host "Gathering Installed Software list (this may take a moment)..."

# 1. Define the 32-bit and 64-bit registry paths to check
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# 2. Run the query ONCE and store the results in a variable
$installedSoftware = Get-ItemProperty $registryPaths -ErrorAction SilentlyContinue |
    Where-Object DisplayName | # Filter out entries without a name
    Select-Object DisplayName, Publisher, DisplayVersion, InstallDate, @{Name="LastModified"; Expression={ (Get-Item $_.PsPath).LastWriteTime }} |
    Sort-Object DisplayName # Sort by name, as you had in your comments

# 3. REMOVED the Out-GridView command.
#    The first block that ended in | Out-GridView; has been deleted.

# 4. Pipe the stored results directly to your HTML report
$installedSoftware |
    ConvertTo-Html -Title "Installed Software Report" |
    
    # 5. Use the RELATIVE path to save the file
    Out-File -FilePath .\PS_AUDITY_OUTPUT\Software_Installed.html -Force

Write-Host "Installed Software report saved."
