@echo off
:: Run as Administrator!

:: Folders to clean
set foldersToClean=C:\Windows\Temp %TEMP% C:\Windows\Prefetch C:\Windows\SoftwareDistribution\Download
echo Folders:
for %%F in (%foldersToClean%) do (
    echo - %%F
)

:: DISM system image repair
echo -> Repairing system image (DISM)...
DISM.exe /Online /Cleanup-Image /RestoreHealth

:: SFC system file integrity check
echo -> Checking system file integrity (SFC)...
sfc /scannow

:: DISM component cleanup
echo -> Cleaning up system components...
DISM.exe /Online /Cleanup-Image /StartComponentCleanup

:: Cleaning folders
for %%F in (%foldersToClean%) do (
    echo -> Cleaning %%F
    del /f /s /q "%%F\*.*" >nul 2>&1
    for /d %%D in ("%%F\*") do rd /s /q "%%D" >nul 2>&1
)

echo -> Enabling Storage Sense...
PowerShell -Command "New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Force | Out-Null; Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy' -Name '01' -Value 1"

echo Cleanup completed!
pause