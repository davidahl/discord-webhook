#!/bin/bash

# # Specify the file name (adjust as needed)
# filename="/home/david/code/hej/your_file.txt"
tempfile=$(mktemp)
# Specify your Discord Webhook URL here
WEBHOOK_URL="https://discord.com/api/webhooks/WEBHOOK"

declare -a arr=("/home/david/code/hej/trapp_5.txt" "/home/david/code/hej/trapp_3.txt")

discord_message="Trappstäd denna veckan har: \n"
# Loop through all files
for filename in "${arr[@]}"
do

# Read the file into an array
mapfile -t lines < "$filename"
num_lines=${#lines[@]}

# Flag to track if "1" was already found and processed
  found=0

  # Process the file line by line
  for i in "${!lines[@]}"
  do
    # Split the line by comma into name and number
    IFS=',' read -r stair name number <<< "${lines[$i]}"

    # If "1" is found and not processed yet
    if [ "$number" -eq 1 ] && [ "$found" -eq 0 ]; then
      # Print the name and setup message
      discord_message+="$stair $name \n"

      # Mark as processed
      found=1
      # Set the current entry to "0"
      lines[$i]="$stair,$name, 0"


      
      # Now set the next name to "1"
      next_index=$(( (i + 1) % num_lines ))  # This handles the circular behavior
      IFS=',' read -r stair next_name next_number <<< "${lines[$next_index]}"
      lines[$next_index]="$stair,$next_name, 1"
      break
    fi
  done

  # Write the updated lines back to the file
  for line in "${lines[@]}"; do
    echo "$line" >> "$tempfile"
  done

  # Replace the original file with the updated content
  mv "$tempfile" "$filename"
done

echo -e "$discord_message"

# Send a message to Discord Webhook with the name
curl -X POST -H "Content-Type: application/json" \
  -d "{\"content\": \"$discord_message\"}" \
  "$WEBHOOK_URL"