#!/bin/bash

# 2025.Nov kneutron

# REF: https://search.brave.com/search?q=linux+nvme-device-self-test&source=web&summary=1&conversation=9fcd90b46cc9aafb22b60d

[ $(dpkg -l |grep -c nvme-cli) -gt 0 ] || apt install -y nvme-cli

devtest=nvme1
[ "$1" = "" ] || devtest="$1"

outf=~/smartlog-nvme-$devtest.log

ls -lR /dev/disk |grep "$devtest" >"$outf"
smartctl -A /dev/"$devtest" >>"$outf"

echo "$(date) - BEGIN nvme long test $devtest"
# long test, wait until done on 1TB tbolt4 sabrent rocket
time nvme device-self-test /dev/$devtest -n 1 -v -w -s 2 -o normal

nvme self-test-log /dev/$devtest |tee -a "$outf"
smartctl -a /dev/$devtest >>"$outf"

ls -lh "$outf"

exit;


Extended Device self-test started
Waiting for self test completion...
[==================================================] 100%

real    9m54.393s
Device Self Test Log for NVME device:nvme1
Current operation  : 0
Current Completion : 0%
Self Test Result[0]:
  Operation Result             : 0
  Self Test Code               : 2
  Valid Diagnostic Information : 0
  Power on hours (POH)         : 0
  Vendor Specific              : 0 0


The primary action of the command is controlled by the --self-test-code or -s option, which specifies the type of test to run:

1h starts a short device self-test operation.

2h starts an extended device self-test operation.

eh initiates a vendor-specific device self-test operation.

fh aborts an ongoing device self-test operation.

0h (default) displays the current state of the device self-test operation.


Additional options include:

--namespace-id or -n to specify the namespace for the test.

--wait or -w to wait for the test to complete before exiting; this is ignored if the abort code (fh) is used.

--output-format or -o to set the output format to normal, JSON, or binary.

--verbose or -v to increase the detail of the output.

--timeout or -t to override the default timeout value in milliseconds.


For example, to start a short self-test on namespace ID 1, use:

nvme device-self-test /dev/nvme0 -n 1 -s 1
 

To abort a self-test on namespace ID 1, use:

nvme device-self-test /dev/nvme0 -n 1 -s 0xf

The results of the self-test can be retrieved using the `nvme self-test-log` command, which displays the most recent 20 log entries by default.
