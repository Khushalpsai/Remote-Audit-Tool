# Friendly status message
Write-Host "Gathering USB storage device history..."

# This C# code is necessary to read registry key last-write-times
add-type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class advapi32 {
    [DllImport("advapi32.dll", CharSet = CharSet.Auto)]
    public static extern Int32 RegQueryInfoKey(
        Microsoft.Win32.SafeHandles.SafeRegistryHandle hKey,
        StringBuilder lpClass,
        Int32 lpCls, Int32 spare, Int32 subkeys,
        Int32 skLen, Int32 mcLen, Int32 values,
        Int32 vNLen, Int32 mvLen, Int32 secDesc,
        out System.Runtime.InteropServices.ComTypes.FILETIME lpftLastWriteTime
    );
}
"@

# This helper function uses the C# code
function getRegTime($regPath) {
    try {
        $reg = Get-Item $regPath -Force -ErrorAction Stop
        if ($reg.handle) {
            $time = New-Object System.Runtime.InteropServices.ComTypes.FILETIME
            $result = [advapi32]::RegQueryInfoKey($reg.Handle, $null, 0, 0, 0, 0, 0, 0, 0, 0, 0, [ref]$time)
            if ($result -eq 0) {
                $timeValue = [uint64]$time.dwHighDateTime -shl 32 -bor ($time.dwLowDateTime -bor [uint32]0)
                return [datetime]::FromFileTime($timeValue)
            }
        }
    }
    catch {
        # Write-Host "Could not read time for $regPath"
        return $null # Return null if key is protected or doesn't exist
    }
}

# 1. REMOVED all the SetThreadToken / privilege elevation code.
#    The master script handles this with "RunAs".

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR"
if (-Not(Test-Path $regPath)) {
    Write-Host "No USB mass storage history found in registry."
    exit
}

$guid = "{83da6326-97a6-4088-9453-a1923f573b29}"

# 2. Collect all device info as objects in a variable
$usbHistory = foreach ($pnpId in Get-Item "$regPath\*\*") {
    $displayName = $pnpId.GetValue("FriendlyName")
    $property = $pnpId.psPath + "\Properties\$guid"

    $installed = getRegTime "$property\0064"
    $connect = getRegTime "$property\0066"
    $disconnect = getRegTime "$property\0067"

    $status = "Disconnected"
    if ($disconnect -eq $connect) { $status = "Currently Connected" }

    # 3. Output a PSCustomObject instead of printing text
    [PSCustomObject]@{
        DeviceName   = $displayName
        Status       = $status
        Installed    = $installed
        FirstConnected = $connect
        LastConnected  = $disconnect
    }
}

# 4. Pipe the collected objects to ConvertTo-Html and save with a RELATIVE path
$usbHistory |
    ConvertTo-Html -Title "USB Storage Device History" |
    Out-File -FilePath .\PS_AUDITY_OUTPUT\USB_History.html -Force

Write-Host "USB storage history saved."
