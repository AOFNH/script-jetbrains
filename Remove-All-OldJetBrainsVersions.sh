#!/bin/bash

# Define the paths to JetBrains folders in Application Support, Caches, and Logs
config_path="$HOME/Library/Application Support/JetBrains"
cache_path="$HOME/Library/Caches/JetBrains"
logs_path="$HOME/Library/Logs/JetBrains"

# Ask the user for software list input
read -p "Enter the software list separated by commas (e.g., 'WebStorm,DataGrip,IntelliJIdea'), or press Enter to use default values: " user_input

# If the user input is empty, use the default software list
if [ -z "$user_input" ]; then
    software_list=("WebStorm" "DataGrip" "IntelliJIdea")
else
    IFS=',' read -ra software_list <<< "$user_input"
fi

# Initialize foundSoftware with all software set to false
declare -A foundSoftware
for software in "${software_list[@]}"; do
    foundSoftware[$software]=false
done

# Function to process JetBrains directories
process_directories() {
    for software in "${software_list[@]}"; do
        dirs_to_remove=()

        # Find directories matching software and version pattern
        directories=$(find "$1" -maxdepth 1 -mindepth 1 -type d -name "$software*" | sort -rV)

        if [[ $directories ]]; then
            foundSoftware[$software]=true

            # Read all but the newest directory into an array
            read -ra dirs_to_remove <<< "$(echo "$directories" | sed -n '1!p')"

            for dirToRemove in "${dirs_to_remove[@]}"; do
                read -p "Do you want to remove the directory $dirToRemove? [Y/N] " user_confirmation

                if [ "$user_confirmation" == "Y" ] || [ "$user_confirmation" == "y" ]; then
                    # Remove directory
                    # rm -rf "$dirToRemove"
                    echo "Removed directory: $dirToRemove"
                else
                    echo "Skipped directory: $dirToRemove"
                fi
            done
        fi
    done
}

# Process directories in Application Support, Caches, and Logs
process_directories "$config_path"
process_directories "$cache_path"
process_directories "$logs_path"

# Check if any software was not found in any of the paths
for software in "${software_list[@]}"; do
    if [ "${foundSoftware[$software]}" == false ]; then
        echo "No directories found for software: $software"
    fi
done