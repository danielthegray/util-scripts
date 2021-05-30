#!/usr/bin/env awk
# Look for a property inside a file, if it doesn't exist, add it at the end of a file
BEGIN {
	found = 0;
	key_regex = "^"key"\s*=";
}
{
	if ($0 ~ key_regex) {
		found = 1;
		print key"="value;
	} else {
		print;
	}
}
END {
	if (found == 0) {
		print key"="value;
	}
}
