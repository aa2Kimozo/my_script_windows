@echo off
setlocal EnableDelayedExpansion

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script must be run as administrator.
    pause
    exit /b
)

::Set name form windows services
::Names of services without any _xyz
set static_services=

::Names of services with _xyz
set base_services=

::Loop static services
for %%S in (%static_services%) do (
    echo Attempting to stop service %%S...
    net stop "%%S" >nul 2>&1
    if !errorlevel! equ 0 (
        sc config "%%S" start= disabled >nul 2>&1
        echo Service %%S has been stopped and disabled.
        set "disabled_services=!disabled_services!%%S, "
    ) else (
        echo Failed to stop service %%S or it was already stopped.
    )
)

::Loop dynamic services using PowerShell
for %%B in (%base_services%) do (
    for /f "tokens=*" %%D in ('powershell -Command "Get-Service -Name '%%B*' | Where-Object { $_.Status -ne 'Stopped' } | ForEach-Object { $_.Name }" 2^>nul') do (
        echo Attempting to stop dynamic service %%D...
        net stop "%%D" >nul 2>&1
        if !errorlevel! equ 0 (
            sc config "%%D" start= disabled >nul 2>&1
            echo Service %%D has been stopped and disabled.
            set "disabled_services=!disabled_services!%%D, "
        ) else (
            echo Failed to stop service %%D or it was already stopped.
        )
    )
)

echo Summary:
if defined disabled_services (
    echo The following services were stopped and disabled:
    echo !disabled_services:~0,-2!
) else (
    echo No services were stopped or disabled.
)
pause >nul
