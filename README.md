# PS-Audity: Raspberry Pi Powered System Auditor

PS-Audity is a portable, modular PowerShell forensic suite designed to be deployed via a Raspberry Pi USB Gadget (or standard flash drive). It automates the collection of critical system data — including network history, installed software, and USB device logs — running entirely from the external drive without installing agents on the target machine.

Designed for system administrators and security auditors, this tool captures the state of a Windows machine and exports zero-dependency HTML reports in seconds.

## Key Features

- **Plug and Play Audit:** Designed to run from a Raspberry Pi configured as a Mass Storage Gadget.
- **One-Click Execution:** The master script (`run-audit.ps1`) bypasses execution policies locally and orchestrates all sub-modules.
- **Live Network Forensics:** Snapshots active TCP/IP connections and maps them to specific executables using `netstat`.
- **Advanced USB Forensics:** Uses inline C# injection to parse the Registry (USBSTOR) and calculate exact connect/disconnect timestamps for previously attached storage devices.
- **WLAN History:** Extracts the native Windows Wi-Fi report to show past network connections.
- **Zero Footprint:** Outputs all data to an HTML folder on the external drive; leaves no permanent software on the target.

## Repository Structure
/
├── run-audit.ps1            # Master controller script
├── OS_Details.ps1           # Gathers OS version, build, and owner info
├── Software_Installed.ps1   # Scans Registry for installed applications
├── Network_History.ps1      # Captures adapter status & WLAN history
├── Background_Process.ps1   # Maps active network connections to processes
├── User_Access_History.ps1  # Audits Security Event Log for login attempts
├── USB_device_history.ps1   # Forensic analysis of USB usage
└── PS_AUDITY_OUTPUT/        # (Created at runtime) Contains HTML reports

## Hardware Setup (Raspberry Pi)

To use this effectively as a portable gadget:

1. **Configure Pi as Mass Storage:** Set up your Raspberry Pi (Zero W or 4) to act as a USB Mass Storage Gadget using the `g_mass_storage` module.
2. **Create Backing File:** Create a container file (e.g., `usb.bin`) on the Pi and format it as NTFS or exFAT so Windows can read it.
3. **Load Payload:** Mount the container image locally on the Pi and copy all `.ps1` files from this repository into the root of the image.
4. **Deploy:** Connect the Pi to the target PC via the USB data port. It will appear as a standard USB drive.

> This suite also works on a standard USB flash drive.

## Usage

1. Insert the Raspberry Pi (or USB drive) into the target Windows machine.
2. Navigate to the drive in File Explorer.
3. Right-click `run-audit.ps1` and select **Run with PowerShell**.

> **Note:** Administrator privileges are required to access Security Event Logs and specific `netstat` flags.

The script will automatically:

- Set the Execution Policy to Bypass for the current process.
- Create the output directory `.\PS_AUDITY_OUTPUT`.
- Execute all audit modules sequentially.

Wait for the message **"AUDIT COMPLETE. All reports saved."**, then open the `PS_AUDITY_OUTPUT` folder to view the HTML reports.

## Generated Reports

| File | Description |
|---|---|
| `OS_Details.html` | System architecture, boot time, and owner info |
| `Software_Installed.html` | Full inventory of installed applications and versions |
| `Network_Connections.html` | Active connections mapped to PIDs and executables |
| `Network_History.html` | Adapter status and historical Wi-Fi connections |
| `USB_History.html` | Timeline of every USB storage device ever connected to the host |
| `User_Access_History.html` | Recent failed login attempts and explicit credential usage (Event IDs 4625, 4648) |

## Disclaimer

This tool is intended for authorized system administration, auditing, and educational purposes only. The user is responsible for ensuring they have permission to audit the target machine.

## License

This project is licensed under the MIT License.
