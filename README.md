# CV Compilation Scripts

This repository contains scripts to install LaTeX and compile your LaTeX CV automatically. The scripts handle installation of LaTeX (if needed) and compilation of your CV with proper error handling.

## Files Overview

- `main.tex` - Your CV source file
- `simplecv.sty` - Custom CV style file
- `sections/` - Directory containing CV sections
- `setup/` - Installation scripts for different platforms
- `.gitignore` - Git ignore file for LaTeX projects

## 🚀 Quick Start

### Option 1: One-Click Installation + Compilation (Recommended)
**Windows:** Run `setup\install_latex.bat` → then `compile_cv.bat`  
**Linux/macOS:** Run `./setup/install_latex.sh` → then `./compile_cv.sh`  
**PowerShell:** Run `.\setup\install_latex.ps1` → then `.\compile_cv.ps1`

### Option 2: Direct Compilation (if LaTeX already installed)
**Windows:** Double-click `compile_cv.bat`  
**Linux/macOS:** Run `./compile_cv.sh`  
**PowerShell:** Run `.\compile_cv.ps1`

## Installation Scripts (in `setup/` folder)

### 1. Windows Batch Installer (`setup/install_latex.bat`)

**Best for:** Windows users who want simple installation

**Features:**
- Automatic system requirements check
- Multiple installation methods (winget, manual)
- Verification and testing
- Additional package installation
- Comprehensive error handling

**Usage:**
```cmd
# Double-click the file, or run from command prompt:
setup\install_latex.bat
```

### 2. PowerShell Installer (`setup/install_latex.ps1`)

**Best for:** Windows users who want advanced control

**Features:**
- Advanced system analysis
- Multiple installation methods with auto-detection
- Detailed progress reporting
- Custom installation options
- Comprehensive testing and verification

**Usage:**
```powershell
# Basic installation:
.\setup\install_latex.ps1

# Basic installation only (smaller download):
.\setup\install_latex.ps1 -BasicInstall

# Force reinstallation:
.\setup\install_latex.ps1 -Force

# Use specific installation method:
.\setup\install_latex.ps1 -InstallMethod winget

# Verbose output:
.\setup\install_latex.ps1 -Verbose
```

### 3. Unix/Linux Installer (`setup/install_latex.sh`)

**Best for:** Linux, macOS, or Windows with WSL/Git Bash

**Features:**
- Cross-platform OS detection
- Multiple Linux distributions support
- Package manager auto-detection
- Interactive installation options
- Comprehensive testing and setup

**Usage:**
```bash
# Make executable (first time only):
chmod +x setup/install_latex.sh

# Run the installer:
./setup/install_latex.sh
```

**Supported Systems:**
- **Ubuntu/Debian:** `apt-get` with multiple installation sizes
- **CentOS/RHEL:** `yum`/`dnf` package managers
- **Fedora:** `dnf` with recommended packages
- **Arch Linux:** `pacman` with multiple options
- **openSUSE:** `zypper` package manager
- **macOS:** Homebrew with BasicTeX or MacTeX options

## Compilation Scripts

### 1. Windows Batch Script (`compile_cv.bat`)

**Best for:** Windows users who prefer double-clicking to run

**Features:**
- Automatic MiKTeX detection
- Creates timestamped output files in `output/` folder
- Opens output directory when done
- Error handling and retry logic
- Automatic cleanup of auxiliary files

**Usage:**
```cmd
# Double-click the file, or run from command prompt:
compile_cv.bat
```

### 2. PowerShell Script (`compile_cv.ps1`)

**Best for:** Windows users who want more advanced features

**Features:**
- Colored output for better readability
- Verbose error reporting
- Custom output directory support
- Detailed file information
- Advanced error handling
- Automatic cleanup

**Usage:**
```powershell
# Basic usage:
.\compile_cv.ps1

# With custom output directory:
.\compile_cv.ps1 -OutputDir "C:\MyDocuments\CV"

# With verbose output:
.\compile_cv.ps1 -Verbose
```

### 3. Bash Script (`compile_cv.sh`)

**Best for:** Linux, macOS, or Windows with WSL/Git Bash

**Features:**
- Cross-platform LaTeX support
- Colored output
- Comprehensive error reporting
- Automatic cleanup
- Works on Linux, macOS, and Windows (with WSL)

**Usage:**
```bash
# Make executable (first time only):
chmod +x compile_cv.sh

# Run the script:
./compile_cv.sh
```

## Output

All scripts will:
1. Create an `output/` directory in the repository folder
2. Generate a PDF with timestamp: `CV_Hossein_Gholami_YYYYMMDD_HHMMSS.pdf`
3. Open the output directory automatically
4. Clean up auxiliary files (`.aux`, `.log`, `.out`)
5. Display compilation status and file information

## Installation Methods

### Windows
1. **Windows Package Manager (winget)** - Automatic, recommended
2. **Chocolatey** - Alternative package manager
3. **Manual Installation** - Download from MiKTeX website

### Linux
- **Ubuntu/Debian:** TeXLive via `apt-get`
- **CentOS/RHEL:** TeXLive via `yum`/`dnf`
- **Fedora:** TeXLive via `dnf`
- **Arch Linux:** TeXLive via `pacman`
- **openSUSE:** TeXLive via `zypper`

### macOS
- **Homebrew** - BasicTeX (100MB) or MacTeX (4GB)
- **Manual** - Download from MacTeX website

## Troubleshooting

### Common Issues

1. **"Installation failed"**
   - Run installation script as Administrator (Windows)
   - Check internet connection
   - Ensure sufficient disk space (5GB+)
   - Try different installation method

2. **"pdflatex not found"**
   - Run the appropriate installation script first
   - Restart terminal/command prompt after installation
   - Check if LaTeX is in PATH

3. **PowerShell execution policy error**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. **Missing packages error**
   - Installation scripts install common packages automatically
   - For manual installation, check the `.log` file for package names
   - Compilation scripts use `--enable-installer` flag for auto-install

5. **Compilation fails**
   - Check the generated `.log` file for detailed error messages
   - Ensure all files are in correct directory structure
   - Try running the installation script again

### System Requirements

- **Windows:** Windows 10/11 with PowerShell 5.0+
- **Linux:** Any modern Linux distribution with package manager
- **macOS:** macOS 10.12 or later
- **Disk Space:** At least 5GB free space
- **Internet:** Required for downloading packages

### Manual Installation

If scripts fail, you can install manually:

**Windows:**
- Visit: [MiKTeX Download](https://miktex.org/download)
- Download and run Basic MiKTeX Installer

**Linux:**
```bash
# Ubuntu/Debian:
sudo apt-get install texlive-latex-recommended

# CentOS/RHEL:
sudo yum install texlive-latex

# Arch Linux:
sudo pacman -S texlive-most
```

**macOS:**
- Visit: [MacTeX Download](https://www.tug.org/mactex/)
- Or use Homebrew: `brew install --cask mactex`

### Manual Compilation

If compilation scripts fail:

```bash
# Basic compilation:
pdflatex main.tex

# With package auto-installation:
pdflatex --enable-installer main.tex
```

## CV Customization

To modify your CV:
1. Edit the appropriate files in the `sections/` directory
2. Modify `main.tex` to include/exclude sections
3. Customize colors and styling in `simplecv.sty`
4. Run any of the compilation scripts

## File Structure

```
cv/
├── main.tex                 # Your CV source file
├── simplecv.sty            # CV style definitions
├── compile_cv.bat          # Windows batch compiler
├── compile_cv.ps1          # PowerShell compiler
├── compile_cv.sh           # Bash compiler
├── .gitignore              # Git ignore file
├── README.md               # This file
├── setup/                  # Installation scripts
│   ├── install_latex.bat   # Windows installer
│   ├── install_latex.ps1   # PowerShell installer
│   └── install_latex.sh    # Unix/Linux installer
├── sections/               # CV content sections
│   ├── education.tex       # Education section
│   ├── work_exp.tex        # Work experience
│   ├── Skil.tex           # Skills section
│   ├── hobbies.tex        # Hobbies section
│   └── ...                # Other sections
└── output/                 # Generated PDFs (auto-created)
    └── CV_Hossein_Gholami_*.pdf
```

## Support

If you encounter issues:
1. Check the generated `.log` files for detailed error messages
2. Ensure all required files are present in the correct structure
3. Run installation scripts as Administrator (Windows) or with sudo (Linux/macOS)
4. Check internet connection and disk space
5. For Windows users, try different PowerShell execution policies 