# CV Compilation Script for PowerShell
# Requires PowerShell 5.0 or later

param(
    [string]$OutputDir = ".\output",
    [switch]$Verbose = $false
)

# Set strict mode and error action
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"  # Changed to Continue for better error handling

# Function to write colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

try {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "CV Compilation Script (PowerShell)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    # Set variables
    $MiKTeXPath = "$env:USERPROFILE\AppData\Local\Programs\MiKTeX\miktex\bin\x64"
    $PdfLatexExe = Join-Path $MiKTeXPath "pdflatex.exe"
    $CvFile = "main.tex"

    # Check for MiKTeX installation
    Write-Status "Checking for MiKTeX installation..."
    if (Test-Path $PdfLatexExe) {
        Write-Success "MiKTeX found at: $PdfLatexExe"
    }
    else {
        Write-ErrorMsg "MiKTeX not found. Please run the installation script first:"
        Write-Host "setup\install_latex.ps1" -ForegroundColor Yellow
        exit 1
    }

    # Create output directory
    Write-Status "Creating output directory..."
    if (-not (Test-Path $OutputDir)) {
        New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
    }
    $OutputDir = Resolve-Path $OutputDir
    Write-Success "Output directory: $OutputDir"

    # Check if CV file exists
    if (Test-Path $CvFile) {
        Write-Status "Using CV file: $CvFile"
    }
    else {
        Write-ErrorMsg "$CvFile not found"
        exit 1
    }

    # Clean up any existing auxiliary files
    @("aux", "log", "out", "pdf") | ForEach-Object {
        $auxFile = $CvFile -replace '\.tex$', ".$_"
        if (Test-Path $auxFile) {
            Remove-Item $auxFile -Force
        }
    }

    # Compile the CV
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Status "Compiling CV: $CvFile (Non-interactive mode)"
    Write-Host "========================================" -ForegroundColor Cyan

    # Use non-interactive mode and suppress most output
    $CompilationArgs = @(
        "-interaction=nonstopmode",
        "--enable-installer",
        $CvFile
    )

    # First compilation attempt
    Write-Status "Running first compilation pass..."
    $process = Start-Process -FilePath $PdfLatexExe -ArgumentList $CompilationArgs -Wait -PassThru -NoNewWindow -RedirectStandardOutput "compile_output.log" -RedirectStandardError "compile_error.log"
    
    # Second compilation for references (ignore exit code for now)
    Write-Status "Running second compilation pass..."
    $process2 = Start-Process -FilePath $PdfLatexExe -ArgumentList $CompilationArgs -Wait -PassThru -NoNewWindow -RedirectStandardOutput "compile_output2.log" -RedirectStandardError "compile_error2.log"

    # Check if PDF was generated (this is the real test)
    $PdfName = $CvFile -replace '\.tex$', '.pdf'
    if (Test-Path $PdfName) {
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Success "Compilation successful!"
        Write-Host "========================================" -ForegroundColor Cyan

        # Copy PDF to output directory with timestamp
        $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $OutputPdf = Join-Path $OutputDir "CV_Hossein_Gholami_$Timestamp.pdf"
        
        Copy-Item $PdfName $OutputPdf -Force
        Write-Success "PDF copied to: $OutputPdf"

        # Clean up auxiliary files
        @("aux", "log", "out") | ForEach-Object {
            $auxFile = $CvFile -replace '\.tex$', ".$_"
            if (Test-Path $auxFile) {
                Remove-Item $auxFile -Force
            }
        }
        
        # Clean up compilation logs
        @("compile_output.log", "compile_error.log", "compile_output2.log", "compile_error2.log") | ForEach-Object {
            if (Test-Path $_) {
                Remove-Item $_ -Force
            }
        }
        
        # Remove the original PDF from root
        Remove-Item $PdfName -Force

        # Display file info
        $FileInfo = Get-Item $OutputPdf
        $FileSizeKB = [math]::Round($FileInfo.Length / 1KB, 2)
        Write-Status "Generated PDF size: $FileSizeKB KB"

        # Open the output directory
        Start-Process explorer $OutputDir

        Write-Host "========================================" -ForegroundColor Cyan
        Write-Success "Done! Your CV is ready at: $OutputPdf"
        Write-Host "========================================" -ForegroundColor Cyan
    }
    else {
        Write-Host "========================================" -ForegroundColor Red
        Write-ErrorMsg "Compilation failed!"
        Write-Host "========================================" -ForegroundColor Red
        Write-ErrorMsg "PDF was not generated. Check the log file for errors."
        
        $LogFile = $CvFile -replace '\.tex$', '.log'
        if (Test-Path $LogFile) {
            Write-Status "Log file: $LogFile"
            if ($Verbose) {
                Write-Status "Last 20 lines of log file:"
                Get-Content $LogFile | Select-Object -Last 20 | ForEach-Object { Write-Host $_ }
            }
        }
        
        # Show compilation logs if available
        if (Test-Path "compile_error.log") {
            Write-Status "Compilation errors:"
            Get-Content "compile_error.log" | ForEach-Object { Write-Host $_ -ForegroundColor Red }
        }
        
        exit 1
    }
}
catch {
    Write-ErrorMsg "An error occurred: $($_.Exception.Message)"
    if ($Verbose) {
        Write-Host $_.Exception.StackTrace -ForegroundColor Red
    }
    exit 1
}

Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 