<# Register known ISOs to virtualbox media manager #>
<# 2023.Nov kingneutron #>
<# Adapted from bash code #>
<# dont know why, but the Samba mount dir currently doesnt work #>

$vmname="dummyisofinder"

# xxx TODO EDITME 
$vmdir="D:\virtbox-vms"
$isodir="D:\ISO"
$isodir2="Z:\ISO" # NAS / network mount

$vbm="C:\Program Files\Oracle\VirtualBox\vboxmanage.exe"

& $vbm createvm --name "$vmname" --ostype 'Linux_64' --basefolder "$vmdir" --register
& $vbm modifyvm "$vmname" --description "NOTE this is just a temp VM used to conveniently register ISOs"

& $vbm storagectl "$vmname" --name IDE --add ide --controller piix3 --portcount 2 --bootable on
#VBoxManage storageattach "$vmname" --storagectl IDE --port 0 --device 0 --type dvddrive --medium emptydrive  #"X:\Folder\containing\the.iso"
#VBoxManage showvminfo "$vmname"

cd $isodir

# Define complex array
$result=[System.Collections.ArrayList]@()

$result=get-childitem -Recurse *.iso

cd $isodir2
$result+=get-childitem -Recurse *.iso

Write-Output $result.fullname
# brkpt

foreach ($thisiso in $result.FullName) {
    Write-Output "$thisiso"
    & $vbm storageattach "$vmname" --storagectl IDE --port 0 --device 0 --type dvddrive --medium "$thisiso"
#  VBoxManage modifyvm $vmname --dvd $PWD/${this}
}

# eject
& $vbm storageattach "$vmname" --storagectl IDE --port 0 --device 0 --type dvddrive --medium emptydrive
