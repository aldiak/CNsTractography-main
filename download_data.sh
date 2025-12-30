# #!/bin/bash

# # This script assumes the list of URLs is saved in a file named 'urls.txt' in the same directory,
# # with one URL per line (copy-paste the content from the document into urls.txt).
# # It will download each .tar.gz file, extract it to the current directory, and delete the .tar.gz file afterward.

# # Create a directory to store the extracted data (optional, to keep things organized)
# mkdir -p East_West_WM_Atlas,
# cd East_West_WM_Atlas, || exit

# # Loop through each URL in the file
# while IFS= read -r url; do
#     # Extract the filename from the URL (using the fileName parameter)
#     filename=$(echo "$url" | grep -oP 'fileName=\K\S+')

#     echo "Filename URL: $filename (no filename found)"
    
#     if [ -z "$filename" ]; then
#         echo "Skipping invalid URL: $url (no filename found)"
#         continue
#     fi
    
#     echo "Downloading $filename..."
#     wget -q --show-progress "$url" -O "$filename"
    
#     if [ $? -ne 0 ]; then
#         echo "Failed to download $filename. Skipping."
#         rm -f "$filename"
#         continue
#     fi
    
#     echo "Extracting $filename..."
#     tar -xzf "$filename"
    
#     if [ $? -eq 0 ]; then
#         echo "Extraction complete. Deleting $filename..."
#         rm "$filename"
#     else
#         echo "Failed to extract $filename. Keeping the archive for inspection."
#     fi
    
#     echo "-----------------------------------"
# done < /media/alou/disk2/url.txt

# echo "All downloads and extractions complete."


#!/bin/sh
# Use this script as your openneuro special remote when using datalad or git-annex to access annexed objects

# For scripts
aws s3 sync --no-sign-request s3://openneuro.org/ds004910 ds004910-download/ 
export OPENNEURO_API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2ZjU4Nzk5ZS0zZGZlLTQ0NjktYTc5Yi02MzRiZTEzM2FjYzYiLCJwcm92aWRlciI6Im9yY2lkIiwibmFtZSI6IkFsb3UgRGlha2l0ZSIsImFkbWluIjpmYWxzZSwiaWF0IjoxNzUzNzA4NzE1LCJleHAiOjE3ODUyNDQ3MTV9.vkePbT9XxHKvOm7-hKy1MWpGAdoSsocF2RWh_2wHpYU"
openneuro login --error-reporting true
deno run -A jsr:@openneuro/cli special-remote
#openneuro download ds005713 /mnt/siat118_disk2/alou/TN
openneuro download ds004910 /mnt/disk1/
