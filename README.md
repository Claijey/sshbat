# sshbat
# Windows Stealth SSH & Persistence Toolkit

![Language](https://img.shields.io/badge/Language-Batchfile-blue?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Windows_10%2F11-0078D6?style=flat-square)
![Category](https://img.shields.io/badge/Category-Red_Team_%2F_Persistence-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Educational_Purpose-orange?style=flat-square)

## Disclaimer

**This tool is developed strictly for educational purposes, authorized red teaming simulations, and cybersecurity research.**

The developer is not responsible for any misuse or damage caused by this tool. Usage of this tool on systems without explicit permission from the owner is illegal and violates the Terms of Service of most platforms. **Do not use this for malicious purposes.**

---

##  About The Project

This project acts as an automated, stealthy deployment agent for **OpenSSH Server** on Windows environments. It is designed to establish persistence on a target machine by installing the official Microsoft OpenSSH feature, creating a hidden administrative backdoor, and modifying firewall rules without triggering standard user alerts.

It is specifically optimized for **low-bandwidth environments** using BITS (Background Intelligent Transfer Service) manipulation and features a **"Ghost Mode"** execution to remain invisible to the end-user.

##  Key Features

* ** Ghost Mode Execution:** Utilizes `mshta` and VBScript hooks to execute the payload completely in the background without a visible console window.
* ** BITS Network Accelerator:** Includes a PowerShell watchdog that forces Windows BITS download jobs into `FOREGROUND` priority, ensuring rapid installation even on slow connections.
* ** Hidden Administrative Account:** Creates a backdoor user (`systm`) and modifies the Windows Registry (`SpecialAccounts\UserList`) to hide it from the Logon UI and Control Panel.
* ** Firewall Evasion:** Instead of disabling the firewall (which triggers alerts), it injects a specific rule allowing TCP Port 22, masked under the name `"Windows Update Service"`.
* ** Smart Installation Loop:** The script verifies the actual installation of the `sshd` service before proceeding. It will not reboot or clean up until the service is confirmed to be present.
* ** Self-Destruct & Cleanup:** Automatically deletes the dropper script, temporary files, and performs a system reboot to apply UAC changes.

##  Installation & Usage

1.  Copy the `.bat` file to a USB drive or the target machine.
2.  Right-click and select **Run as Administrator**.
3.  **USB Dropper Mode:** The script will immediately copy itself to `%TEMP%` and detach from the original process. You can remove the USB drive immediately (within 1 second).
4.  The installation proceeds silently in the background. The system will reboot automatically once finished.

###  Default Credentials

After the reboot, the system will be accessible via SSH with the following credentials:

* **Username:** `systm`
* **Password:** `oursecurepass`
* **Status:** *Hidden (Invisible in Login Screen)*

```bash
ssh systm@<TARGET_IP>
