`gpart show #get the available partitions`  
#after executing show command you gonna get this info  
#disk = da0  
#freebsd-usf = get id (~3)  
#freebsd-swap = get id (~4)  
`gpart recover da0`   
#recover the new space added  
`gpart show`  
#check the new free space is added  
#let's remove swap from current location  
`swapoff -a`  
#disable swap on freebsd  
`gpart delete -i 4 da0`   
#freebsd-swap id = 4  
`gpart show`  
#get free space sector start and size in notepad  
#lets move swap to the end of disk (download the calculator down to help and use sector start & free size in calculator)  
`gpart add -t freebsd-swap -b <Swap Start (Sector)> da0`  
#get the swap start from calculator and replace in the placeholder.  
`gpart show`  
#confirm the swap place and size is correct (if something wrong, delete it and recalculate and repeat the previous step)  
`gpart modify -i 4 -l swapfs da0`  
#assign label for the new partition for opnsense booting  
`swapon /dev/gpt/swapfs`  
#start the swapping on the system  
#we moved now the swap to the end of disk, let's increase root partition size  
`gpart resize -i 3 da0`  
#freebsd-usf id = 3  
`gpart show`  
#check the resize is done  
`growfs /dev/gpt/rootfs`  
#scanning the new space added to the partition mount.  
`exit`   
#exit shell  

reference : https://roofman.me/2021/01/26/opnsense-resize-disk-space/

For 42GB  
  
\# gpart show  
=>      40  88080304  da0  GPT  (42G)  
        40    532480    1  efi  (260M)  
    532520      1024    2  freebsd-boot  (512K)  
    533544  49798144    3  freebsd-ufs  (24G)  
  50331688  16777136    4  freebsd-swap  (8.0G)  
  67108824  20971520       - free -  (10G)    
  
gpart add -t freebsd-swap -b 71303168 da0  

\# gpart show  
=>      40  88080304  da0  GPT  (42G)  
        40    532480    1  efi  (260M)  
    532520      1024    2  freebsd-boot  (512K)  
    533544  49798144    3  freebsd-ufs  (24G)  
  50331688  20971480       - free -  (10G)  
  71303168  16777176    4  freebsd-swap  (8.0G)  

