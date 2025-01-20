# Get a list of all user accounts
$accounts = Get-CimInstance -ClassName Win32_UserAccount

# Display the list of user accounts
Write-Host "List of user accounts:" -ForegroundColor Green
foreach ($account in $accounts) {
    Write-Host "$($account.Name) ($($account.FullName))"
}

# Ask the user for input of account names to delete
Write-Host "`nEnter the names of the accounts you want to delete separated by spaces:" -NoNewline
$userInput = Read-Host

# Split the entered data into separate elements
$selectedAccounts = $userInput.Split(" ")

# Check and delete the selected accounts
foreach ($name in $selectedAccounts) {
    # Validate that the provided name exists in the list of accounts
    $validAccount = $accounts | Where-Object { $_.Name -eq $name }
    
    if ($null -ne $validAccount) {
        # Find the account by its name
        $accountToDelete = $accounts | Where-Object { $_.Name -eq $name }
        
        if ($null -ne $accountToDelete) {
            # Get the account's SID
            $sid = $accountToDelete.SID
            
            try {
                # Delete the user's folder
                $userFolderPath = "C:\Users\$name"
                if (Test-Path $userFolderPath) {
                    Remove-Item -Path $userFolderPath -Recurse -Force
                    Write-Host "The user folder for '$name' has been deleted." -ForegroundColor Yellow
                }
                else {
                    Write-Host "The user folder for '$name' was not found." -ForegroundColor Red
                }

                # Delete the user's profile from the registry
                $profilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid"
                if (Test-Path $profilePath) {
                    Remove-Item -Path $profilePath -Recurse -Force
                    Write-Host "The profile for account '$name' has been removed from the registry." -ForegroundColor Yellow
                }
                else {
                    Write-Host "The profile for account '$name' was not found in the registry." -ForegroundColor Red
                }              
            }
            catch {
                Write-Warning "An error occurred while deleting account '$name': $_"
            }
        }
        else {
            Write-Host "The account '$name' was not found." -ForegroundColor Red
        }
    }
    else {
        Write-Warning "The account '$name' does not exist."
    }
}
