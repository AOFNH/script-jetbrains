#!/bin/bash

# Define the paths to JetBrains folders in Application Support, Caches, and Logs
paths=(
  "$HOME/Library/Application Support/JetBrains"
  "$HOME/Library/Caches/JetBrains"
  "$HOME/Library/Logs/JetBrains"
)

# Initialize a associative array to track found software
declare -A foundSoftware

# Ask the user for software list input
read -p "Enter the software list separated by commas (e.g., 'WebStorm,DataGrip,IntelliJIdea'), or press Enter to use default values: " userInput

# If the user input is empty, use the default software list
if [[ -z "$userInput" ]]; then
  softwareList=("WebStorm" "DataGrip" "IntelliJIdea")
else
  IFS=',' read -r -a softwareList <<< "$userInput"
fi

# Initialize foundSoftware with all software set to false
for software in "${softwareList[@]}"; do
  foundSoftware[$software]=false
done

# Process each specified JetBrains path
for path in "${paths[@]}"; do
  if [[ -d "$path" ]]; then
    for software in "${softwareList[@]}"; do
      directories=($(find "$path" -type d -name "$software*"))
      if [[ ${#directories[@]} -gt 0 ]]; then
        foundSoftware[$software]=true
        # Sort the directories to find the oldest ones (assuming version format)
        IFS=$'\n' sortedDirectories=($(sort -V <<<"${directories[*]}"))
        unset IFS
        # We skip the last (newest) directory and consider old ones for removal
        directoriesToRemove=("${sortedDirectories[@]:0:${#sortedDirectories[@]}-1}")
        # Interact with the user for each directory before removing it
        for dirToRemove in "${directoriesToRemove[@]}"; do
          read -p "Do you want to remove the directory $dirToRemove? [Y/N]: " userConfirmation
          if [[ "$userConfirmation" == "Y" ]]; then
            # rm -rf "$dirToRemove"
            echo "Removed directory: $dirToRemove"
          else
            echo "Skipped directory: $dirToRemove"
          fi
        done
      fi
    done
  else
    echo "Path not found: $path"
  fi
done

# Check if any software was not found in any of the paths
for software in "${softwareList[@]}"; do
  if [[ ${foundSoftware[$software]} == false ]]; then
    echo "No directories found for software: $software"
  fi
done