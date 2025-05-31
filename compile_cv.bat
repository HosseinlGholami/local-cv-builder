@echo off
setlocal enabledelayedexpansion

echo ========================================
echo CV Compilation Script (Batch)
echo ========================================

REM Set variables
set "MIKTEX_PATH=%USERPROFILE%\AppData\Local\Programs\MiKTeX\miktex\bin\x64"
set "PDFLATEX_EXE=%MIKTEX_PATH%\pdflatex.exe"
set "CV_FILE=main.tex"
set "OUTPUT_DIR=%~dp0output"

REM Check for MiKTeX installation
echo [INFO] Checking for MiKTeX installation...
if exist "%PDFLATEX_EXE%" (
    echo [SUCCESS] MiKTeX found at: %PDFLATEX_EXE%
) else (
    echo [ERROR] MiKTeX not found. Please run the installation script first:
    echo setup\install_latex.bat
    pause
    exit /b 1
)

REM Create output directory
echo [INFO] Creating output directory...
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
echo [SUCCESS] Output directory: %OUTPUT_DIR%

REM Check if CV file exists
if exist "%CV_FILE%" (
    echo [INFO] Using CV file: %CV_FILE%
) else (
    echo [ERROR] %CV_FILE% not found
    pause
    exit /b 1
)

REM Clean up any existing auxiliary files
echo [INFO] Cleaning up previous compilation files...
for %%x in (aux log out pdf) do (
    if exist "main.%%x" del /f /q "main.%%x" >nul 2>&1
)

REM Compile the CV
echo ========================================
echo [INFO] Compiling CV: %CV_FILE% (Non-interactive mode)
echo ========================================

REM Use non-interactive mode
echo [INFO] Running first compilation pass...
"%PDFLATEX_EXE%" -interaction=nonstopmode --enable-installer "%CV_FILE%" >compile_output.log 2>compile_error.log

echo [INFO] Running second compilation pass...
"%PDFLATEX_EXE%" -interaction=nonstopmode --enable-installer "%CV_FILE%" >compile_output2.log 2>compile_error2.log

REM Check if PDF was generated (this is the real test)
set "PDF_NAME=main.pdf"
if exist "%PDF_NAME%" (
    echo ========================================
    echo [SUCCESS] Compilation successful!
    echo ========================================

    REM Generate timestamp for unique filename
    for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
    set "timestamp=!dt:~0,8!_!dt:~8,6!"

    REM Copy PDF to output directory with timestamp
    set "OUTPUT_PDF=%OUTPUT_DIR%\CV_Hossein_Gholami_!timestamp!.pdf"
    copy "%PDF_NAME%" "!OUTPUT_PDF!" >nul
    echo [SUCCESS] PDF copied to: !OUTPUT_PDF!

    REM Clean up auxiliary files
    for %%x in (aux log out) do (
        if exist "main.%%x" del /f /q "main.%%x" >nul 2>&1
    )
    
    REM Clean up compilation logs
    for %%x in (compile_output.log compile_error.log compile_output2.log compile_error2.log) do (
        if exist "%%x" del /f /q "%%x" >nul 2>&1
    )
    
    REM Remove the original PDF from root
    del /f /q "%PDF_NAME%" >nul 2>&1

    REM Display file size
    for %%f in ("!OUTPUT_PDF!") do set "size=%%~zf"
    set /a "sizeKB=!size!/1024"
    echo [INFO] Generated PDF size: !sizeKB! KB

    REM Open the output directory
    start "" "%OUTPUT_DIR%"

    echo ========================================
    echo [SUCCESS] Done! Your CV is ready at: !OUTPUT_PDF!
    echo ========================================
) else (
    echo ========================================
    echo [ERROR] Compilation failed!
    echo ========================================
    echo [ERROR] PDF was not generated. Check the log file for errors.
    
    if exist "main.log" (
        echo [INFO] Log file: main.log
    )
    
    REM Show compilation errors if available
    if exist "compile_error.log" (
        echo [INFO] Compilation errors:
        type "compile_error.log"
    )
    
    pause
    exit /b 1
)

echo Press any key to continue...
pause >nul 