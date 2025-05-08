#!/bin/bash

# This script merges the notification strings into the main localization files

# Function to merge JSON files
merge_json() {
  local source_file=$1
  local target_file=$2
  
  # Remove the last closing brace
  sed -i '' -e '$s/}$//' "$target_file"
  
  # Remove the opening brace and add a comma from the source file
  content=$(cat "$source_file" | tail -n +2)
  
  # Append the content to the target file
  echo "," >> "$target_file"
  echo "$content" >> "$target_file"
}

# Merge English strings
merge_json "assets/notifications/notification_strings_en.arb" "assets/l10n/app_en.arb"

# Merge Portuguese strings
merge_json "assets/notifications/notification_strings_pt.arb" "assets/l10n/app_pt.arb"

# Merge Spanish strings
merge_json "assets/notifications/notification_strings_es.arb" "assets/l10n/app_es.arb"

echo "Localization strings merged successfully!"