<# REF: https://techgenix.com/adding-a-progress-bar-to-your-powershell-scripts/ #>

cd /Volumes/zhgstera6/shrcompr-zhgst6

$List = Get-Childitem

$TotalItems=$List.Count
$CurrentItem = 0
$PercentComplete = 0

ForEach($file in $List)
{
Write-Progress -Activity "LS Filenames" `
 -Status "$PercentComplete% Complete: $CurrentItem / $TotalItems" `
 -PercentComplete $PercentComplete

# do a thing here
#$Name = $VM.Name
#Get-VM -Name $Name

$CurrentItem++
$PercentComplete = [int](($CurrentItem / $TotalItems) * 100)
Start-Sleep -Milliseconds 10
}
