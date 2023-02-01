<# Turn just about any *nix command output into a parsable PS object 

Tested with Powershell 7.1.7 on OSX 10.13 High Sierra

Author: kingneutron@gmail.com
# 2023.0131

REQUIRES: gdf 		installed from brew or macports, available in $PATH

# Call script with $0 1 	for demo, you can also pipe output |less for pager

# REF: https://devblogs.microsoft.com/powershell-community/converting-string-output-to-objects/
# REF: https://devblogs.microsoft.com/scripting/powertip-customize-table-headings-with-powershell/
# REF: https://sid-500.com/2021/06/23/powershell-manipulating-strings-with-trim-trimstart-and-trimend-method/

# Provides functions if sourced: ' . ./$0 '
# parseGDFHT
# parseGDFT
#>

# REF: https://www.computerperformance.co.uk/powershell/if-and/

$demo = 0
$chkarg = $Args[0]
if ($chkarg -eq '1' -Or $chkarg -eq "demo") {
  $demo = 1
}

if ($demo -gt 0) {

    $lines = gdf -hT
<#
Filesystem                                     Type  Size  Used Avail Use% Mounted on
/dev/disk3s2                                   hfs   187G  151G   36G  81% /
/dev/disk6s1                                   zfs    54G  448K   54G   1% /Volumes/zsam53
zsam53/dot-thunderbird-linux                   zfs    56G  2.2G   54G   4% /Volumes/zsam53/dot-thunderbird-linux
zsam53/dvdrips-shr-zsam53                      zfs    54G  480K   54G   1% /Volumes/zsam53/dvdrips-shr-zsam53
#>

# skip the header line
    $columns = ($lines[2] -split ' ').Trim() | Where-Object {$_ }
# DEBUGG
    $columns
}

function parseGDFHT {
    param([object[]]$Lines)
    $skip = 1

    $Lines `
    | Select-Object -Skip $skip `
    | ForEach-Object `
        {
        $columns = ($_ -split ' ').Trim() | Where-Object {$_ }
        [pscustomobject]@{
            Filesystem = $columns[0]
            Type = $columns[1]
            Size = $columns[2]
            Used = $columns[3]
            Avail = $columns[4]
            Usepct = [int]$columns[5].Trim('%') # cast as integer to make useful for sorting
            MountedOn = $columns[6]
        } # customobj
    } # lines
} # func

if ($demo -gt 0) {

    Write-Output "Limit to last 10:"
    parseGDFHT (gdf -hT) `
    | Select-Object -Last 10 `
    | Format-Table -AutoSize

    Write-Output "Select only zfs filesystems:"
    parseGDFHT (gdf -hT) `
    | Where-Object {$_.Type -eq 'zfs'} `
    | Format-Table -AutoSize
}

<# gdf -T
Filesystem                                     Type  1K-blocks       Used  Available Use% Mounted on
/dev/disk3s2                                   hfs   195618588  157638992   37723596  81% /
/dev/disk6s1                                   zfs    55725472        448   55725024   1% /Volumes/zsam53
#>

function parseGDFT {
    param([object[]]$Lines)
    $skip = 1

#$tmp = '89%'         
#$tmp2 = $tmp -replace '%',''
#$tmp2
#89
# REF: https://learn.microsoft.com/en-us/powershell/scripting/lang-spec/chapter-04?view=powershell-7.3
# ^ Casting to decimal and int var types
    $Lines `
    | Select-Object -Skip $skip `
    | ForEach-Object `
        {
        $columns = ($_ -split ' ').Trim() | Where-Object {$_ }
        [pscustomobject]@{
            Filesystem = $columns[0]
            Type = $columns[1]
            Size = [decimal]$columns[2] # bignum to make useful for sorting
            Used = [decimal]$columns[3]
            Avail = [decimal]$columns[4]
            Usepct = [int]$columns[5].Trim('%')
            MountedOn = $columns[6]
        } # customobj
    } # lines
} # func


if ($demo -gt 0) {

    Write-Output "Select only FS Available over 79GB:" # 80*1024*1024 = 83886080
    $criteria = 79*1024*1024

    parseGDFT (gdf -T) `
    | Where-Object {$_.Avail -ge $criteria } `
    | Format-Table -AutoSize

    Write-Output "Select only FS with 50%+ available:"
    parseGDFT (gdf -T) `
    | Where-Object {$_.Usepct -ge 50} `
    | Format-Table -AutoSize

#gdf -T |awk '{$1="";$3=""; print}'
#Type  Used Available Use% Mounted on
#hfs  157650784 37711804 81% /

    Write-Output "Display only certain fields df-short sorted by largest avail space:"
    parseGDFT (gdf -T) `
    | Sort-Object -Property Avail `
    | Format-Table -AutoSize -Property Type, Used, Avail, Usepct, MountedOn
    
    Write-Output "Rename output fields on the fly:"
#Get-Process notepad |
#      Format-Table ProcessName, @{Label="TotalRunningTime"; Expression={(Get-Date) - $_.StartTime}}    
    parseGDFT (gdf -T) `
    | Format-Table -AutoSize Filesystem, MountedOn, @{L="PctUsed"; E={$_.Usepct} }

# REF: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/sort-object?view=powershell-7.3
    Write-Output "Sort by percent-used field with only certain columns displayed:"
    parseGDFT (gdf -T) `
    | Sort-Object -Property Usepct -Descending `
    | Format-Table -AutoSize -Property Type, Used, Avail, Usepct, MountedOn

}

# Alt method:
# (gdf -hT) -replace '\s+',',' | convertfrom-csv |Where-Object Type -like 'zfs' |Format-Table
