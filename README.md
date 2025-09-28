# sandfly-kernel-module-decloak

# Introduction

Phrack magazine released a data dump of a threat actor purportedly from North 
Korea. 

The data dump contained large amounts of operational data on their activity, 
along with a Linux Loadable Kernel Module (LKM) rootkit with stealth 
capabilties and extensive backdoor capabilities. 

You can read more about this data leak here:

https://phrack.org/issues/72/7_md#article

This script uses a technique to decloak this style of rookit by showing the 
hidden kernel module name if found operating. It will not only decloak this 
rootkit, but variants using this rootkit framework and method of hiding such 
as Reptile and likely others.

# How To Use

Copy the script onto a host you want to investigate and run it. Any modules 
being hidden with this method will be shown. 

Example:

```
root@sandlfysecurity-victim:~# ./sandfly-kernel-module-decloak.sh 
Linux Loadable Kernel Module (LKM) rootkit check 1.0.
Copyright (c)2025 Sandfly Security - Agentless Linux Security - https://www.sandflysecurity.com
Checking for hidden Linux kernel modules.


*** WARNING ***
Kernel module 'vmwfxs' is active and hiding.
The /proc/vmallocinfo entry showing it is loaded is the following: 

0xffffffffc07e2000-0xffffffffc07e4000    8192 khook_init+0x8d/0x140 [vmwfxs] pages=1 vmalloc N0=1

*** WARNING: This system has hidden kernel modules and may be operating a rootkit.

root@sandlfysecurity-victim:~# 

```

# Limitations

LKM rootkits can use different methods to hide. This detection method will find 
rootkit frameworks that hide from `/proc/modules` but leaves traces in 
`/proc/vmallocinfo`. Not all rootkits may do this. As a result, other rootkits 
could evade detection even if a system shows clean with this script. 

# Other Tips

If you see a detection with this script, you may want to run the `dmesg` command 
to see if you can find what tainted the kernel. This can corroborate the malicious 
module. The command to run is:

```
dmesg | grep taint
```

For example we see the malicious module `vmwfxs` detected above and `dmesg` below 
shows it responsible for the kernel taint with an unsigned module. This confirms 
that a rootkit is very likely active on this host. 

```
root@sandlfysecurity-victim:~# dmesg | grep taint
[   24.065426] vmwfxs: module verification failed: signature and/or required key missing - tainting kernel
root@sandlfysecurity-victim:~# 
```

WARNING: The `dmesg` command reads a ring buffer and may not show all entries 
as they may roll out. This means that `dmesg` can confirm a module loaded and 
tainted the kernel, but not finding anything does not mean it's not present. 
It may simply mean the original taint entry left the buffer as new messages 
entered. The main confirmation is if the module is listed in `/proc/vmallocinfo` 
(in [brackets]) then it is active on the host.


# Automate Rootkit Hunting

While this script is good for manual rootkit confirmation for this particular 
type of LKM rootkit, it is best to automate hunting for these types of threats 
and deploying multiple techniques to find variants. Sandfly Security offers an 
agentless Linux Security platform which can find this and other styles of Linux 
LKM rootkits without endpoint agents.

Please see our website for more information and read our blog for other Linux 
malware detection articles:

https://www.sandflysecurity.com


# Links

Phrack article on data dump:

https://phrack.org/issues/72/7_md#article

Sandfly Security rootkit analysis:

https://sandflysecurity.com/blog/leaked-north-korean-linux-stealth-rootkit-analysis
