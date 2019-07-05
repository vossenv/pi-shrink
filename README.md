# Pi Size


*This script will NOT work on windows, nor on the linux subsystem for windows because it doesn't have the necessary kernel pieces.  This can be run on linux via a disposable VM with relative ease as described below for Windows users.  No comparable native windows solutions are known by the author.*

Pi Size is a simple bash script which can help you shrink your raspberry pi images to a reasonable size.  Normally, creating a backup image of a pi's filesystem using tools like Win32DiskImager produces a raw copy.  This raw copy is an exact replicate of the SD card's contents.  Unfortunately, this includes what is normally a substantial amount of empty space.  Consequently, if one makes an image of a 32 GB card, the image itself becomes nearly 32 GB - regardless whether your Pi's files occupy 10% or 100% of that space!  

A major drawback to this is the fact that you can never use your image on a card smaller than 32 GB.  Furthermore, because not all SD cards are manufactered the same -  from time to time, you might find that your 32 GB image won't even fit on a 32 GB card from another manufacturer (or even the same!).  On top of all that, your images occupy a great deal more hard drive space.  A basic headless version of Buster can live on a drive of only  2.4 GB -- do you want to stack up backup images occupying 32 GB a piece when they could be 2.4 GB?

This might not be such a big deal if there was an easy way to shrink the Pi images - but there isn't.  Far from it, in fact - owing to the EXT4 filesystem type it becomes a major challenge for those working on Windows - there are few, if any good ways to handle the process with native Windows applications (I've heard of success with partitioning software like Paragon, but didn't have much myself).  In any case, there is an extra step in the task beyond resizing the filesystem - you must also truncate the raw image file to discard the extra empty space.  Finding a solution to do all of these things is not as easy as it should be.

The absolute best resource I have found on how to do this can be found here (and it is fantastic!):
https://softwarebakery.com//shrinking-images-on-linux

I was  able to succesfully shrink my Pi images using the above guide, but I also found myself wanting for a more streamlined process.  After all, most of us who aren't running on a linux platform don't have the same luxury of just opening up GParted, tweaking a few buttons, and cutting the extra space.  My preference is also to automate solutions wherever possible, and GParted simply isn't conducive to this - even if it were readily available.

This script attempts to automate the steps described in the above link using some alternatives to GParted - namely parted and resize2fs - both commonly found on linux platforms.

If you're on windows, I recommend spinning up a headless ubuntu box from vagrant.  This only takes a few minutes, and you can easily access the Pi image from within after you SSH in.  This is all you need to do to gain access to the linux environment and shrink your image.  Once you have a linux environment up and can access the image file, all you need to do is run the script using your image name as the argument:

`./pi-shrink.sh myimage.img`

**NOTE: You should make a backup of your original image before running, as this script will operate on the image iteself.  Once you are satisfied with the result, you can safely delete the backup copy**

The image should now be shrunk to it's minimum allowable size! It can now be easily written onto any SD card with Win32DiskImager or some other imageing utility.  Just remember to expand the pi filesystem afterwards to get the rest of the SD card's space.


Example output:

```
Device details
------------------------------------------------------------------
Model: Loopback device (loopback)
Disk /dev/loop0: 2898MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size    Type     File system  Flags
 1      4194kB  273MB   268MB   primary  fat32        lba
 2      277MB   2898MB  2621MB  primary  ext4


Partition details
------------------------------------------------------------------
Image file: test.img
Mounted as loop on: /dev/loop0
Partitions: 2
Target partion: /dev/loop0p2
Initial size: 2898.26 MB / 2.89 GB
Target size: 2413.46 MB / 2.41 GB

Shrinking filesystem to minimum size...
resize2fs 1.44.1 (24-Mar-2018)
Resizing the filesystem on /dev/loop0p2 to 475367 (4k) blocks.
The filesystem on /dev/loop0p2 is now 475367 (4k) blocks long.

Shrinking partition to 2413.46 MB...
Warning: Shrinking a partition can cause data loss, are you sure you want to continue?
Information: You may need to update /etc/fstab.

Expanding filesystem to fill partition...
resize2fs 1.44.1 (24-Mar-2018)
Resizing the filesystem on /dev/loop0p2 to 521641 (4k) blocks.
The filesystem on /dev/loop0p2 is now 521641 (4k) blocks long.

Waiting for mount operation to finish...
Truncating raw image file...

Check filesystem...
------------------------------------------------------------------
fsck from util-linux 2.31.1
e2fsck 1.44.1 (24-Mar-2018)
rootfs: clean, 44403/125184 files, 340557/521641 blocks
Unmounting /dev/loop0...
Process complete!
```