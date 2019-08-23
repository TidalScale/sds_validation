TidalScale Guest Verification
Version 1.0
23 August 2019

CONTENTS
* Quick Summary
* Overview
* Compatibility
* How To Run This Test
* Success Criteria and Caveat
* Best Practice Usage
* How Long Should You Run the Test? 

Quick Summary
-------------
1. Install the tar file with "tar xvf ts-test.tar"
2. "cd ts-test"
3. "sudo root ./runstress" to check that it's installed properly.
4. If it runs and finishes in about a minute then start a full run with
   "sudo root ./runstress 8h"

Overview
--------
This "tar" archive file contains a set of simple tools
to be used to verify that a guest operating system
is healthy after an initial install on a TidalScale
Software Defined Server (SDS).

This is not intended to be an exhaustive test
for every possible guest operating system.
It only performs some basic sanity checking
intended to make sure that the SDS is installed
and configured in a minimally correct mannger.
It does this by placing a workload in the guest
that will force execution state (memory and virtual CPU state)
to be migrated among all the nodes of the SDS.

Compatibility
-------------
This test has been verified to be compatible
with CentOS 6, Oracle Linux 6, and CentOS 7.

The shell script portion of the test
relies on the presence of the "bash" shell.

The compiled code (the "stress-ng" program)
has been compiled as a "statically linked" executable image
so it should not depend on the presence of any shared libraries.
The program is a widely available open source test
found on the Internet.  The version included here
is recompiled to avoid dependencies on other packages
which may not be present in all guest OS installed environments.

This package itself is provided as a "tar file"
to avoid dependency on any particular Linux distribution's
software package management system.
This does require the presence of the "tar",
which is normally available on all UNIX style systems
including all GNU/Linux distributions such as CentOS.

How To Run This Test
--------------------
The test program "stress-ng" can be used
in any manner that is indicated in the documentation
for the program on the Internet.

However for TidalScale verification purposes,
we desire that it be used specifically
in conjunction with the shell scripts included
in this package, and run in the manner described
in these notes.

This package should be installed and run
as indicated in the following:
1. Copy the tar file "ts-test.tar" to the guest environment
   on the Software Defined Server system to be tested.
2. Log into the guest OS on the Software Defined Server to be tested.
3. Extract the tar file in any convenient directory
   with the command 
       # tar xvf ts-test.tar
   This will create a directory "ts-test" in the current
   directory where the command is typed, and place the
   files from the package into that directory.
4. Look in the "ts-test" directory; you should see the following:
       # ls -l
       total 4404
       -rwxr-xr-x. 1 tsadmin tsadmin     231 Aug 20 17:33 runstress
       -rw-r--r--. 1 tsadmin tsadmin    2387 Aug 20 17:35 smoke.bash
       -rwx------. 1 tsadmin tsadmin 4499011 Aug 21 17:48 stress-ng

5. As the user "root", type this command to check
   that the test is installed correctly:
       # ./runstress
   This should run for slightly longer than one minute.
   This only verifies that the package is installed
   and will run on the target system.
6. Run the test for a longer duration by supplying
   an argument to the "runstress" script indicating
   how long it should run.  The duration is
   specified using a number followed by a letter
   to indicate the time unit as "s" for seconds,
   "m" for minutes, or "h" for hours.
   For example
       # ./runstress 8h
   will run the test for 8 hours.

Success Criteria and Caveat
---------------------------
If the SDS doesn't crash or hang, then
the test is considered to be a success.

Caveat: sometimes the test program "stress-ng"
doesn't finish executing; it finishes putting the
stress workload on the system but leaves a bunch of
"defunct" processes around without cleaning them up.
This isn't a bug in the TidalScale software,
but an issue with the test program.
Please ignore this result.

Best Practice
-------------
Since the run time of the test for full verification
will typically be several hours or more,
it is generally advisable to take steps to ensure
that the test will continue to run if your terminal
session disconnects.

One way to do this is using "tmux"
This program is not always present,
and it isn't available
for some versions of Linux.

There is an other older program "screen"
which is similar which may be used instead of "tmux"
if "tmux" is unavailable.

Consult the man pages for "tmux" and "screen"
for detailed explanation of how to use those programs.

If neither is available, "nohup" may be used
to ensure that the program will continue to run
if the terminal session is dropped, and output
will be captured to a file.

How Long Should You Run the Test?
---------------------------------
The aim of this test is to verify that
guest memory pages and virtual processor (VCPU)
state can freely transfer among all the nodes
of the Software Defined Server, and will work fine
on all the nodes.

If the Interconnect network of the SDS
is not configured correctly, the SDS can hang or even crash.

If the test program completes its run
without the SDS crashing, then the test is considered a success.

The correct time duration depends upon
the processor speed, number of guest VCPUs,
number of nodes, and guest memory size.

It's fine if the test runs longer than necessary;
the key is to make sure it runs "long enough".

On a two-node SDS with 1.5TB of RAM in each node,
using about 2.5TB of RAM for the guest,
a test run of 8 hours is normally long enough.
For a smaller SDS, a shorter run time will be adequate;
for a larger SDS, more time may be required.
