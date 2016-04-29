`dnsflush`
==========

This is a simple BASH script to flush the DNS on OS X from 10.1 (Cheetah) to 10.11 (El Capitan).

Rational
--------

The steps needed to flush the DNS cache on OS X changes almost every time the OS gets an significant upgrade. I wanted a simple tool that could handle this task and though I typically have the latest or 2nd to latest version I decided to add all versions I could find instructions for just for my own edification. I would be suprised if anyone is still using Cheetah, Puma, Panther, or Tiger for example. But the script should work for all current versions reasonably available. Up to El Capitan. I have locked the script to not attempt a DNS flush of any potentially newer versions of OS X as the next version has at least a 50/50 chance of being different.

Fitness for Use
---------------

I give no garauntees for this scripts fitness for use on any specific system. It is my personal compilation of examples found on the Internet. Based on the sources I got the code from I suspect it is "safe enough" to not mangle any untested systems (I've only used this on my own iMac with El Capitan) do not blame me if you try this and your system suffers for it. I share this code with the world so as to be easy for me to reference personally and in the hope that others will find it useful.
