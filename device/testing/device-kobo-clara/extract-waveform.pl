#!/usr/bin/env perl
# SPDX-License-Identifier: GPL-2.0+
# (c) 2020, Andreas Kemnade

sub usage {
	print "Usage: $0 disk epdc.fw\ndisk is the Kobo/Toline disk (image) containing a waveform\n";
	exit(1);
}

&usage unless $#ARGV == 1;

open IMGFILE, '<:raw', @ARGV[0] or die "cannot open @ARGV[0]";
seek IMGFILE, 0x700000-16, 0;
read IMGFILE, $magic, 8;
(unpack("x0 H16", $magic) eq "fff5afff78563412") or die "invalid magic";

seek IMGFILE, 0x700000-8, 0;
read IMGFILE, $lengthbytes, 4;
$length = unpack("x0 V", $lengthbytes) or die "invalid length";
print $length . " bytes\n" ;
seek IMGFILE, 0x700000, 0 or die "seek failed, file too short?";
open OUTFILE, '>:raw', @ARGV[1] or die "cannot open @ARGV[1]";
read IMGFILE, $waveform, $length;
print OUTFILE $waveform;
