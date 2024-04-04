#!/bin/bash

# For various input lines, print the awk column number to reference each field and ===== to indicate next record/line
# Good for docs

# 2024.Apr kneutron

# REQUIRES: GNU Awk

arg=$1
#[ "$arg" = "" ] && let arg=1
# Must pass a numeric arg to see example, otherwise SOURCE thisfile and we define func

case $arg in

  1)
# will run this foreach input record, and each line is substantially different (except last 2)
	gawk ' { for (i = 1; i <= NF; ++i) print i, $i } {print "====="}' awkinput-printcolumns.txt
	exit
	;;

  2)
# print col number, field contents, length of this field
	gawk ' { for (i = 1; i <= NF; ++i) print i, $i, "\t", length($i) } {print "====="}' awkinput-printcolumns.txt \
	 |column -t
	exit
	;;
esac

# Usage: 
# source $0
# pipe-something |awkprintcols

function awkprintcols () {
  gawk '{ for (i = 1; i <= NF; ++i) print i, $i } {print "====="}' /dev/stdin  
}


#exit; # if we leave this in and get sourced, interactive shell exits!

# bash multiline comment
# REF: https://stackoverflow.com/questions/43158140/way-to-create-multiline-comments-in-bash
: <<'END_COMMENT'
REF: https://unix.stackexchange.com/questions/206520/determining-column-number-using-string-in-awk

Example 1:

1 drwxrwxr-x
2 3
3 dave-imac5
4 admin
5 6B
6 Nov
7 28
8 2021
9 0BR-converted
=====
1 another
2 input
3 line
=====
1 Filesystem
2 Type
3 Size
4 Used
5 Avail
6 Use%
7 Mounted-on
=====
1 /dev/disk1s5s1
2 apfs
3 233G
4 226G
5 7.4G
6 97%
7 /


Example 2:
gawk ' { for (i = 1; i <= NF; ++i) print i, $i, "\t", length($i) } {print "====="}' awkinput-printcolumns.txt |column -t

AwkCol Contents-of-fld Length-of-this-field
1      drwxrwxr-x      10
2      3               1
3      dave-imac5      10
4      admin           5
5      6B              2
6      Nov             3
7      28              2
8      2021            4
9      0BR-converted   13
=====                  


Example 3: pipe df to this function (OSX / MacOS)

gdf -hT |head -n 2 |gawk ' { for (i = 1; i <= NF; ++i) print i, $i, "\t", length($i) } {print "====="}' |column -t


Example 4: pipe ls to this function

ls -lh |head -n 2 |gawk ' { for (i = 1; i <= NF; ++i) print i, $i, "\t", length($i) } {print "====="}' |column -t

1      total       5
2      721928      6
=====              
1      drwxr-xr-x  10
2      93          2
3      dave-imac5  10
4      staff       5
5      2.9K        4
6      Mar         3
7      27          2
8      23:23       5
9      0rders      6
=====              


Example 5: skip header line (OSX)

$ . $0 		# SOURCE
$ gdf -hT |tail +2 |head -n 1 |awkprintcols

1 /dev/disk1s5s1
2 apfs
3 233G
4 226G
5 7.4G
6 97%
7 /
=====


$ echo 'this   is  an  arbitrary     line' |awkprintcols
1 this
2 is
3 an
4 arbitrary
5 line
=====


END_COMMENT
