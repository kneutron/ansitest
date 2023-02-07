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

<#
# Alt method OTF, use convert-from-csv: - NOTE format-table needs to be LAST
# PS > (gdf -hT) -replace '\s+',',' | convertfrom-csv |Where-Object Type -like 'zfs' |Format-Table

# REF: https://stackoverflow.com/questions/15040460/sort-object-and-integers
# Cast csv column OTF as integer for sorting
# PS > (gdf -T) -replace '\s+',',' -replace '%',''| convertfrom-csv |Where-Object Type -like 'zfs' `
|Sort-Object {[int]$_.Use} |Format-Table

Filesystem                                     Type 1K-blocks  Used       Available  Use Mounted
----------                                     ---- ---------  ----       ---------  --- -------                      
/dev/disk6s1                                   zfs  55725472   448        55725024   1   /Volumes/zsam53              
/dev/disk8s1                                   zfs  2089958804 440        2089958364 1   /Volumes/zhgstera6           
zhgstera6/shrcompr-gz3                         zfs  2121152668 31194304   2089958364 2   /Volumes/zhgstera6/shrcompr-…
zhgstera6/tmpdel-xattrsa                       zfs  2148201824 58243460   2089958364 3   /Volumes/zhgstera6/tmpdel-xa…
zsam53/dot-thunderbird-linux                   zfs  57928244   2203220    55725024   4   /Volumes/zsam53/dot-thunderb…
zint500/dvdrips-shr-zint500                    zfs  87848348   4166832    83681516   5   /Volumes/zint500/dvdrips-shr…
zhgstera6/virtbox-virtmachines-linux           zfs  2248803996 158845632  2089958364 8   /Volumes/zhgstera6/virtbox-v…
zhgstera6/notshrcompr-zhgst6                   zfs  2474267964 384309600  2089958364 16  /Volumes/zhgstera6/notshrcom…
zhgstera6/dvdrips-shr                          zfs  2615991212 526032848  2089958364 21  /Volumes/zhgstera6/dvdrips-s…

=====

The Long Format
     If the -l option is given, the following information is displayed for each file: file mode, number of
     links, owner name, group name, number of bytes in the file, abbreviated month, day-of-month file was
     last modified, hour file last modified, minute file last modified, and the pathname

drwxr-xr-x  4 dave  staff   136 Feb  1 13:21 bkps

#									    vv also Year
$header='perms','links','owner','group','size','datemonth','datemonthday','hourminuteoryear','name'

# LS - display only ps1 - dont ask me why we have to replace multiple commas twice
#SKIP# (ls -lrt) -replace '\s',',' -replace '@,',',' -replace ',,',',' -replace ',,',',' |Out-String `

PS > (ls -lrt) -replace '\s',',' -replace ',,',',' -replace ',,',',' |Out-String `
|convertfrom-csv -Header $header `
|Where-Object Name -like '*.ps1' `
|Format-Table

perms      links owner group size datemonth datemonthday hourminute name
-----      ----- ----- ----- ---- --------- ------------ ---------- ----
-rwxr-xr-x 1     dave  staff 83   Jan       13           16:33      hashtable.ps1

PS> (ls -lrt) -replace '\s',',' -replace ',,',',' -replace ',,',',' |Out-String `
|convertfrom-csv -Header $header `
|Where-Object datemonth -like 'Jan' `
|Format-Table  

perms       links owner group size datemonth datemonthday hourminuteoryear name
-----       ----- ----- ----- ---- --------- ------------ ---------------- ----
-rwxr-xr-x  1     dave  staff 83   Jan       13           16:33            hashtable.ps1
-rwxr-xr-x@ 1     dave  staff 621  Jan       23           10:51            get-pc-info.ps1


PS /Volumes/zhgstera6/shrcompr-zhgst6> (ls -lrt) -replace '\s',',' -replace ',,',',' -replace ',,',',' `
|Out-String |convertfrom-csv -Header $header `
|Where-Object size -gt 50000 `
|Format-Table       

perms       links owner group size      datemonth datemonthday hourminuteoryear name
-----       ----- ----- ----- ----      --------- ------------ ---------------- ----
-rwxrwxr-x  1     dave  dave  727080111 Jan       31           2020             Star_Trek-Picard_Free_Series_Premiere…
-rw-rwxr--  1     dave  staff 72453489  May       14           2020             Katy_Perry-Daisies_Official-NutHKRKBg…
-rwxr-xr-x  1     dave  dave  90975484  Jun       18           2020             balena-etcher-electron-1.5.99-linux-x…
-rwxrwxr-x  1     dave  dave  83886080  Jul       3            2020             OpenZFS_on_OS_X_1.9.4.dmg
-rw-rwxr--  1     dave  dave  906679642 Apr       29           2021             wsl-AlmaLinux8.zip
-rw-rwxr--  1     dave  dave  68771041  Jul       3            2021             squidserver7-kn-JEOS-201303.7z
-rw-rwx---  1     dave  dave  919955725 Jul       10           2021             test-zfs-21-Draid-xfs.7z
-rw-rw-r--  1     dave  dave  82658304  Apr       20           2022             vscode-code_1.66.2-1649664567_amd64.d…
-rw-------  1     dave  dave  533171860 Oct       16           19:42            VMware-Player-Full-16.2.0-18760230.x8…
-rw-r--r--@ 1     dave  dave  536072059 Oct       21           12:59            VMware-Workstation-Full-15.5.2-157852…
-rw-r--r--@ 1     dave  dave  91512032  Oct       25           11:54            virtualbox-7.0_7.0.2-154219_Debian_bu…
-rw-r--r--@ 1     dave  dave  519045120 Nov       3            19:39            veeam-recovery-media-5.0.2.4567_x86_6…


# Display only certain fields, sort by size small to large - NOTE \s+
PS /Volumes/zhgstera6/shrcompr-zhgst6> (ls -lrS) -replace '\s+',',' -replace ',,',',' -replace ',,',',' `
|Out-String |convertfrom-csv -Header $header `
|Select-Object -Property perms,owner,group,size,name `
|Format-Table       

perms       owner group size      name
-----       ----- ----- ----      ----
total                             
drwxrwxr-x  dave  dave  3         vm-ansible-controller
drwxrwxr-x  dave  dave  3         send-to-zfs-shared.workflow
drwxrwxr-x  dave  dave  3         etc-wicd-scripts-postconnect
drwxr-xr-x  dave  dave  3         dvdrips
drwxrw----  dave  dave  3         config
drwxr-xr-x  dave  dave  3         bkps-AOMEI


# must match multiple criteria
PS /Volumes/zhgstera6/shrcompr-zhgst6> (ls -lrt) -replace '\s',',' -replace ',,',',' -replace ',,',',' `
 |Out-String |convertfrom-csv -Header $header `
 |Where-Object size -gt 50000 `
 |Where-Object name -like '*.zip' `
 |Format-Table       

perms      links owner group size      datemonth datemonthday hourminuteoryear name
-----      ----- ----- ----- ----      --------- ------------ ---------------- ----
-rwxr-xr-x 1     dave  dave  90975484  Jun       18           2020             balena-etcher-electron-1.5.99-linux-x6…
-rw-rwxr-- 1     dave  dave  906679642 Apr       29           2021             wsl-AlmaLinux8.zip


parse PS -ef:
  UID   PID  PPID   C STIME   TTY           TIME CMD
    0     1     0   0 12Jan23 ??       126:45.39 /sbin/launchd
    0    42     1   0 12Jan23 ??         4:53.92 /usr/sbin/syslogd

PS > (ps -ef) -replace '\s+',',' |convertfrom-csv |select PID,TIME,CMD |Where-Object CMD -like 'bash'

WARNING: One or more headers were not specified. Default names starting with "H" have been used in place of any missing headers.

PID   TIME    CMD
---   ----    ---
2122  0:00.25 bash
2463  0:00.38 bash
2464  0:00.24 bash
2466  0:00.21 bash
2465  0:00.21 bash
94301 0:00.73 bash
92180 0:00.24 bash
92289 0:00.22 bash
11615 0:00.29 bash

# NOTE does not handle spaces for things like "Google Chrome"
PS > (ps -ef) -replace '\s+',',' |convertfrom-csv |select PID,TIME,CMD |Where-Object {$_.CMD -Like '*thunderbird'}

PS > (ps -ef) -replace '\s+',',' |convertfrom-csv |select PID,TIME,CMD |Where-Object {$_.CMD -Like '*irtual*'}

WARNING: One or more headers were not specified. Default names starting with "H" have been used in place of any missing headers.

PID   TIME      CMD
---   ----      ---
2836  11:06.03  /Applications/VirtualBox.app/Contents/MacOS/VirtualBox
2838  32:10.06  /Applications/VirtualBox.app/Contents/MacOS/VBoxXPCOMIPCD
2840  101:13.55 /Applications/VirtualBox.app/Contents/MacOS/VBoxSVC
2885  553:41.95 /Applications/VirtualBox.app/Contents/Resources/VirtualBoxVM.app/Contents/MacOS/VirtualBoxVM
30766 0:08.96   /Applications/VirtualBox.app/Contents/MacOS/VBoxNetDHCP

#>
