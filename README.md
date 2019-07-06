root@vagrant:# ./pi-shrink.sh myimage.img                          
                                                                                        
Pi Shrink v1.0.0                                                                        
https://github.com/vossenv/pi-shrink                                                    
Based on: https://softwarebakery.com/shrinking-images-on-linux                          
                                                                                        
Preparing image...                                                                      
------------------------------------------------------------------                      
Making a copy of the original...                                                        
Image will be called shrunk_myimage.img                                                 
 31,914,983,424 100%   47.40MB/s    0:10:42 (xfr#1, to-chk=0/1)                         
Finished clone, sleeping 5s for disk activity to cease...                               
                                                                                        
Device details                                                                          
------------------------------------------------------------------                      
Model: Loopback device (loopback)                                                       
Disk /dev/loop0: 31.9GB                                                                 
Sector size (logical/physical): 512B/512B                                               
Partition Table: msdos                                                                  
Disk Flags:                                                                             
                                                                                        
Number  Start   End     Size    Type     File system  Flags                             
 1      4194kB  273MB   268MB   primary  fat32        lba                               
 2      277MB   31.9GB  31.6GB  primary  ext4                                           
                                                                                        
Partition details                                                                       
------------------------------------------------------------------                      
Image file: shrunk_myimage.img                                                          
Mounted as loop on: /dev/loop0                                                          
Partitions: 2                                                                           
Target partion: /dev/loop0p2                                                            
Initial size: 31914.98 MB / 31.914 GB                                                   
Target size: 2470.14 MB / 2.47 GB                                                       
                                                                                        
Proceed (y/n)[y]?                                                                       
                                                                                        
Begin processsing                                                                       
------------------------------------------------------------------                      
Preparing filesystem...                                                                 
e2fsck 1.44.1 (24-Mar-2018)                                                             
Pass 1: Checking inodes, blocks, and sizes                                              
Pass 2: Checking directory structure                                                    
Pass 3: Checking directory connectivity                                                 
Pass 4: Checking reference counts                                                       
Pass 5: Checking group summary information                                              
rootfs: 44403/1846464 files (0.2% non-contiguous), 449156/7724160 blocks                
                                                                                        
Shrinking filesystem to minimum size...                                                 
resize2fs 1.44.1 (24-Mar-2018)                                                          
Resizing the filesystem on /dev/loop0p2 to 489536 (4k) blocks.                          
The filesystem on /dev/loop0p2 is now 489536 (4k) blocks long.                          
                                                                                        
Shrinking partition to 2470.14 MB...                                                    
Warning: Shrinking a partition can cause data loss, are you sure you want to continue?  
Information: You may need to update /etc/fstab.                                         
                                                                                        
Expanding filesystem to fill partition...                                               
resize2fs 1.44.1 (24-Mar-2018)                                                          
Resizing the filesystem on /dev/loop0p2 to 535478 (4k) blocks.                          
The filesystem on /dev/loop0p2 is now 535478 (4k) blocks long.                          
                                                                                        
Unmounting /dev/loop0...                                                                
Waiting for 5s unmount...                                                               
                                                                                        
Truncating raw image file...                                                            
Final size will be 2.470 GB                                                             
                                                                                        
Finalize...                                                                             
e2fsck 1.44.1 (24-Mar-2018)                                                             
Pass 1: Checking inodes, blocks, and sizes                                              
Pass 2: Checking directory structure                                                    
Pass 3: Checking directory connectivity                                                 
Pass 4: Checking reference counts                                                       
Pass 5: Checking group summary information                                              
rootfs: 44403/133008 files (0.2% non-contiguous), 341048/535478 blocks                  
Unmounting /dev/loop0...                                                                
                                                                                        
Process complete!                                                                       
------------------------------------------------------------------                      
Succesfully shrunk image from 31.914 GB to 2.470 GB!                                    
                                       