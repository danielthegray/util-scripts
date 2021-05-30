#!/usr/bin/env perl
# This script traverses all files recursively and saved, in a file called SIZES
# a list of all the files it encounters as well as the size that the file
# was seen to have.
#
# It is meant as a complement to another utility to check sizes and ensure
# that none of them have changed.

use strict;
use warnings;

use File::Find;
use Data::Dumper;

open(SIZES, ">", "SIZES") or die "Cannot open SIZES file for writing: $!";

sub sizer {
	my $file = $File::Find::name;
	unless (-f $file) {
		return;
	}
	open(FILE, "<", $file) or die "Could not check size of file $file: $!";
	my $file_size = (stat(FILE))[7];
	close(FILE);
	if (defined($file_size)) {
		print SIZES "$file => $file_size\n";
	}
}
find({wanted => \&sizer, no_chdir => 1}, '.');

close(SIZES);
