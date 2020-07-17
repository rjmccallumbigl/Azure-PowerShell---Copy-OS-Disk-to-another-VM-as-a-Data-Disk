# https://docs.microsoft.com/en-us/azure/virtual-machines/scripts/virtual-machines-windows-powershell-sample-copy-managed-disks-to-same-or-different-subscription#sample-script
# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/attach-disk-ps#attach-an-existing-data-disk-to-a-vm

#Provide the name of your resource group where source VM exists
$sourceResourceGroupName='Name-of-source-vm-resource-group';

#Provide the name of the source VM
$sourceVmName='Name-of-source-vm';

#Provide the name of the Rescue VM we will attach the disk to
$rescueVmName = "Name-of-destination-vm";

#Name of the Rescue VM's Resource Group where snapshot will be copied to
$targetResourceGroupName='Name-of-destination-vm-resource-group';

#Get date
$date = Get-Date -Format "MM-dd-yyyy";

#Get Rescue VM
$rescuevm = Get-AzVM -ResourceGroupName $targetResourceGroupName -Name $rescueVmName;

#Get the source VM's managed disk
$managedDisk= Get-AzDisk -ResourceGroupName $sourceResourceGroupName -Name ($sourceVmName + "_OsDisk_1_*");
$diskConfig = New-AzDiskConfig -SourceResourceId $managedDisk.Id -Location $managedDisk.Location -CreateOption Copy;

#Create a new managed disk in the target subscription and resource group
$copiedDiskName = $sourceVmName + "-DiskCopyFromScript-" + $date;
$diskCopy = New-AzDisk -Disk $diskConfig -DiskName $copiedDiskName -ResourceGroupName $targetResourceGroupName;

#detach current disk at Lun 0
$rescueVMDiskName = $rescuevm.StorageProfile.DataDisks[0].Name;
Remove-AzVMDataDisk -VM $rescuevm -Name $rescueVMDiskName;
Update-AzVM -VM $rescuevm -ResourceGroupName $targetResourceGroupName;

#Attach to Rescue VM
$rescuevm = Add-AzVMDataDisk -CreateOption Attach -Lun 0 -VM $rescuevm -ManagedDiskId $diskCopy.Id;
Update-AzVM -VM $rescuevm -ResourceGroupName $targetResourceGroupName;
