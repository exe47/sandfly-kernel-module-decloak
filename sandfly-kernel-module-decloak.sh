#!/bin/bash
#
# This script will de-cloak certain types of Linux stealth rootkits.
#
# We will check a Linux host to see if a kernel module shows presence 
# in /proc/vmallocinfo in [brackets] but is not being shown in /proc/modules.
# This indicates that a certain type of Loadable Kernel Module (LKM) rootkit
# is potentially active on a host and hiding from command line tools like 
# 'lsmod'.
#
# Works on variants based on Reptile and/or using the khook library to help hide. 
# This includes the rootkit released by Phrack Magazine Issue #72 data dump of a 
# North Korean/China APT actor.
#
# This script is Copyright (c)2025 Sandfly Security and is distributed under the MIT
# license. 
# 
# Sandfly's agentless Linux security solution will find this style of rootkit
# and many more threats more without endpoint agents. See our website for more 
# information:
# 
# https://www.sandflysecurity.com


PROC_VMALLOCINFO="/proc/vmallocinfo"
PROC_MODULES="/proc/modules"
GOT_HIDDEN=0
VERSION=1.0

echo -e "Linux Loadable Kernel Module (LKM) rootkit check $VERSION."
echo "Copyright (c)2025 Sandfly Security - Agentless Linux Security - https://www.sandflysecurity.com"

if [ "$EUID" -ne 0 ]; then
   echo "Error: This script must be run as root."
   exit 1
fi

echo -e "Checking for hidden Linux kernel modules.\n"

# Parses /proc/vmallocinfo for entries in [brackets]. Then checks if that name is in /proc/modules.
# If it is not present in both, then a rootkit is hiding from listing in /proc/modules to evade
# listing with tools like lsmod. This indicates a stealth rootkit may be active on this system.
for module in $(grep -o '\[[^]]*\]' "$PROC_VMALLOCINFO" | tr -d '[]'); do
    if ! grep -q -w "$module" "$PROC_MODULES"; then
        echo -e "\n*** WARNING ***\nKernel module '$module' is active and hiding."
        echo -e "The $PROC_VMALLOCINFO entry showing it is loaded is the following: \n"
        grep $module $PROC_VMALLOCINFO
        GOT_HIDDEN=1
    fi
done

if [ "$GOT_HIDDEN" -ne 0 ]; then
    echo -e "\n*** WARNING: This system has hidden kernel modules and may be operating a rootkit.\n"
    exit 1
else
    echo -e "\nNo hidden kernel modules were found using this variant of rootkit.\n"
    exit 0
fi
