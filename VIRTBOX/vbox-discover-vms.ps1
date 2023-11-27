<# Discover virtualbox vms in dir and add them to gui #>
<# 2023.Nov kingneutron #>
<# Adapted from bash code #>

# TODO EDITME for where your VMs live
D:
cd virtbox-vms

$vbm="C:\Program Files\Oracle\VirtualBox\vboxmanage.exe"
$result=get-childitem -Recurse *.vbox 

# $result.fullname
# D:\virtbox-vms\almalinux-test-centos-replacement-rhel8\almalinux-test-centos-replacement-rhel8.vbox

foreach ($thisvm in $result.fullname) {
  Write-Output $thisvm
  & $vbm registervm $thisvm

}

& $vbm list vms
get-date
Write-Output "Recommended to run vbox-registerISOs now"

<# 
$result
    Directory: D:\virtbox-vms\XPvm

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---            4/6/2023  2:39 PM          11447 XPvm.vbox
#>