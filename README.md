# BD-C5500-Telnet-Enabler
BD-C5500 Bootloader vulnerability POC

The Samsung Blu-Ray player BD-C5500 contains a vulnerability in its bootloader (present in the latest available firmware) that allows arbitrary code execution through the UART interface by issuing a carefully crafted boot command.
This method REQUIRES a ext3 USB, an ethernet cable and UART access

# How it works

The BD-C5500's Linux system executes a script called rcS located in /etc/init.d/ during boot. 
This script interprets several boot parameters that can influence the system's behavior.
Here is an excerpt from the original rcS script:
<pre> ```
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
``` </pre>
The vulnerable parameter is BAPP, which is designed to execute a single program after boot. However, this can be abused using eval to execute a chain of commands instead.
By injecting a carefully constructed payload, you can mount a USB device and execute a script from it, effectively enabling arbitrary code execution post-boot.
