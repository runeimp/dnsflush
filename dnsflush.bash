#!/usr/bin/env bash
###################
# DNS Flush
#
# @author RuneImp <runeimp@gmail.com>
# @licenses http://opensource.org/licenses/MIT
# @see http://osxdaily.com/2008/03/21/how-to-flush-your-dns-cache-in-mac-os-x/
# @see http://osxdaily.com/2015/11/16/howto-flush-dns-cache-os-x-elcap/
# @see http://blog.chlaird.com/2015/06/os-x-1011-el-capitan-flush-dns.html
#
#####
# ChangeLog
# ---------
# 2017-07-07  1.1.0      Added support for macOS Sierra
# 2016-??-??  1.0.0      Initial creation
#


#
# CONSTANTS
#
declare -r APP_CLI="dnsflush"
declare -r APP_NAME="DNS Flush"
declare -r APP_VERSION="1.1.0"
declare -r APP_LABEL="$APP_NAME v$APP_VERSION"


declare -r OS_NAME=$(uname -s)
declare -r OS_VERSION=$(uname -r)

declare -r MAJOR_MINOR_PATCH_RE='([0-9]+)\.([0-9]+)\.([0-9]+)(.*)'
declare -r MAJOR_MINOR_PATCH_BUILD_RE='([0-9]+)\.([0-9]+)\.([0-9]+).?([0-9A-z]+).?$'

declare -r UNKNOWN_VERSION_MAC=$(cat <<UNKNOWN_VERSION
  $APP_NAME does not know how to handle flushing the DNS cache of this version
  of OS X. This script is specifically setup to handle each version of OS X as
  Apple changes the mechanism often I do not even want to hazard a guess at how
  this version manages it's DNS cache.
UNKNOWN_VERSION
)


#
# VARIABLES
#
declare -i dns_flushed=1
OS_VERSION_MAJOR=""
OS_VERSION_MINOR=""
OS_VERSION_PATCH=""
OS_VERSION_BUILD=""


#
# FUNCTIONS
#
mac_version()
{
	local tmp=$(type sw_vers 2>&1 /dev/null)
	if [[ $? -eq 0 ]]; then
		tmp="$(sw_vers -productVersion)"
		if [[ $tmp =~ $MAJOR_MINOR_PATCH_RE ]]; then
			
			OS_VERSION_MAJOR="${BASH_REMATCH[1]}"
			OS_VERSION_MINOR="${BASH_REMATCH[2]}"
			OS_VERSION_PATCH="${BASH_REMATCH[3]}"
			OS_VERSION_BUILD="$(sw_vers -buildVersion)"
		fi
	else
		tmp="$(system_profiler SPSoftwareDataType | awk '/System Version/ {print ($3 == "OS") ? $5 $6 : $4 $5;}')"
		if [[ "$tmp" =~ $MAJOR_MINOR_PATCH_BUILD_RE ]]; then
			OS_VERSION_MAJOR="${BASH_REMATCH[1]}"
			OS_VERSION_MINOR="${BASH_REMATCH[2]}"
			OS_VERSION_PATCH="${BASH_REMATCH[3]}"
			OS_VERSION_BUILD="${BASH_REMATCH[4]}"
		fi
	fi

	# echo "\$tmp: $tmp"
	# echo "\$OS_VERSION_MAJOR: $OS_VERSION_MAJOR"
	# echo "\$OS_VERSION_MINOR: $OS_VERSION_MINOR"
	# echo "\$OS_VERSION_PATCH: $OS_VERSION_PATCH"
	# echo "\$OS_VERSION_BUILD: $OS_VERSION_BUILD"
}

case "$OS_NAME" in
	Darwin)
		mac_version
		;;
	*)
		echo "Unknown OS: $OS_NAME"
		exit 1
		;;
esac

case "$OS_NAME" in
	Darwin)
		if [[ $OS_VERSION_MAJOR -eq 10 ]]; then
			case $OS_VERSION_MINOR in
				9 | 1[12])
					# Mavricks, El Capitan, Sierra
					dscacheutil -flushcache
					sudo killall -HUP mDNSResponder
					dns_flushed=0
					;;
				10)
					# Yosemite
					sudo discoveryutil mdnsflushcache
					sudo discoveryutil udnsflushcaches
					dns_flushed=0
					;;
				7 | 8)
					# Lion & Mountain Lion
					sudo killall -HUP mDNSResponder
					dns_flushed=0
					;;
				5 | 6)
					# Leopard & Snow Leopard
					dscacheutil -flushcache
					dns_flushed=0
					;;
				1 | 2 | 3 | 4)
					# Cheetah, Puma, Panther, and Tiger
					lookupd -flushcache
					dns_flushed=0
					;;
				*)
					echo "$UNKNOWN_VERSION_MAC"
					;;
			esac

			if [[ $dns_flushed -eq 0 ]]; then
				# say DNS cache flushed
				echo "DNS cache flushed"
			fi
		fi
		;;
esac
