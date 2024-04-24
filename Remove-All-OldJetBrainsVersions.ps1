# Define the paths to JetBrains folders in Roaming and Local
$paths = @("$HOME\AppData\Roaming\JetBrains", "$HOME\AppData\Local\JetBrains")
# Ask the user for software list input
$userInput = Read-Host "Enter the software list separated by commas (e.g., 'WebStorm,DataGrip,IntelliJIdea'), or press Enter to use default values"
# If the user input is empty, use the default software list
$softwareList = if ($userInput -eq '') {
    "WebStorm", "DataGrip", "IntelliJIdea"
}
else {
    $userInput.Split(',').Trim()
}
# Process each specified JetBrains path
foreach ($path in $paths) {
    if (Test-Path $path) {
        foreach ($software in $softwareList) {
            $directories = Get-ChildItem -Path $path -Directory | Where-Object { $_.Name -match "^$software" }
            $sortedDirectories = $directories | Sort-Object { [regex]::Match($_.Name, "\d+\.\d+$").Value -as [Version] }
            $directoriesToRemove = $sortedDirectories | Select-Object -SkipLast 1
            # Interact with the user for each directory before removing it
            foreach ($dirToRemove in $directoriesToRemove) {
                $userConfirmation = Read-Host "Do you want to remove the directory $($dirToRemove.FullName)? [Y/N]"
                if ($userConfirmation -eq 'Y') {
                    # Remove-Item $dirToRemove.FullName -Recurse -Force
                    Write-Host "Removed directory: $($dirToRemove.FullName)"
                }
                else {
                    Write-Host "Skipped directory: $($dirToRemove.FullName)"
                }
            }
        }
    }
    else {
        Write-Host "Path not found: $path"
    }
}