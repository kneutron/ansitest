<# Register known ISOs to virtualbox media manager #>
<# 2023.Nov kingneutron #>
<# Adapted from bash code #>

$vmname="dummyisofinder"

# xxx TODO EDITME 
$vmdir="D:\virtbox-vms"
$isodir="D:\ISO"

$vbm="C:\Program Files\Oracle\VirtualBox\vboxmanage.exe"

& $vbm createvm --name "$vmname" --ostype 'Linux_64' --basefolder "$vmdir" --register
& $vbm modifyvm "$vmname" --description "NOTE this is just a temp VM used to conveniently register ISOs"

& $vbm storagectl "$vmname" --name IDE --add ide --controller piix3 --portcount 2 --bootable on
#VBoxManage storageattach "$vmname" --storagectl IDE --port 0 --device 0 --type dvddrive --medium emptydrive  #"X:\Folder\containing\the.iso"
#VBoxManage showvminfo "$vmname"

cd $isodir
$result=get-childitem -Recurse *.iso

foreach ($thisiso in $result.FullName) {
    Write-Output $thisiso
    & $vbm storageattach "$vmname" --storagectl IDE --port 0 --device 0 --type dvddrive --medium $thisiso
#  VBoxManage modifyvm $vmname --dvd $PWD/${this}
}

# eject
& $vbm storageattach "$vmname" --storagectl IDE --port 0 --device 0 --type dvddrive --medium emptydrive
