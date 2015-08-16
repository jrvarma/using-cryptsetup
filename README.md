# using-cryptsetup
Semi automated script for setting up LUKS volumes and cmtab entries

The Linux packages `cryptmount` and `cryptsetup` allow normal users to mount and unmount encrypted file systems. To set up the encryption for the first time, one has to log in as `root` (or use `sudo`), but after that only normal user privileges are required to use the system. 

There are many tutorial on the web about `cryptmount` and `cryptsetup`, but if one creates encrypted volumes frequently (for example, on different USB sticks), it is very painful to type in a whole sequence of dangerous commands ensuring that one is using the correct arguments.

This script provides a semi-automated solution to this problem. By semi-automated, I mean:

* Setting up encrypted volumes involves running some very powerful commands as `root` (or `sudo`) and I do not recommend making it an executable file. Rather, the commands should be executed line by line or at least block by block in a terminal, paying careful attention to all the warning messages.

* All the parameters that need to be changed by the user are set up in the initial portion of the script through shell variables. These include: the partition or the volume file name, volume size, user name, volume labels, mount point etc. These need to be edited to the appropriate values before use, but the rest of the code containing the actual sudo commands do not need to be edited. This reduces the scope of errors.

`Cryptsetup` allows us to create encrypted file systems in two ways. Either, we can select a partition on the hard disk and encrypt the whole partition, or we can use a file on any partition as the container for the encrypted file system. The code supports both methods.

The commands in this script needs to be run only once with `sudo`. Thereafter the encrypted volume can be mounted as a normal user by using the command: `cryptmount targetname` and providing the passphrase for the volume. The same normal user can unmount the volume by issuing the command `cryptmount -u targetname`. The commands in this script create the appropriate entries in `cmtab` to facilitate this.
