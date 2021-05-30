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

#my $diff_percentage_threshold = 0.001;
my $diff_percentage_threshold = 0;

my %file_sizes = ();
open(SIZES, "<", "SIZES") or die "Cannot open SIZES file for writing: $!";
while(<SIZES>) {
	my ($file, $size) = /(.*) => (\d+)/;
	$file_sizes{$file} = $size;
}
close(SIZES);

my %found = ();

sub sizer {
	my $file = $File::Find::name;
	unless (-f $file) {
		return;
	}
	#	print "Found file $file\n";
	if ($file =~ /SIZES$/ || $file =~ /node_modules/ || $file =~ /wartest/) {
		#print "$file is an ignored file!\n";
		return;
	}
	unless(defined($file_sizes{$file})) {
		#print "File $file did not exist before!\n";
		return;
	}
	open(FILE, "<", $file) or die "Could not check size of file $file: $!";
	my $file_size = (stat(FILE))[7];
	close(FILE);
	if (!defined($file_size)) {
		#	print "$file does not have a defined file size!\n";
		return;
	}
	if (defined($file_sizes{$file})) {
		$found{$file} = 1;
	}
	if ($file_size != $file_sizes{$file}) {
		my $file_size_difference = $file_sizes{$file} - $file_size;
		my $file_size_diff_percent = $file_size_difference / $file_size * 100;
		if (abs($file_size_diff_percent) > $diff_percentage_threshold) {
			print STDERR "File $file has a different size ($file_size -> $file_sizes{$file} DIFF: $file_size_difference = $file_size_diff_percent %)!\n";
		} elsif ($file_size_difference > 0) {
			print STDERR "File $file has a SMALL DIFFERENCE IN size ($file_size -> $file_sizes{$file} DIFF: $file_size_difference = $file_size_diff_percent %)!\n";
		}
	}
}
find({wanted => \&sizer, no_chdir => 1}, '.');

for my $file (keys %file_sizes) {
	if ($file && !defined($found{$file})) {
		print STDERR "File $file was no longer found! FOUND = ".($found{$file} // "undefined")."\n";
	}
}
