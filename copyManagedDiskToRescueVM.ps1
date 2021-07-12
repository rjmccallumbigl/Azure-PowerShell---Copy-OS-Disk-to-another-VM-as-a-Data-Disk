# https://docs.microsoft.com/en-us/azure/virtual-machines/scripts/virtual-machines-windows-powershell-sample-copy-managed-disks-to-same-or-different-subscription#sample-script
# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/attach-disk-ps#attach-an-existing-data-disk-to-a-vm

#Provide the name of your resource group where source VM exists
$sourceResourceGroupName = 'Name-of-source-vm-resource-group'

#Provide the name of the source VM
$sourceVmName = 'Name-of-source-vm'

#Provide the name of the Rescue VM we will attach the disk to
$rescueVmName = "Name-of-destination-vm"

#Name of the Rescue VM's Resource Group where snapshot will be copied to
$targetResourceGroupName = 'Name-of-destination-vm-resource-group'

#Get date
$date = Get-Date -Format "MM-dd-yyyy"

#Get VMs
$sourceVm = Get-AzVM -ResourceGroupName $sourceResourceGroupName -Name $sourceVmName 
$rescuevm = Get-AzVM -ResourceGroupName $targetResourceGroupName -Name $rescueVmName

#Get the source VM's managed OS disk
$managedDisk = Get-AzDisk -ResourceGroupName $sourceResourceGroupName -Name $sourceVm.StorageProfile.OsDisk.Name
$diskConfig = New-AzDiskConfig -SourceResourceId $managedDisk.Id -Location $managedDisk.Location -CreateOption Copy

#Create a new managed disk in the target resource group (is a copy)
$copiedDiskName = $sourceVmName + "-DiskCopyFromScript-" + $date
$diskCopy = New-AzDisk -Disk $diskConfig -DiskName $copiedDiskName -ResourceGroupName $targetResourceGroupName

#Attach to Rescue VM at next available LUN
$rescuevm = Add-AzVMDataDisk -CreateOption Attach -Lun ($rescuevm.StorageProfile.DataDisks).Count -VM $rescuevm -ManagedDiskId $diskCopy.Id
Update-AzVM -VM $rescuevm -ResourceGroupName $targetResourceGroupName
