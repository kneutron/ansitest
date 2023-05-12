<# REF: https://www.reddit.com/r/PowerShell/comments/10dbu5o/find_frequent_event_viewer_errors_lookup_their/
#>

# Clear the console screen for a fresh start
Clear-Host

# Function to retrieve and filter events from the System log
function Get-SystemEvents {
    # Retrieve events from the "System" event log that have a level of 2 or 3
    Get-WinEvent -LogName System -FilterXPath "*[System[Level=2 or Level=3]]" |

    # Create a custom object for each event
    ForEach-Object {
        [PSCustomObject]@{
            EventID = $_.Id
            Message = $_.Message
            Count = 1
        }
    } |

    # Group the objects by the EventID
    Group-Object -Property EventID |

    # Sort the groups by the Count in descending order
    Sort-Object -Property Count -Descending |

    # Select the first 5 groups
    Select-Object @{Name='Count'; Expression={$_.Count}},
    @{Name='Event ID'; Expression={$_.Group[0].EventID}},
    @{Name='Message'; Expression={$_.Group[0].Message}} -First 5
}

Write-Host "Checking your computer for most frequent errors..." -ForegroundColor Yellow

# Pause so user can read
Start-Sleep 3

# Call the function once to display results in console
Get-SystemEvents |

# Without Out-Host piped, Write-Host will steal the spotlight and hide function output
 Out-Host

# Inform user you will find solutions
Write-Host "Please wait. I will retrieve your solutions..." -ForegroundColor Green

# Put the events into a variable to iterate through
$Events = Get-SystemEvents

# Pause so user can read
Start-Sleep 5

# Iterate through each event
foreach ($Event in $Events) {
    # Create a search string by combining the EventID and Message properties
    $SearchString = "$($Event.EventID) $($Event.Message)"
    # Replace spaces with "+"
    $SearchString = $SearchString -replace ' ', '+'
    # Open the search results in Microsoft Edge (in case default browser is set to a malware browser)
    Start-Process "msedge.exe" -ArgumentList "https://www.bing.com/search?q=$SearchString+site:microsoft.com"
}
