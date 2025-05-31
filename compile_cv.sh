#!/bin/bash

echo "========================================"
echo "CV Compilation Script (Bash)"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Set variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output"
CV_FILE="main.tex"

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for LaTeX installation
print_status "Checking for LaTeX installation..."
if command_exists pdflatex; then
    print_success "pdflatex found: $(which pdflatex)"
else
    print_error "pdflatex not found. Please run the installation script first:"
    echo "./setup/install_latex.sh"
    exit 1
fi

# Create output directory
print_status "Creating output directory..."
mkdir -p "$OUTPUT_DIR"
print_success "Output directory: $OUTPUT_DIR"

# Check if CV file exists
if [[ -f "$CV_FILE" ]]; then
    print_status "Using CV file: $CV_FILE"
else
    print_error "$CV_FILE not found"
    exit 1
fi

# Compile the CV
echo "========================================"
print_status "Compiling CV: $CV_FILE"
echo "========================================"

# First compilation
pdflatex -interaction=nonstopmode "$CV_FILE"
FIRST_EXIT_CODE=$?

if [[ $FIRST_EXIT_CODE -ne 0 ]]; then
    print_warning "First compilation failed, trying again..."
    pdflatex -interaction=nonstopmode "$CV_FILE"
    SECOND_EXIT_CODE=$?
    
    if [[ $SECOND_EXIT_CODE -ne 0 ]]; then
        print_error "Both compilation attempts failed!"
        print_error "Check the .log file for details."
        exit 1
    fi
fi

# Check if PDF was generated
PDF_NAME="${CV_FILE%.tex}.pdf"
if [[ -f "$PDF_NAME" ]]; then
    echo "========================================"
    print_success "Compilation successful!"
    echo "========================================"
    
    # Copy PDF to output directory with timestamp
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    OUTPUT_PDF="$OUTPUT_DIR/CV_Hossein_Gholami_$TIMESTAMP.pdf"
    
    cp "$PDF_NAME" "$OUTPUT_PDF"
    print_success "PDF copied to: $OUTPUT_PDF"
    
    # Clean up auxiliary files
    for ext in aux log out; do
        if [[ -f "${CV_FILE%.tex}.$ext" ]]; then
            rm -f "${CV_FILE%.tex}.$ext"
        fi
    done
    rm -f "$PDF_NAME"
    
    # Display file info
    FILE_SIZE=$(ls -lh "$OUTPUT_PDF" | awk '{print $5}')
    print_status "Generated PDF size: $FILE_SIZE"
    
    # Try to open the output directory
    if command_exists xdg-open; then
        xdg-open "$OUTPUT_DIR" 2>/dev/null &
    elif command_exists open; then
        open "$OUTPUT_DIR" 2>/dev/null &
    elif command_exists explorer; then
        explorer "$OUTPUT_DIR" 2>/dev/null &
    fi
    
    echo "========================================"
    print_success "Done! Your CV is ready."
    echo "========================================"
    
else
    echo "========================================"
    print_error "Compilation failed!"
    echo "========================================"
    print_error "PDF was not generated. Check the log file for errors."
    LOG_FILE="${CV_FILE%.tex}.log"
    if [[ -f "$LOG_FILE" ]]; then
        print_status "Log file: $LOG_FILE"
        print_status "Last 20 lines of log file:"
        tail -20 "$LOG_FILE"
    fi
    exit 1
fi 