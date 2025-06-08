# TX-PWN
BD-C5500 Bootloader vulnerability POC

The Samsung Blu-Ray player BD-C5500 contains a vulnerability in its bootloader (present in the latest available firmware) that allows arbitrary code execution through the UART interface by issuing a carefully crafted boot command.
This method REQUIRES an ext3 USB, an ethernet cable and UART access

# How it works

The BD-C5500's Linux system executes a script called rcS located in /etc/init.d/ during boot. 
This script interprets several boot parameters that can influence the system's behavior.
Here is an excerpt from the original rcS script:
<pre>
#########################################################################


####vvvv####vvvv#################################################
# BRCM VARIABLES THAT CAN BE SET ON BOOT PARAM LINE
####vvvv####vvvv#########################################vvvv####
#
# BDVD_BOOT_AUTOSTART 
#    This is more of a "mode" than a variable setting. When 
#    set to 'y', it directs this script to go into "production"
#    mode settings.  See the actual code below for what the
#    actual settings are.  Note that this "mode" will not 
#    set any variable that already has a non-null value.
#
# BQ
#    BQ is an acronym for 'Broadcom Quiet'.  When set to 'y'
#    it squelches most of the console output from this script.
#    Note that if you want the Linux kernel to be quiet, you 
#    should specify  'quiet' on the boot line.  
#
# BNET 
#    If this is set to a 'y', the network will be brought up.
#
# BNET_DLY
#    Delays the network bringup by ${BNET_DLY} seconds. If
#    not set, there is no delay.
#
# BAPP  
#    Specifies a program to run at the end of this script.
#    If BAPP is null, no program is started.
#
# BAPP_OUT 
#    Specifies a file to store the Application output, both
#    stdout and stderr.  By default, ${BAPP} output will be 
#    redirected to /tmp/app.out.
#
# OFE_SB
#    If this is not set to 'n', the 7620 Sideband Protocol
#    application "app_ofe_sb" will be started in the
#    background.
#
# Size of /var tmpfs file system, in kbytes.
# BTMPFS_SIZE=384  - original
BTMPFS_SIZE=640
#
# Size allocated for syslogd log, in kbyptes.  Must be a good
# deal less than BTMPFS_SIZE.
BDEVLOG_SIZE=64
####^^^^####^^^^####
</pre>
The vulnerable parameter is BAPP, which is designed to execute a single program after boot. However, this can be abused using eval to execute a chain of commands instead.
By injecting a carefully constructed payload, you can mount a USB device and execute a script from it, effectively enabling arbitrary code execution post-boot.

# How to run it
1. Connect to the UART interface
2. Press Ctrl+C during boot to enter the CFE console.
3. Insert your EXT3-formatted USB drive with stage2.sh inside and connect an Ethernet cable.
4. Set your ethernet interface to a static ip with the following ip: 192.168.1.100 
5. Run the following command:
<pre>boot -elf -z flash0.kernel1: 'root=/dev/romblock17 console=0,115200n8 BDVD_BOOT_AUTOSTART=n BAPP_OUT=/dev/console BAPP="eval sleep 10; mount -o rw /dev/sda1 /var; cd /var; sh ./stage2.sh" memcfg=384 rw'</pre>
6. On your computer in another terminal, run <pre>telnet 192.168.1.108</pre> (The telnet username is root with no password.)

If mounting /dev/sda1 fails, try using /dev/sda instead.

Once you’ve run the exploit once, stage2.sh will be copied to /mtd_down/homebrew on the BD-C5500's filesystem.
For future reboots, you can launch it directly with a simpler and faster command:
<pre>boot -elf -z flash0.kernel1: 'root=/dev/romblock17 console=0,115200n8 BDVD_BOOT_AUTOSTART=n BAPP_OUT=/dev/console BAPP="eval  cd /mtd_down/homebrew; sh ./stage2.sh" memcfg=384 rw'</pre>

To gain telnet while running the main Blu-ray application, append this to the end of either command:
<pre>cd /usr/local/bin/; ./app_player</pre>
Be sure that you added a ; to the command before it

# UART Pinout

The UART interface is located at CN7 on the BD-C5500 board.

* Pin 1 – TX

* Pin 2 – RX

* Pin 14 – GND

Baud rate: 115200 8N1

# Notes
The USB must be EXT3 if you want write access on it. This is especially useful for backing up your NAND with the following command : <pre>for n in `seq 0 21`; do nanddump -f mtd$n.dump /dev/mtd$n; done </pre>

# Credits

Thanks to the following forum thread, without which this Proof-Of-Concept would not have been possible:  
[https://forum.samygo.tv/viewtopic.php?t=1156&sid=b52e08820181a968ddbdb7bedea5964f](https://forum.samygo.tv/viewtopic.php?t=1156&sid=b52e08820181a968ddbdb7bedea5964f)

