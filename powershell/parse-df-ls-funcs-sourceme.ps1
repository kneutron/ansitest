<# Turn just about any *nix command output into a parsable PS object 

HOWTO display all functions in this script: Select-String -Path parse-df-ls-funcs-sourceme.ps1 -Pattern "function"

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

function dfhtzfssortbypct { # how to call this func: dfhtzfssortbypct (gdf -T)
    param([object[]]$Lines)

#Write-Host "DFT - Display zfs filesystems only and sort by largest use% column  low..high"
#(gdf -T) 
    $Lines -replace '\s+',',' -replace '%','' `
    | convertfrom-csv `
    |  Where-Object Type -like 'zfs' `
    |  Sort-Object {[int]$_.Use} `
    |Format-Table

} # func

function dftzfssortbymostfreespace { # how to call this func: dftzfssortbymostfreespace (gdf -T)
    param([object[]]$Lines)

#Write-Host "DFT - Display zfs filesystems only and sort by largest use% column  low..high"
#(gdf -T) 
    $Lines -replace '\s+',',' -replace '%','' `
    | convertfrom-csv `
    |  Where-Object Type -like 'zfs' `
    | select Filesystem,Type,1k-blocks,Used,Available,Mounted `
    |  Sort-Object {[decimal]$_.Available} -Descending `
    |Format-Table

} # func

function dftzfsnomountedsortbymostfreespace { # how to call this func: funcname (gdf -T)
    param([object[]]$Lines)

#Write-Host "DFT - Display zfs filesystems only and sort by largest use% column  low..high"
#(gdf -T) 
    $Lines -replace '\s+',',' -replace '%','' `
    | convertfrom-csv `
    |  Where-Object Type -like 'zfs' `
    | select Filesystem,Type,Used,Available,1k-blocks `
    |  Sort-Object {[decimal]$_.Available} -Descending `
    |Format-Table

} # func

function dftzfs4fieldssortbymostusedspace { # how to call this func: funcname (gdf -T)
    param([object[]]$Lines)

#Write-Host "DFT - Display zfs filesystems only and sort by largest use% column  low..high"
#(gdf -T) 
    $Lines -replace '\s+',',' -replace '%','' `
    | convertfrom-csv `
    |  Where-Object Type -like 'zfs' `
    | select Filesystem,Type,Used,1k-blocks `
    |  Sort-Object {[decimal]$_.Used} -Descending `
    |Format-Table

} # func

if ($demo -gt 0) {

# REF: https://stackoverflow.com/questions/2063995/powershell-echo-on
# Equivalent to bash ' set -x '
#Set-PSDebug -Trace 1
#0: Turn script tracing off.
#1: Trace script lines as they run.
#2: Trace script lines, variable assignments, func calls, and scripts.

# Alt method OTF, use convert-from-csv: - NOTE format-table needs to be LAST
# PS > (gdf -hT) -replace '\s+',',' | convertfrom-csv |Where-Object Type -like 'zfs' |Format-Table

# REF: https://stackoverflow.com/questions/15040460/sort-object-and-integers

# Cast csv column "Use%" OTF as integer for sorting and remove the % sign
Write-Output "DFT - Display zfs filesystems only and sort by largest use% column  low..high"
(gdf -T) -replace '\s+',',' -replace '%','' `
| convertfrom-csv `
|  Where-Object Type -like 'zfs' `
|  Sort-Object {[int]$_.Use} `
|Format-Table

<#
Filesystem                                     Type 1K-blocks  Used       Available  Use Mounted
----------                                     ---- ---------  ----       ---------  --- -------                      
/dev/disk6s1                                   zfs  55725472   448        55725024   1   /Volumes/zsam53              
/dev/disk8s1                                   zfs  2089958804 440        2089958364 1   /Volumes/zhgstera6           
zhgstera6/shrcompr-gz3                         zfs  2121152668 31194304   2089958364 2   /Volumes/zhgstera6/shrcompr-…
zhgstera6/tmpdel-xattrsa                       zfs  2148201824 58243460   2089958364 3   /Volumes/zhgstera6/tmpdel-xa…
zsam53/dot-thunderbird-linux                   zfs  57928244   2203220    55725024   4   /Volumes/zsam53/dot-thunderb…
zhgstera6/virtbox-virtmachines-linux           zfs  2248803996 158845632  2089958364 8   /Volumes/zhgstera6/virtbox-v…
zhgstera6/notshrcompr-zhgst6                   zfs  2474267964 384309600  2089958364 16  /Volumes/zhgstera6/notshrcom…
#>

Write-Output "DFT - Display zfs filesystems only and sort by space available column  high..low , omit Use% field"
(gdf -T) -replace '\s+',',' `
| convertfrom-csv `
|  Where-Object Type -like 'zfs' `
| select Filesystem,Type,1k-blocks,Used,Available,Mounted `
|  Sort-Object {[decimal]$_.Available} -Descending `
|Format-Table

<#
Filesystem                                     Type 1K-blocks  Used       Available  Mounted
----------                                     ---- ---------  ----       ---------  -------
zhgstera6/virtbox-virtmachines-linux           zfs  2242779492 158845632  2083933860 /Volumes/zhgstera6/virtbox-virtm…
zhgstera6/virtbox-virtmachines                 zfs  2795502068 711568208  2083933860 /Volumes/zhgstera6/virtbox-virtm…
zhgstera6/tmpdel-xattrsa                       zfs  2142177320 58243460   2083933860 /Volumes/zhgstera6/tmpdel-xattrsa
zhgstera6/shrcompr-zhgst6                      zfs  3304246824 1220312964 2083933860 /Volumes/zhgstera6/shrcompr-zhgs…
zhgstera6/shrcompr-gz3                         zfs  2115128164 31194304   2083933860 /Volumes/zhgstera6/shrcompr-gz3
zhgstera6/osx-home-moved                       zfs  2117395128 33461268   2083933860 /Volumes/zhgstera6/osx-home-moved
zhgstera6/notshrcompr-zhgst6/bkp-bookmarks     zfs  2124029172 40095312   2083933860 /Volumes/zhgstera6/notshrcompr-z…
zhgstera6/notshrcompr-zhgst6                   zfs  2468243460 384309600  2083933860 /Volumes/zhgstera6/notshrcompr-z…
/dev/disk8s1                                   zfs  2083934300 440        2083933860 /Volumes/zhgstera6
zhgstera6/virtbox-virtmachines/nocompr-freebsd zfs  2093468028 9534168    2083933860 /Volumes/zhgstera6/virtbox-virtm…
zint500/shrcompr-zint500                       zfs  124323944  40715408   83608536   /Volumes/zint500/shrcompr-zint500
zint500/virtbox-virtmachines                   zfs  119698008  36089472   83608536   /Volumes/zint500/virtbox-virtmac…
#>

# OOO = "select" order determines which fields are first
Write-Output "DFT - display ZFS filesystems, fields out of order, omit Mounted-on, Sort by most Available space"
(gdf -T) -replace '\s+',',' `
| convertfrom-csv `
|  Where-Object Type -like 'zfs' `
| select Filesystem,Type,Used,Available,1k-blocks `
|  Sort-Object {[decimal]$_.Available} -Descending `
|Format-Table

<#
Filesystem                                     Type Used       Available  1K-blocks
----------                                     ---- ----       ---------  ---------
zhgstera6/virtbox-virtmachines-linux           zfs  158845632  2083933848 2242779480
zhgstera6/virtbox-virtmachines                 zfs  711568208  2083933848 2795502056
zhgstera6/tmpdel-xattrsa                       zfs  58243460   2083933848 2142177308
zhgstera6/shrcompr-zhgst6                      zfs  1220312964 2083933848 3304246812
zhgstera6/shrcompr-gz3                         zfs  31194304   2083933848 2115128152
zhgstera6/osx-home-moved                       zfs  33461268   2083933848 2117395116
zhgstera6/notshrcompr-zhgst6/bkp-bookmarks     zfs  40095312   2083933848 2124029160
zhgstera6/notshrcompr-zhgst6                   zfs  384309600  2083933848 2468243448
/dev/disk8s1                                   zfs  440        2083933848 2083934288
zhgstera6/virtbox-virtmachines/nocompr-freebsd zfs  9534168    2083933848 2093468016
zint500/shrcompr-zint500                       zfs  40715408   83608636   124324044
zint500/virtbox-virtmachines                   zfs  36089492   83608636   119698128
#>

Write-Output "DFT - display ZFS filesystems, fields out of order, omit multiple columns, Sort by most Used space"
(gdf -T) -replace '\s+',',' `
| convertfrom-csv `
|  Where-Object Type -like 'zfs' `
| select Filesystem,Type,Used,1k-blocks `
|  Sort-Object {[decimal]$_.Used} -Descending `
|Format-Table

<#
Filesystem                                     Type Used       1K-blocks
----------                                     ---- ----       ---------
zhgstera6/shrcompr-zhgst6                      zfs  1220312964 3304246812
zhgstera6/virtbox-virtmachines                 zfs  711568208  2795502056
zhgstera6/dvdrips-shr                          zfs  538333192  2622267040
zhgstera6/notshrcompr-zhgst6                   zfs  384309600  2468243448
zhgstera6/virtbox-virtmachines-linux           zfs  158845632  2242779480
zsam53/notshrcompr-zsam53                      zfs  70684008   126126680
zsam53/shrcompr-zsam53                         zfs  67551036   122993708
zint500/notshrcompr-zint500                    zfs  58707900   142316500
zhgstera6/tmpdel-xattrsa                       zfs  58243460   2142177308
#>
} # if demo

<#
=====

LS

The Long Format
     If the -l option is given, the following information is displayed for each file: file mode, number of
     links, owner name, group name, number of bytes in the file, abbreviated month, day-of-month file was
     last modified, hour file last modified, minute file last modified, and the pathname

drwxr-xr-x  4 dave  staff   136 Feb  1 13:21 bkps
#>


#  									         vv also Year
#             1       2       3       4       5      6           7              8                  9
$LSHeadertmp='perms','links','owner','group','size','datemonth','datemonthday','hourminuteoryear','name'

Remove-Variable -Name LSHeader -Scope global -Force -ErrorAction:SilentlyContinue # clear if already set
Set-Variable -Name "LSHeader" -Value $LSHeadertmp -Scope global -Description "globalLSheader" -PassThru 
#Set-Variable -Name "LSHeader" -Value $LSHeadertmp -Option constant -Scope global -Description "globalLSheader" -PassThru 

function lsps1 { # how to call this func: lsps1 (ls -lrt [path])
    param([object[]]$Lines)

#Write-Host "LS - Display only .ps1 files"
#(ls -lrt) 
  $Lines -replace '\s+',',' -replace ',,',',' `
  | convertfrom-csv -Header $LSHeader `
  | Where-Object Name -like '*.ps1' `
  |Format-Table

} # func

function lssortsmallestshort { # how to call this func: funcname (ls -lS [path])
    param([object[]]$Lines)

#Write-Host "LS - Display only certain fields, sort by size small to large, comma-separated size" # - NOTE \s+
#(ls -lS) 
# NOTE Use ls -lrS to sort largest descending
  $Lines -replace '\s+',',' -replace ',,',',' `
  | convertfrom-csv -Header $LSHeader `
  | Select-Object -Property perms,owner,group,@{ n='Size';e={"{0:N0}" -f ($_.size)} },name `
  |  Where-Object perms -ne total `
  |Format-Table

#  | Select-Object -Property perms,owner,group,size,name `

} # func


if ($demo -gt 0) {

# LS - display only ps1 - dont ask me why we have to replace multiple commas twice (was missing \s+
#SKIP# (ls -lrt) -replace '\s',',' -replace '@,',',' -replace ',,',',' -replace ',,',',' |Out-String `
#PS > (ls -lrt) -replace '\s+',',' -replace ',,',',' -replace ',,',',' |Out-String `
##|Out-String ` # is not necessary

Write-Output "LS - Display only .ps1 files"
lsps1 (ls -lrt $HOME/bin/powershell)
#(ls -lrt) -replace '\s+',',' -replace ',,',',' `
#| convertfrom-csv -Header $LSHeader `
#| Where-Object Name -like '*.ps1' `
#|Format-Table

<#
perms      links owner group size datemonth datemonthday hourminute name
-----      ----- ----- ----- ---- --------- ------------ ---------- ----
-rwxr-xr-x 1     dave  staff 83   Jan       13           16:33      hashtable.ps1
#>

Write-Output "LS - filter / leave out extraneous total line and Display files where :group != dave"
cd /Volumes/zhgstera6/shrcompr-zhgst6
(ls -lrt) -replace '\s+',',' -replace ',,',',' `
| convertfrom-csv -Header $LSHeader `
|  Where-Object perms -ne total `
|  Where-Object group -ne 'dave' `
|Format-Table

<#
perms      links owner group size     datemonth datemonthday hourminuteoryear name
-----      ----- ----- ----- ----     --------- ------------ ---------------- ----
-rw-rwxr-- 1     dave  staff 72453489 May       14           2020             Katy_Perry-Daisies_Official-NutHKRKBgR0…
-rw-rwxr-- 1     dave  staff 89774    May       18           2020             Katy_Perry-Daisies_Official-NutHKRKBgR0…
-rwxrwxr-x 1     dave  wheel 703      Aug       23           2020             zpool-upgrade-linux.txt
-rw-rwxr-- 1     dave  wheel 491      Apr       16           2021             zfs-missing-linuxside-086.txt
-rwxr-xr-x 1     dave  wheel 3541     Jun       5            2022             bkpsys-2fsarchive
-rwxr-xr-x 1     dave  staff 103      Oct       11           15:37            fix-console-resolution.sh
-rwxr-xr-x 1     dave  staff 157      Dec       5            15:33            makemkv-getnewkey.sh
-rwxr-xr-x 1     dave  staff 1610     Dec       7            13:57            unpass.sh
-rwxr-xr-x 1     dave  staff 561      Dec       9            15:07            split-motorhead-flac.sh
#>


Write-Output "Display files where datemonth is Jan"
(ls -lrt) -replace '\s+',',' -replace ',,',',' `
| convertfrom-csv -Header $LSHeader `
| Where-Object datemonth -like 'Jan' `
|Format-Table  

<#
perms       links owner group size datemonth datemonthday hourminuteoryear name
-----       ----- ----- ----- ---- --------- ------------ ---------------- ----
-rwxr-xr-x  1     dave  staff 83   Jan       13           16:33            hashtable.ps1
-rwxr-xr-x@ 1     dave  staff 621  Jan       23           10:51            get-pc-info.ps1
#>

<# SKIP THIS - will not sort right as string
#PS /Volumes/zhgstera6/shrcompr-zhgst6> 
(ls -lrt) -replace '\s+',',' -replace ',,',',' `
|convertfrom-csv -Header $LSHeader `
| Where-Object size -gt 50000 `
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
#>

Write-Output "LS - Display only certain fields, sort by size small to large, size as 1KB comma-separated" # - NOTE \s+
#PS /Volumes/zhgstera6/shrcompr-zhgst6> 
(ls -lrS) -replace '\s+',',' -replace ',,',',' `
|convertfrom-csv -Header $LSHeader `
| Select-Object -Property perms,owner,group,@{ n='Size';e={"{0:N0}" -f ($_.size/1KB)} },name `
|  Where-Object perms -ne total `
|Format-Table       

# @{ n='Size';e={"{0:N0}" -f ($_.Size/1KB)} }
<#
perms       owner group size      name
-----       ----- ----- ----      ----
drwxrwxr-x  dave  dave  3         vm-ansible-controller
drwxrwxr-x  dave  dave  3         send-to-zfs-shared.workflow
drwxrwxr-x  dave  dave  3         etc-wicd-scripts-postconnect
drwxr-xr-x  dave  dave  3         dvdrips
drwxrw----  dave  dave  3         config
drwxr-xr-x  dave  dave  3         bkps-AOMEI


# SKIP must match multiple criteria (sort will not work right when size is string instead of number)
# SKIP PS /Volumes/zhgstera6/shrcompr-zhgst6> (ls -lrt) -replace '\s',',' -replace ',,',',' -replace ',,',',' `
#|convertfrom-csv -Header $LSHeader `
#| Where-Object size -gt 50000 `
#| Where-Object name -like '*.zip' `
#|Format-Table       
#>

#$LSHeader='perms','links','owner','group','size','datemonth','datemonthday','hourminuteoryear','name'

# TEST OK PS 7.1.7 on OSX
#$resultobj.GetType().size # Blank!

Write-Output "LS - store results in a var and make an object that can be reused and manipulated different ways"
$result = (ls -lrt) -replace '\s+',',' -replace ',,',',' ;`
 $resultobj = ($result |convertfrom-csv -Header $LSHeader) 

# REF: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/where-object?view=powershell-7.3
Write-Output "LS - Display files that have a size >50MB"
# reCast size to decimal for sorting OTF
$resultobj `
| Where-Object {[decimal]$_.size -gt 50000}
|Format-Table

# Multiple criteria with proper number sort
Write-Output "LS - Look for .zip files that are over 50MB , re-using the same object"
$resultobj `
| Where-Object {[decimal]$_.size -gt 50000} `
| Where-Object name -like '*.zip' `
|Format-Table       

<#
perms       links owner group size      datemonth datemonthday hourminuteoryear name
-----       ----- ----- ----- ----      --------- ------------ ---------------- ----
-rwxrwxr-x  1     dave  dave  358392    Feb       2            2020             font-klingon-pIqaDFontsNormalAndWeb.z…
-rwxrwxr-x  1     dave  dave  6507097   Jun       12           2020             wsusoffline120.zip
-rwxr-xr-x  1     dave  dave  90975484  Jun       18           2020             balena-etcher-electron-1.5.99-linux-x…
-rwxrwxr-x  1     dave  dave  1225899   Jul       5            2020             vocational-cobol.zip
-rwxrwxr-x  1     dave  dave  86568     Aug       1            2020             zfs_autobackup-master.zip
-rwxrwxr-x  1     dave  dave  8323895   Aug       11           2020             win10-Run-in-Sandbox-master.zip
-rw-rwxr--  1     dave  dave  5440144   Jan       16           2021             ccextractor-0.88_no_windows.zip
-rw-rwxr--  1     dave  dave  6506667   Apr       7            2021             wsusofflineCE120.zip
-rw-rwxr--  1     dave  dave  906679642 Apr       29           2021             wsl-AlmaLinux8.zip
-rw-rwxr--  1     dave  dave  8507058   May       14           2021             motherboard-bios-fryserver-Z170-DELUX…
-rw-rwxr--  1     dave  dave  8931021   May       14           2021             motherboard-bios-fryserver-Z170-DELUX…
-rw-rwxr--  1     dave  dave  8712971   May       14           2021             motherboard-bios-fryserver-latest-Z17…
-rw-rwxr--  1     dave  dave  257970    Jul       20           2021             iSCSIInitiator-master.zip
-rwxr-xr-x  1     dave  dave  6295615   Aug       30           2021             barrier-master-like-synergy-pc-contro…
-rw-rw-r--  1     dave  dave  14120730  Nov       27           2021             ventoy-1.0.61-windows.zip
-rw-r--r--  1     dave  dave  130983880 Feb       18           2022             AmazonMusicDownload.zip
-rw-rw-r--  1     dave  dave  2254468   Nov       13           09:53            Win_11_Boot_And_Upgrade_FiX_KiT_v2.1.…
-rw-rw-r--@ 1     dave  dave  324810    Dec       13           12:18            ansitest-master.zip
#>

# https://devblogs.microsoft.com/scripting/powertip-sorting-more-than-one-column/
Write-Output "LS - Look for files from previous years , re-using the same object"
Write-Output "Sorts on TWO FIELDS (sort by Date ascending, Group by Name [a-z] within Year)"
$resultobj `
| Where-Object perms -ne total `
| Where-Object hourminuteoryear -notlike '*:*' `
|  Sort-Object -property @{e="hourminuteoryear";Descending=$false},@{e="name";Descending=$false} `
|Format-Table

<#
perms       links owner group size      datemonth datemonthday hourminuteoryear name
-----       ----- ----- ----- ----      --------- ------------ ---------------- ----
-rwxrwxrwx  1     dave  dave  20588     Feb       16           1998             rochmail.wav
-rwxr-xr-x  1     dave  dave  123       Jul       9            2011             debsort
-rwxrwxr-x  1     dave  dave  607       Aug       14           2015             grepdvdtitle.sh
-rwxr-xr-x  1     dave  dave  1138      May       16           2016             doubleback-cloud.sh
-rwxr-xr-x  1     dave  dave  149       May       16           2016             tty-doubleback-cloud
-rwxrwxr-x  1     dave  dave  27121269  Jun       2            2017             Edelweiss-Bring_Me_Edelweiss-BuWrg80d…
-rw-rw-r--  1     dave  dave  123494    Jul       7            2018             cyberpower-ups-linux-powerpanel_132_a…
drwxrwxr-x  16    dave  dave  16        Apr       26           2018             macOS-wallpapers-upscaled
-rwxrwxr-x  1     dave  dave  18714256  Oct       30           2018             The_Wallflowers-One_Headlight_Officia…
drwxrwxrwx  551   dave  dave  551       Apr       22           2018             wavs
-rw-r--r--  1     dave  dave  12157596  Jun       24           2019             basic-4-linux--gambas-3.13.0.tar.bz2
-rwxr-xr-x  1     dave  dave  12157596  Jun       24           2019             basic-4-linux-gambas-3.13.0.tar.bz2
-rwxr-xr-x  1     dave  dave  754       Jun       13           2019             bkpsys-2rear.sh
-rwxrwxr-x  1     dave  dave  2923      Aug       31           2019             chkdvdlist-4missing.sh
-rwxrwxr-x  1     dave  dave  1967      Sep       3            2019             grepdvdlistmissing.tgz
-rwxrwxr-x  1     dave  dave  1313153   Jun       9            2019             kvpm-0.9.10.tar.gz
#>

# WORKS - sort array largest first and cast size (string to decimal) OTF
# REF: https://stackoverflow.com/questions/28073525/convert-all-values-in-a-csv-column-to-integer-or-remove-leading-zeroes-in-powe#28073963
Write-Output "LS - Look for files from previous years , re-using the same object"
Write-Output "Sorts on TWO FIELDS (sort by Date (year) ascending, Group by Size  high..low within Year)"
$resultobj `
| Where-Object perms -ne total `
| Where-Object hourminuteoryear -notlike '*:*' `
|  Sort-Object -property @{e="hourminuteoryear";Descending=$false},@{e={[decimal]$_.size};Descending=$true} `
|Format-Table

#Sort-Object -descending {[decimal] $_.size} `
#|  Sort-Object {[decimal]$_.Used} -Descending `

<#
$ar = @(); foreach ($tmp in $resultobj.size) { $tmp2 = [decimal]$tmp; $ar += $tmp2 }

$resultdecimal = @()
for($i=0; $i -lt $resultobj.size.Length; $i=$i+1)
 {$resultdecimal += ([decimal]$resultobj.size[$i])}

PS > $resultdecimal |Sort-Object
519045120
533171860
536072059
727080111
906679642
919955725
#>



<#
parse PS -ef:
  UID   PID  PPID   C STIME   TTY           TIME CMD
    0     1     0   0 12Jan23 ??       126:45.39 /sbin/launchd
    0    42     1   0 12Jan23 ??         4:53.92 /usr/sbin/syslogd
#> 

# with newline
Write-Output "`nPS-EF - Display only certain fields"
(ps -ef) -replace '\s+',',' `
|convertfrom-csv `
| select PID,TIME,CMD `
| Where-Object CMD -like 'bash'

<#
WARNING: One or more headers were not specified. Default names starting with "H" have been used in place of any missing headers.

H1    : 
UID   : 501
PID   : 99809
PPID  : 1
C     : 0
STIME : 9:34AM
TTY   : ??
TIME  : 137:22.72
CMD   : /Applications/Thunderbird.app/Contents/MacOS/thunderbird

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
#>

# NOTE does not handle spaces for things like "Google Chrome"
Write-Output "`nPSEF - check if thunderbird is running"
(ps -ef) -replace '\s+',',' `
|convertfrom-csv `
| select PID,TIME,CMD `
| Where-Object {$_.CMD -Like '*thunderbird'}


Write-Output "`nPSEF - look for running virtualbox"
(ps -ef) -replace '\s+',',' `
|convertfrom-csv `
| select PID,TIME,CMD `
| Where-Object {$_.CMD -Like '*irtual*'}

<#
WARNING: One or more headers were not specified. Default names starting with "H" have been used in place of any missing headers.

PID   TIME      CMD
---   ----      ---
2836  11:06.03  /Applications/VirtualBox.app/Contents/MacOS/VirtualBox
2838  32:10.06  /Applications/VirtualBox.app/Contents/MacOS/VBoxXPCOMIPCD
2840  101:13.55 /Applications/VirtualBox.app/Contents/MacOS/VBoxSVC
2885  553:41.95 /Applications/VirtualBox.app/Contents/Resources/VirtualBoxVM.app/Contents/MacOS/VirtualBoxVM
30766 0:08.96   /Applications/VirtualBox.app/Contents/MacOS/VBoxNetDHCP

#>
} # ifdemo

# NOTE should give perfect comma-sep output:
# ls -l /Volumes/zhgstera6/shrcompr-zhgst6/ \
# |awk '{$1="";$2="";$3="";$4=""; print}' |column -t >ls.txt

# "squeeze" spaces
# tr -s " " < ls.txt |tr ' ' ','

# size, datemo, dateday, dateyr, fname
#2205,Jun,20,2020,zpool-resizeup-mirror-no-degradation-raid10.sh
#703,Aug,23,2020,zpool-upgrade-linux.txt
#71244,Jun,21,2020,zrep.sh
