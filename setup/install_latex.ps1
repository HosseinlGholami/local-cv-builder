# LaTeX Environment Installation Script for PowerShell
# Requires PowerShell 5.0 or later

param(
    [switch]$Force = $false,
    [switch]$BasicInstall = $false,
    [switch]$Verbose = $false,
    [string]$InstallMethod = "auto"  # auto, winget, chocolatey, manual
)

# Set strict mode and error action
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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

function Write-Header {
    param([string]$Message)
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to check system requirements
function Test-SystemRequirements {
    Write-Header "Checking System Requirements"
    
    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    Write-Status "Windows Version: $($osVersion.Major).$($osVersion.Minor).$($osVersion.Build)"
    
    if ($osVersion.Major -lt 10) {
        Write-Warning "Windows 10 or later is recommended for best compatibility"
    }
    
    # Check available disk space
    $systemDrive = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
    $freeSpaceGB = [math]::Round($systemDrive.FreeSpace / 1GB, 2)
    Write-Status "Available disk space on C: drive: $freeSpaceGB GB"
    
    if ($freeSpaceGB -lt 5) {
        Write-Warning "At least 5 GB of free disk space is recommended"
        if (-not $Force) {
            $continue = Read-Host "Continue anyway? (y/n)"
            if ($continue -ne 'y' -and $continue -ne 'Y') {
                throw "Insufficient disk space. Use -Force to override."
            }
        }
    }
    
    # Check PowerShell version
    Write-Status "PowerShell Version: $($PSVersionTable.PSVersion)"
    
    # Check if running as administrator
    if (Test-Administrator) {
        Write-Success "Running as Administrator"
    } else {
        Write-Warning "Not running as Administrator. Some features may require elevation."
    }
}

# Function to detect available installation methods
function Get-InstallationMethods {
    $methods = @()
    
    # Check for winget
    try {
        $wingetVersion = & winget --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            $methods += @{
                Name = "winget"
                Available = $true
                Description = "Windows Package Manager (recommended)"
                Version = $wingetVersion
            }
        }
    } catch {
        $methods += @{
            Name = "winget"
            Available = $false
            Description = "Windows Package Manager (not available)"
            Reason = "winget not found or not working"
        }
    }
    
    # Check for Chocolatey
    try {
        $chocoVersion = & choco --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            $methods += @{
                Name = "chocolatey"
                Available = $true
                Description = "Chocolatey Package Manager"
                Version = $chocoVersion
            }
        }
    } catch {
        $methods += @{
            Name = "chocolatey"
            Available = $false
            Description = "Chocolatey Package Manager (not available)"
            Reason = "Chocolatey not installed"
        }
    }
    
    # Manual installation is always available
    $methods += @{
        Name = "manual"
        Available = $true
        Description = "Manual download and installation"
    }
    
    return $methods
}

# Function to install via winget
function Install-ViaWinget {
    Write-Status "Installing MiKTeX via Windows Package Manager..."
    
    try {
        if ($BasicInstall) {
            & winget install MiKTeX.MiKTeX --accept-package-agreements --accept-source-agreements
        } else {
            & winget install MiKTeX.MiKTeX --accept-package-agreements --accept-source-agreements
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "MiKTeX installation completed via winget"
            return $true
        } else {
            Write-ErrorMsg "Winget installation failed with exit code: $LASTEXITCODE"
            return $false
        }
    } catch {
        Write-ErrorMsg "Winget installation failed: $($_.Exception.Message)"
        return $false
    }
}

# Function to install via Chocolatey
function Install-ViaChocolatey {
    Write-Status "Installing MiKTeX via Chocolatey..."
    
    try {
        & choco install miktex --yes
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "MiKTeX installation completed via Chocolatey"
            return $true
        } else {
            Write-ErrorMsg "Chocolatey installation failed with exit code: $LASTEXITCODE"
            return $false
        }
    } catch {
        Write-ErrorMsg "Chocolatey installation failed: $($_.Exception.Message)"
        return $false
    }
}

# Function to install manually
function Install-Manually {
    Write-Header "Manual Installation Required"
    
    Write-Status "Please follow these steps:"
    Write-Host "1. A web browser will open to the MiKTeX download page"
    Write-Host "2. Download the 'Basic MiKTeX Installer' for Windows"
    Write-Host "3. Run the downloaded installer"
    Write-Host "4. Follow the installation wizard:"
    Write-Host "   - Choose 'Install for all users' if you have admin rights"
    Write-Host "   - Select default installation directory"
    Write-Host "   - Choose 'Yes' for automatic package installation"
    Write-Host "5. After installation, return here and press Enter"
    
    # Open download page
    Start-Process "https://miktex.org/download"
    
    Read-Host "Press Enter after completing the manual installation"
    return $true
}

# Function to verify installation
function Test-Installation {
    Write-Header "Verifying Installation"
    
    # Common installation paths
    $possiblePaths = @(
        "$env:USERPROFILE\AppData\Local\Programs\MiKTeX\miktex\bin\x64",
        "$env:ProgramFiles\MiKTeX\miktex\bin\x64",
        "${env:ProgramFiles(x86)}\MiKTeX\miktex\bin\x64"
    )
    
    $pdflatexPath = $null
    
    foreach ($path in $possiblePaths) {
        $testPath = Join-Path $path "pdflatex.exe"
        if (Test-Path $testPath) {
            $pdflatexPath = $testPath
            break
        }
    }
    
    if (-not $pdflatexPath) {
        # Try to find in PATH
        try {
            $pdflatexPath = (Get-Command pdflatex -ErrorAction SilentlyContinue).Source
        } catch {
            # pdflatex not found
        }
    }
    
    if ($pdflatexPath) {
        Write-Success "pdflatex found at: $pdflatexPath"
        
        # Test if it works
        try {
            $version = & $pdflatexPath --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "pdflatex is working correctly!"
                if ($Verbose) {
                    Write-Host "Version information:"
                    $version | Select-Object -First 3 | ForEach-Object { Write-Host "  $_" }
                }
                return $pdflatexPath
            } else {
                Write-Warning "pdflatex found but not working properly"
                return $null
            }
        } catch {
            Write-Warning "Error testing pdflatex: $($_.Exception.Message)"
            return $null
        }
    } else {
        Write-ErrorMsg "pdflatex not found after installation"
        return $null
    }
}

# Function to install additional packages
function Install-AdditionalPackages {
    param([string]$MiKTeXPath)
    
    Write-Header "Installing Additional Packages"
    
    $mpmPath = Join-Path (Split-Path $MiKTeXPath) "mpm.exe"
    
    if (Test-Path $mpmPath) {
        $packages = @(
            "pgf",           # TikZ graphics
            "fontawesome",   # Font Awesome icons
            "biblatex",      # Modern bibliography
            "enumitem",      # Enhanced lists
            "hyperref",      # Hyperlinks
            "xcolor",        # Colors
            "geometry",      # Page geometry
            "fancyhdr"       # Headers and footers
        )
        
        foreach ($package in $packages) {
            Write-Status "Installing package: $package"
            try {
                & $mpmPath --install=$package --admin 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Installed $package"
                } else {
                    Write-Warning "Could not install $package (may already be installed)"
                }
            } catch {
                Write-Warning "Error installing $package: $($_.Exception.Message)"
            }
        }
        
        Write-Success "Additional packages installation completed"
    } else {
        Write-Warning "MiKTeX Package Manager not found. Packages will be installed on-demand."
    }
}

# Function to create test document
function Test-LaTeXCompilation {
    param([string]$PdfLatexPath)
    
    Write-Status "Testing LaTeX compilation..."
    
    $testDocument = @"
\documentclass{article}
\usepackage[utf8]{inputenc}
\title{LaTeX Test Document}
\author{Installation Script}
\date{\today}

\begin{document}
\maketitle
\section{Test Section}
If you can see this PDF, your LaTeX installation is working correctly!
\end{document}
"@
    
    try {
        # Create test file
        $testDocument | Out-File -FilePath "test_latex.tex" -Encoding UTF8
        
        # Compile test document
        $process = Start-Process -FilePath $PdfLatexPath -ArgumentList "-interaction=nonstopmode", "test_latex.tex" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0 -and (Test-Path "test_latex.pdf")) {
            Write-Success "Test compilation successful!"
            
            # Clean up test files
            Remove-Item "test_latex.*" -Force -ErrorAction SilentlyContinue
            return $true
        } else {
            Write-Warning "Test compilation failed. Check test_latex.log for details."
            return $false
        }
    } catch {
        Write-ErrorMsg "Error during test compilation: $($_.Exception.Message)"
        return $false
    }
}

# Main installation function
function Install-LaTeX {
    try {
        Write-Header "LaTeX Environment Installation Script"
        Write-Host "This script will install MiKTeX for LaTeX compilation on Windows"
        Write-Host
        
        # Check system requirements
        Test-SystemRequirements
        
        # Check if already installed
        $existingInstallation = Test-Installation
        if ($existingInstallation -and -not $Force) {
            Write-Success "MiKTeX is already installed and working!"
            Write-Host "Location: $existingInstallation"
            
            $choice = Read-Host "Do you want to update/reinstall? (y/n)"
            if ($choice -ne 'y' -and $choice -ne 'Y') {
                Write-Status "Installation skipped. Verifying additional packages..."
                Install-AdditionalPackages $existingInstallation
                return
            }
        }
        
        # Get available installation methods
        $methods = Get-InstallationMethods
        
        Write-Status "Available installation methods:"
        foreach ($method in $methods) {
            if ($method.Available) {
                Write-Host "  [✓] $($method.Name) - $($method.Description)" -ForegroundColor Green
                if ($method.Version) {
                    Write-Host "      Version: $($method.Version)" -ForegroundColor Gray
                }
            } else {
                Write-Host "  [✗] $($method.Name) - $($method.Description)" -ForegroundColor Red
                Write-Host "      Reason: $($method.Reason)" -ForegroundColor Gray
            }
        }
        Write-Host
        
        # Choose installation method
        $installSuccess = $false
        
        if ($InstallMethod -eq "auto") {
            # Try methods in order of preference
            $availableMethods = $methods | Where-Object { $_.Available }
            
            foreach ($method in $availableMethods) {
                Write-Status "Trying installation method: $($method.Name)"
                
                switch ($method.Name) {
                    "winget" {
                        $installSuccess = Install-ViaWinget
                    }
                    "chocolatey" {
                        $installSuccess = Install-ViaChocolatey
                    }
                    "manual" {
                        $installSuccess = Install-Manually
                    }
                }
                
                if ($installSuccess) {
                    break
                }
            }
        } else {
            # Use specified method
            $selectedMethod = $methods | Where-Object { $_.Name -eq $InstallMethod -and $_.Available }
            
            if ($selectedMethod) {
                switch ($InstallMethod) {
                    "winget" {
                        $installSuccess = Install-ViaWinget
                    }
                    "chocolatey" {
                        $installSuccess = Install-ViaChocolatey
                    }
                    "manual" {
                        $installSuccess = Install-Manually
                    }
                }
            } else {
                Write-ErrorMsg "Specified installation method '$InstallMethod' is not available"
                throw "Installation method not available"
            }
        }
        
        if (-not $installSuccess) {
            Write-ErrorMsg "All installation methods failed"
            throw "Installation failed"
        }
        
        # Verify installation
        Start-Sleep -Seconds 3  # Wait for installation to complete
        $pdflatexPath = Test-Installation
        
        if (-not $pdflatexPath) {
            Write-ErrorMsg "Installation verification failed"
            throw "Installation verification failed"
        }
        
        # Install additional packages
        if (-not $BasicInstall) {
            Install-AdditionalPackages $pdflatexPath
        }
        
        # Test compilation
        if (Test-LaTeXCompilation $pdflatexPath) {
            Write-Success "LaTeX environment is fully functional!"
        }
        
        Write-Header "Installation Complete!"
        Write-Success "Your LaTeX environment is ready!"
        Write-Host
        Write-Host "Next steps:"
        Write-Host "1. You can now run .\compile_cv.bat to build your CV"
        Write-Host "2. Or use .\compile_cv.ps1 for PowerShell version"
        Write-Host "3. Check README.md for detailed usage instructions"
        Write-Host
        
        # Show installed components
        Write-Host "Installed components:"
        Write-Host "[✓] MiKTeX LaTeX distribution" -ForegroundColor Green
        Write-Host "[✓] pdflatex compiler" -ForegroundColor Green
        if (-not $BasicInstall) {
            Write-Host "[✓] Additional LaTeX packages" -ForegroundColor Green
        }
        Write-Host "Location: $pdflatexPath" -ForegroundColor Gray
        
    } catch {
        Write-ErrorMsg "Installation failed: $($_.Exception.Message)"
        if ($Verbose) {
            Write-Host $_.Exception.StackTrace -ForegroundColor Red
        }
        
        Write-Host
        Write-Header "Troubleshooting"
        Write-Host "If installation failed, try these solutions:"
        Write-Host
        Write-Host "1. Run as Administrator:"
        Write-Host "   Right-click PowerShell -> 'Run as Administrator'"
        Write-Host
        Write-Host "2. Try different installation method:"
        Write-Host "   .\install_latex.ps1 -InstallMethod manual"
        Write-Host
        Write-Host "3. Check system requirements:"
        Write-Host "   - Windows 10 version 1903 or later"
        Write-Host "   - At least 5GB free disk space"
        Write-Host "   - Stable internet connection"
        Write-Host
        Write-Host "4. Manual installation:"
        Write-Host "   Visit: https://miktex.org/download"
        
        exit 1
    }
}

# Run the installation
Install-LaTeX 