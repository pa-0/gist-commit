#!/bin/bash

# Archives a specified website including all sub-pages and outputs a single PDF file

# Requires the following tools to be installed:
# - wget
# - wkhtmltopdf
# - gs (ghostscript)

# Installation:
#
# Download this script and make it executable:
#   chmod +x website_to_pdf.sh

# Usage
#
#   ./website_to_pdf.sh <URL> <output_pdf>



# Function to download the website and generate a list of HTML files
download_website() {
    url="$1"
    output_dir="$2"
    links_file="$3"

    wget -r -np -k -p -P "$output_dir" "$url" &> "$links_file"
    sed -n "s/.*Saving to: ‘\([^’]*\).*/\1/p" "$links_file" 
}

# Function to generate PDFs from HTML files and concatenate them
generate_pdf() {
    input_list="$1"
    output_pdf="$2"
    temp_dir="$3"

    pdf_files=""
    total_files=$(wc -l < "$input_list" | tr -d '[:space:]')
    current_file=1

    while IFS= read -r html_file; do
        pdf_file="${temp_dir}/$(basename "$html_file" .html).pdf"
        echo "Converting ($current_file of $total_files): $html_file to $pdf_file"
        wkhtmltopdf "$html_file" --disable-javascript --enable-local-file-access "$pdf_file"
        pdf_files="$pdf_files $pdf_file"
        current_file=$((current_file + 1))
    done < "$input_list"

    # Concatenate all PDF files
    echo "Merging PDF files into $output_pdf"
    gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$output_pdf" $pdf_files
}

main() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 <URL> <output_pdf>"
        exit 1
    fi

    url="$1"
    output_pdf="$2"
    temp_dir="$(mktemp -d)"
    links_file="$(mktemp)"
    html_list="$(mktemp)"

    echo "Downloading website $url to temp dir ($temp_dir)"
    download_website "$url" "$temp_dir" "$links_file" > "$html_list"
    generate_pdf "$html_list" "$output_pdf" "$temp_dir"

    # Clean up temporary files
    rm -rf "$temp_dir" "$links_file" "$html_list"
}

main "$@"
