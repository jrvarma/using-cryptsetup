#!/bin/bash
## This is best executed block by block in a terminal
## It is best not to make this file executable

## This editable block sets the loop device numbers.
## Change these loop device numbers if they are already in use
## Loop device to associate with cryptsetup (luks) mapping 
## this is needed both for partitions and for volumes
loop6=/dev/loop6 
## Loop device used to mount volume file before cryptsetup
## This is needed only for luks volumes. Not needed for partitions
loop5=/dev/loop5 

## This editable block sets the values of 
## where, label and owner appropriately
## $where is the mount location
where=/path/to/mount/location
## $label is the label for the filesystem that will be created
label=mylabel
## $username is the user to whom $where will be chowned
owner=username
## targetname is name of the cryptmount target
target=targetname

############# This editable block is only for luks partition
## set the value of device (partition) appropriately
## $device is the partition to be encrypted
device=/dev/sda7
cryptdev=$device # for cmtab entry, do not edit this
################  end of luks partition editable block

################ This editable block is only for luks volume
## set the values of label and nGB appropriately
## $volume is the file for the luks volume
volume=/path/to/volumefile
## nGB is the volume size in GB
nGB=100 
################  end of luks volume editable block

##
######## End of editable blocks. Remaining code can be run as is
##

################ This code block is only for luks volume
# create the luks volume filling it with zeroes
nMB=$((nGB*1024))
dd if=/dev/zero of=$volume bs=1M count=0 seek=$nMB
# create losetup device
device=$loop5
sudo losetup $device $volume
cryptdev=$volume # for cmtab entry
################  end of special code block for luks volume 

## At this point, $device is either the luks partition or the losetup
## device set up for the luks volume. In either case, we can run
## cryptsetup on this device.

## initialize and set passphrase
sudo cryptsetup luksFormat $device

## Opens luks device (prompting for password) and set up mapping
sudo cryptsetup luksOpen $device myMapper

## setup loop device for the mapping created by cryptsetup
sudo losetup $loop6 /dev/mapper/myMapper 

## create file system (mkfs.ext4, mkfs.ext3 or mkntfs)
sudo mkfs.ext4 $loop6
## create label (e2label or ntfslabel)
sudo e2label  $loop6 $label

## create mount location, mount file system, set permissions
sudo mkdir -p $where
sudo mount $loop6 $where
sudo chown $owner:$owner $where
sudo umount $where

## detach luks mapping from loop device
sudo losetup -d $loop6

## remove the luks mapping and wipe key from kernel memory
sudo cryptsetup luksClose myMapper

########## This code block is only for luks volume
## detach luks volume from loop device
sudo losetup -d $device
########## End of special code block for luks volume

########## Create entry in cmtab for cryptmount 
## cryptdev is the partition if we are encrypting the partition. It is
## the volume file if we are creating an encrypted volume
(cat  << INPUT
$target {
keyformat=luks
dev=$cryptdev
dir=$where
}
INPUT
) | sudo tee -a /etc/cryptmount/cmtab

####### Test mounting using cryptmount (via cmtab entry)
## Note no sudo here
cryptmount target

####### Test unmounting using cryptmount (via cmtab entry)
## Note no sudo here
cryptmount -u target
