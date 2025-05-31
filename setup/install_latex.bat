@echo off
setlocal enabledelayedexpansion

echo ========================================
echo LaTeX Environment Installation Script
echo ========================================
echo This script will install MiKTeX for LaTeX compilation
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as Administrator - Good!
) else (
    echo Note: You may need administrator privileges for some installations.
)

echo.
echo Checking system requirements...
echo Windows Version: 
ver
echo.

:: Check if winget is available
where winget >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Windows Package Manager (winget) is available
    set WINGET_AVAILABLE=1
) else (
    echo [WARNING] Windows Package Manager (winget) not found
    echo You may need to install it from Microsoft Store or use manual installation
    set WINGET_AVAILABLE=0
)

:: Check if MiKTeX is already installed
set MIKTEX_PATH=%USERPROFILE%\AppData\Local\Programs\MiKTeX\miktex\bin\x64
set PDFLATEX_EXE=%MIKTEX_PATH%\pdflatex.exe

if exist "%PDFLATEX_EXE%" (
    echo.
    echo [INFO] MiKTeX is already installed!
    echo Location: %PDFLATEX_EXE%
    
    :: Check version
    echo Checking MiKTeX version...
    "%PDFLATEX_EXE%" --version 2>nul | findstr "MiKTeX"
    echo.
    
    choice /C YN /M "Do you want to update MiKTeX"
    if errorlevel 2 goto :skip_install
    if errorlevel 1 goto :install_miktex
) else (
    echo.
    echo [INFO] MiKTeX not found. Installation needed.
    echo.
)

:install_miktex
echo ========================================
echo Installing MiKTeX...
echo ========================================

if %WINGET_AVAILABLE%==1 (
    echo Using Windows Package Manager (winget)...
    echo This may take 5-15 minutes depending on your internet connection.
    echo.
    
    winget install MiKTeX.MiKTeX
    
    if !errorlevel! == 0 (
        echo.
        echo [SUCCESS] MiKTeX installation completed via winget!
    ) else (
        echo.
        echo [ERROR] Winget installation failed. Trying alternative method...
        goto :manual_install
    )
) else (
    goto :manual_install
)

goto :verify_installation

:manual_install
echo ========================================
echo Manual Installation Required
echo ========================================
echo.
echo Please follow these steps:
echo 1. Open your web browser
echo 2. Go to: https://miktex.org/download
echo 3. Download "Basic MiKTeX Installer" for Windows
echo 4. Run the downloaded installer
echo 5. Follow the installation wizard
echo 6. Choose "Install for all users" if you have admin rights
echo 7. After installation, come back and press any key
echo.
echo Opening MiKTeX download page...
start https://miktex.org/download
echo.
pause

:verify_installation
echo ========================================
echo Verifying Installation...
echo ========================================

:: Wait a moment for installation to complete
timeout /t 3 /nobreak >nul

:: Check again if MiKTeX is installed
if exist "%PDFLATEX_EXE%" (
    echo [SUCCESS] MiKTeX found at: %PDFLATEX_EXE%
    
    :: Test pdflatex
    echo Testing pdflatex...
    "%PDFLATEX_EXE%" --version >nul 2>&1
    if !errorlevel! == 0 (
        echo [SUCCESS] pdflatex is working correctly!
        
        :: Show version info
        echo.
        echo Installed version:
        "%PDFLATEX_EXE%" --version 2>nul | findstr "MiKTeX"
        
    ) else (
        echo [WARNING] pdflatex found but not working properly
        echo You may need to restart your computer or check the installation
    )
) else (
    echo [ERROR] MiKTeX installation verification failed
    echo Please check if the installation completed successfully
    goto :troubleshooting
)

:skip_install
echo ========================================
echo Installing Additional Packages...
echo ========================================

echo Installing commonly needed LaTeX packages...
if exist "%PDFLATEX_EXE%" (
    echo Installing tikz package...
    "%MIKTEX_PATH%\mpm.exe" --install=pgf --admin 2>nul
    
    echo Installing fontawesome package...
    "%MIKTEX_PATH%\mpm.exe" --install=fontawesome --admin 2>nul
    
    echo Installing biblatex package...
    "%MIKTEX_PATH%\mpm.exe" --install=biblatex --admin 2>nul
    
    echo Package installation completed.
)

echo ========================================
echo Environment Setup Complete!
echo ========================================
echo.
echo Your LaTeX environment is ready!
echo.
echo Next steps:
echo 1. You can now run compile_cv.bat to build your CV
echo 2. Or use compile_cv.ps1 for PowerShell version
echo 3. Check README.md for detailed usage instructions
echo.
echo Installed components:
if exist "%PDFLATEX_EXE%" (
    echo [✓] MiKTeX LaTeX distribution
    echo [✓] pdflatex compiler
    echo [✓] Common LaTeX packages
) else (
    echo [✗] MiKTeX installation incomplete
)
echo.

goto :end

:troubleshooting
echo ========================================
echo Troubleshooting
echo ========================================
echo.
echo If installation failed, try these solutions:
echo.
echo 1. Manual Installation:
echo    - Visit: https://miktex.org/download
echo    - Download and run the installer manually
echo.
echo 2. Alternative Installation Methods:
echo    - Use Chocolatey: choco install miktex
echo    - Use Scoop: scoop install latex
echo.
echo 3. System Requirements:
echo    - Windows 10 version 1903 or later
echo    - At least 1GB free disk space
echo    - Internet connection for package downloads
echo.
echo 4. Common Issues:
echo    - Antivirus blocking installation
echo    - Insufficient disk space
echo    - Network connectivity issues
echo    - Missing administrator privileges
echo.

:end
echo ========================================
echo Installation script completed.
echo ========================================
pause 