#!/usr/bin/env bash
###################
# DNS Flush
#
# @author RuneImp <runeimp@gmail.com>
# @licenses http://opensource.org/licenses/MIT
#
# @see http://osxdaily.com/2017/12/18/reset-dns-cache-macos-high-sierra/
# @see http://osxdaily.com/2017/03/08/clear-dns-cache-macos-sierra/
# @see http://osxdaily.com/2015/11/16/howto-flush-dns-cache-os-x-elcap/
# @see http://blog.chlaird.com/2015/06/os-x-1011-el-capitan-flush-dns.html
# @see http://osxdaily.com/2008/03/21/how-to-flush-your-dns-cache-in-mac-os-x/
#
#####
# ChangeLog
# ---------
# 2018-04-14  1.2.0      Added support for macOS High Sierra and updated for Sierra
# 2017-07-07  1.1.0      Added support for macOS Sierra
# 2016-??-??  1.0.0      Initial creation
#


#
# CONSTANTS
#
declare -r APP_CLI="dnsflush"
declare -r APP_NAME="DNS Flush"
declare -r APP_VERSION="1.2.1"
declare -r APP_LABEL="$APP_NAME v$APP_VERSION"

declare -a OS_LIST_10
OS_LIST_10[0]='Cheetah'        # 10.0
OS_LIST_10[1]='Puma'           # 10.1
OS_LIST_10[2]='Jaguar'         # 10.2
OS_LIST_10[3]='Panther'        # 10.3
OS_LIST_10[4]='Tiger'          # 10.4
OS_LIST_10[5]='Leopard'        # 10.5
OS_LIST_10[6]='Snow Leopard'   # 10.6
OS_LIST_10[7]='Lion'           # 10.7
OS_LIST_10[8]='Mountain Lion'  # 10.8
OS_LIST_10[9]='Mavricks'       # 10.9
OS_LIST_10[10]='Yosemite'      # 10.10
OS_LIST_10[11]='El Capitan'    # 10.11
OS_LIST_10[12]='Sierra'        # 10.12
OS_LIST_10[13]='High Sierra'   # 10.13
OS_LIST_10[14]='Mojave'        # 10.14
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
				12)
					# Sierra
					if [[ $OS_VERSION_PATCH -lt 3 ]]; then
						sudo killall -HUP mDNSResponder
					else
						sudo killall -HUP mDNSResponder
						sudo killall mDNSResponderHelper
						sudo dscacheutil -flushcache
					fi
					dns_flushed=0
					;;
				9 | 11)
					# Mavricks, El Capitan
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
				7 | 8 | 13 | 14)
					# Lion, Mountain Lion, High Sierra, Mojave
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
				echo "DNS cache flushed for ${OS_LIST_10[$OS_VERSION_MINOR]}"
			fi
		fi
		;;
esac
