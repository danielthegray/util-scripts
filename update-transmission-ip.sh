#!/bin/bash
if [[ "$#" -eq 0 ]] ; then
	echo
	echo "Usage: $0 [interface]"
	echo "    where [interface] is the network interface you want Transmission"
	echo "    to listen on (e.g. eth0, wlan0, ens3, tun0)"
	echo
	echo "Intended to be called by a cron job to ensure that the IP address"
	echo "is updated in the Transmission config file if the interface IP"
	echo "address changes. This assumes that you're using the GTK"
	echo "Transmission client."
	echo
	echo "Currently ONLY updates the IPv4 address (it's all I need right now,"
	echo "feel free to to add it and send a pull request!)"
	echo
	echo
	exit 1
fi
interface=$1
actual_ip=`ip addr show $interface | perl -ne 'next if !m/inet /; s/.*inet ([0-9.]+).*/$1/;print'`
ipv4_config_key='bind-address-ipv4'
config_file=`echo ~/.config/transmission/settings.json`
ip_in_config=`awk 'BEGIN{FS="\""}/'$ipv4_config_key'/{print $4}' < $config_file`
if [[ $actual_ip != $ip_in_config ]] ; then
	# Restart transmission UI
	transmission_pid=`ps aux | awk '/transmission-gtk/ && !/awk/{print $2}'`
	kill $transmission_pid
	while [[ -n "$transmission_pid" ]] ; do
		sleep 1
		transmission_pid=`ps aux | awk '/transmission-gtk/ && !/awk/{print $2}'`
	done

	# Replace new IP address in config file
	perl -pi'.old' -e 's/"'$ipv4_config_key'": ".*",/"'$ipv4_config_key'": "'$actual_ip'",/;' $config_file
	# Start transmission again
	transmission-gtk &
fi

transmission_pid=`ps aux | awk '/transmission-gtk/ && !/awk/{print $2}'`
if [[ -z "$transmission_pid" ]] ; then
	transmission-gtk &
fi
