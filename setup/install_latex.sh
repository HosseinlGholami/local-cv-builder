#!/bin/bash

# LaTeX Environment Installation Script
# Supports Linux, macOS, and other Unix-like systems

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            OS="ubuntu"
            PKG_MANAGER="apt"
        elif command_exists yum; then
            OS="centos"
            PKG_MANAGER="yum"
        elif command_exists dnf; then
            OS="fedora"
            PKG_MANAGER="dnf"
        elif command_exists pacman; then
            OS="arch"
            PKG_MANAGER="pacman"
        elif command_exists zypper; then
            OS="opensuse"
            PKG_MANAGER="zypper"
        else
            OS="linux_unknown"
            PKG_MANAGER="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        if command_exists brew; then
            PKG_MANAGER="homebrew"
        else
            PKG_MANAGER="none"
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
        PKG_MANAGER="none"
    else
        OS="unknown"
        PKG_MANAGER="unknown"
    fi
}

# Function to install LaTeX based on OS
install_latex() {
    case $OS in
        "ubuntu")
            print_status "Installing TeXLive on Ubuntu/Debian..."
            print_warning "This will download approximately 3-4 GB of packages"
            echo "Options:"
            echo "1. Basic installation (texlive-latex-base) - ~200MB"
            echo "2. Recommended installation (texlive-latex-recommended) - ~1GB"
            echo "3. Full installation (texlive-full) - ~4GB"
            echo "4. Custom minimal installation"
            echo
            read -p "Choose option (1-4): " choice
            
            case $choice in
                1)
                    sudo apt-get update
                    sudo apt-get install -y texlive-latex-base texlive-fonts-recommended
                    ;;
                2)
                    sudo apt-get update
                    sudo apt-get install -y texlive-latex-recommended texlive-fonts-extra texlive-latex-extra
                    ;;
                3)
                    sudo apt-get update
                    sudo apt-get install -y texlive-full
                    ;;
                4)
                    sudo apt-get update
                    sudo apt-get install -y texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra texlive-pictures
                    ;;
                *)
                    print_error "Invalid choice. Installing recommended packages."
                    sudo apt-get update
                    sudo apt-get install -y texlive-latex-recommended
                    ;;
            esac
            ;;
            
        "centos")
            print_status "Installing TeXLive on CentOS/RHEL..."
            if command_exists dnf; then
                sudo dnf install -y texlive-scheme-medium
            else
                sudo yum install -y texlive texlive-latex texlive-collection-fontsrecommended
            fi
            ;;
            
        "fedora")
            print_status "Installing TeXLive on Fedora..."
            sudo dnf install -y texlive-scheme-medium texlive-collection-latexextra
            ;;
            
        "arch")
            print_status "Installing TeXLive on Arch Linux..."
            echo "Options:"
            echo "1. Basic installation (texlive-core)"
            echo "2. Extended installation (texlive-most)"
            echo "3. Full installation (texlive-most + texlive-lang)"
            read -p "Choose option (1-3): " choice
            
            case $choice in
                1)
                    sudo pacman -S --noconfirm texlive-core
                    ;;
                2)
                    sudo pacman -S --noconfirm texlive-most
                    ;;
                3)
                    sudo pacman -S --noconfirm texlive-most texlive-lang
                    ;;
                *)
                    sudo pacman -S --noconfirm texlive-most
                    ;;
            esac
            ;;
            
        "opensuse")
            print_status "Installing TeXLive on openSUSE..."
            sudo zypper install -y texlive texlive-latex texlive-metapost
            ;;
            
        "macos")
            if [[ "$PKG_MANAGER" == "homebrew" ]]; then
                print_status "Installing MacTeX via Homebrew..."
                print_warning "This will download approximately 4 GB"
                echo "Options:"
                echo "1. BasicTeX (minimal, ~100MB)"
                echo "2. MacTeX (full, ~4GB)"
                read -p "Choose option (1-2): " choice
                
                case $choice in
                    1)
                        brew install --cask basictex
                        print_status "Installing additional packages for BasicTeX..."
                        sudo tlmgr update --self
                        sudo tlmgr install collection-fontsrecommended collection-latexextra
                        ;;
                    2)
                        brew install --cask mactex
                        ;;
                    *)
                        brew install --cask basictex
                        ;;
                esac
            else
                print_error "Homebrew not found. Installing Homebrew first..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                if command_exists brew; then
                    brew install --cask mactex
                else
                    print_error "Failed to install Homebrew. Please install MacTeX manually."
                    print_status "Visit: https://www.tug.org/mactex/"
                    return 1
                fi
            fi
            ;;
            
        "windows")
            print_error "This script is for Unix-like systems."
            print_status "For Windows, please use install_latex.bat"
            return 1
            ;;
            
        *)
            print_error "Unsupported operating system: $OSTYPE"
            print_status "Please install LaTeX manually for your system."
            return 1
            ;;
    esac
}

# Function to verify installation
verify_installation() {
    print_header "Verifying Installation"
    
    if command_exists pdflatex; then
        print_success "pdflatex found: $(which pdflatex)"
        
        # Test pdflatex
        print_status "Testing pdflatex..."
        if pdflatex --version >/dev/null 2>&1; then
            print_success "pdflatex is working correctly!"
            
            # Show version
            echo
            echo "Installed version:"
            pdflatex --version | head -1
            echo
        else
            print_warning "pdflatex found but not working properly"
        fi
    else
        print_error "pdflatex not found after installation"
        return 1
    fi
    
    # Check for other useful tools
    if command_exists latex; then
        print_success "latex command available"
    fi
    
    if command_exists xelatex; then
        print_success "xelatex available (Unicode support)"
    fi
    
    if command_exists lualatex; then
        print_success "lualatex available (Lua support)"
    fi
    
    if command_exists bibtex; then
        print_success "bibtex available (bibliography support)"
    fi
}

# Function to install additional packages
install_additional_packages() {
    print_header "Installing Additional Packages"
    
    if command_exists tlmgr; then
        print_status "Installing commonly needed packages via tlmgr..."
        
        # List of essential packages
        packages=(
            "pgf"           # TikZ graphics
            "fontawesome"   # Font Awesome icons
            "biblatex"      # Modern bibliography
            "enumitem"      # Enhanced lists
            "hyperref"      # Hyperlinks
            "graphicx"      # Graphics inclusion
            "xcolor"        # Colors
            "geometry"      # Page geometry
            "fancyhdr"      # Headers and footers
        )
        
        for package in "${packages[@]}"; do
            print_status "Installing $package..."
            tlmgr install "$package" 2>/dev/null || print_warning "Could not install $package (may already be installed)"
        done
        
        print_success "Additional packages installation completed"
    else
        print_warning "tlmgr not available. Additional packages will be installed on-demand."
    fi
}

# Function to setup environment
setup_environment() {
    print_header "Environment Setup"
    
    # Check if LaTeX binaries are in PATH
    if command_exists pdflatex; then
        print_success "LaTeX binaries are in PATH"
    else
        # Try to add common LaTeX paths
        if [[ "$OS" == "macos" ]]; then
            LATEX_PATH="/usr/local/texlive/2023/bin/universal-darwin"
            if [[ -d "$LATEX_PATH" ]]; then
                echo "export PATH=\"$LATEX_PATH:\$PATH\"" >> ~/.bashrc
                echo "export PATH=\"$LATEX_PATH:\$PATH\"" >> ~/.zshrc
                print_status "Added LaTeX to PATH. Please restart your terminal or run:"
                echo "export PATH=\"$LATEX_PATH:\$PATH\""
            fi
        fi
    fi
    
    # Create a test document
    print_status "Creating test document..."
    cat > test_latex.tex << 'EOF'
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
EOF

    print_status "Testing LaTeX compilation..."
    if pdflatex -interaction=nonstopmode test_latex.tex >/dev/null 2>&1; then
        if [[ -f "test_latex.pdf" ]]; then
            print_success "Test compilation successful! LaTeX is working."
            rm -f test_latex.tex test_latex.pdf test_latex.aux test_latex.log
        else
            print_warning "Compilation ran but no PDF generated"
        fi
    else
        print_error "Test compilation failed"
        print_status "Check test_latex.log for details"
    fi
}

# Main installation function
main() {
    print_header "LaTeX Environment Installation Script"
    echo "This script will install LaTeX for CV compilation"
    echo
    
    # Detect OS
    detect_os
    print_status "Detected OS: $OS with package manager: $PKG_MANAGER"
    echo
    
    # Check if LaTeX is already installed
    if command_exists pdflatex; then
        print_success "LaTeX is already installed!"
        pdflatex --version | head -1
        echo
        read -p "Do you want to update/reinstall? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            verify_installation
            setup_environment
            exit 0
        fi
    fi
    
    # Install LaTeX
    print_status "Starting LaTeX installation..."
    echo
    
    if install_latex; then
        print_success "LaTeX installation completed!"
    else
        print_error "LaTeX installation failed!"
        exit 1
    fi
    
    # Verify installation
    verify_installation
    
    # Install additional packages
    read -p "Install additional LaTeX packages? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_additional_packages
    fi
    
    # Setup environment
    setup_environment
    
    print_header "Installation Complete!"
    echo
    print_success "Your LaTeX environment is ready!"
    echo
    echo "Next steps:"
    echo "1. You can now run ./compile_cv.sh to build your CV"
    echo "2. Check README.md for detailed usage instructions"
    echo "3. If you encounter issues, check the troubleshooting section"
    echo
    
    # Show what was installed
    echo "Installed components:"
    if command_exists pdflatex; then
        echo "[✓] pdflatex compiler"
    fi
    if command_exists xelatex; then
        echo "[✓] xelatex (Unicode support)"
    fi
    if command_exists lualatex; then
        echo "[✓] lualatex (Lua support)"
    fi
    if command_exists bibtex; then
        echo "[✓] bibtex (bibliography)"
    fi
    if command_exists tlmgr; then
        echo "[✓] tlmgr (package manager)"
    fi
    echo
}

# Run main function
main "$@" 