# util-scripts
A collection of scripts I use for hacky tasks, published here in the hope that you may find them useful as well! (maybe, maybe not)

## `update-transmission-ip`
Usage: `update-transmission-ip [interface]`

where _[interface]_ is the network interface you want Transmission
to listen on (e.g. eth0, wlan0, ens3, tun0.) Calling with no parameters
prints a small help screen.

Intended to be called by a cron job to ensure that the IP address
is updated in the Transmission config file if the interface IP
address changes (every minute, or 5 minutes, as you prefer).
This assumes that you're using the GTK Transmission client.

Currently ONLY updates the IPv4 address (it's all I need right now,
feel free to to add it and send a pull request!)
