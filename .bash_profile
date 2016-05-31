#!/bin/bash
PATH=$PATH:/usr/sbin
unamestr=$(uname)
kernelver=$(uname -mrs)
ntp=$(command -v ntpq)
uptime=$(uptime)

command_exists () {
    type "$1" &> /dev/null ;
}

echo "";
if [[ "$unamestr" == 'SunOS' ]]; then
    memfree=$(top -b | grep Memory | awk '{ print $2}' | cut -c -2)
    memusedmegs=$(top -b | grep Memory | awk '{ print $5}' | sed 's/.$//')
    memused=$((memusedmegs/1024))
    tabs='\t\t'
#    ntpacc=$($ntp -crv | grep -i "rootdispersion" | $theawk -F"=" '{print $2}' | cut -c -2)
    ntpacc=$($ntp -crv | grep -i "rootdispersion" | cut -d"=" -f2 | cut -c -2)
    export LC_ALL="C"
    cpuspeed=$(/usr/bin/kstat -m cpu_info | grep clock_MHz | awk '{ print $2 }' | sort -u)
    lcores=$(/usr/bin/kstat -m cpu_info | egrep "chip_id|core_id|module: cpu_info" |grep 'module: cpu_info' | awk '{ print $4 }' | sort -u | wc -l | tr -d ' ')
    pcores=$(/usr/bin/kstat -m cpu_info | egrep "chip_id|core_id|module: cpu_info" |grep chip_id | awk '{ print $2 }' | sort -u | wc -l | tr -d ' ')
elif [[ "$unamestr" == 'FreeBSD' ]]; then
    memfreemegs=$(grep "real memory" /var/run/dmesg.boot | awk '{ print $5}' | cut -c2-)
    memfree=$((memfreemegs/1024))
    memusedmegs=$(grep "avail memory" /var/run/dmesg.boot | awk '{ print $5}' | cut -c2-)
    memused=$((memusedmegs/1024))
    tabs='\t\t'
#    ntpacc=$($ntp -crv | grep "rootdisp" | $theawk -F"=" '{print $3}' | cut -d . -f 1)
    ntpacc=$($ntp -crv | grep "rootdisp" | cut -d"=" -f3 | cut -d . -f 1)
    cpuspeed=$(sysctl -a | egrep -i 'hw.machine|hw.model|hw.ncpu' | grep GHz | sed 's/.*@//')
    lcores=$(sysctl -a | egrep -i 'hw.machine|hw.model|hw.ncpu' | awk '{if(NR==3){print $2}}')
    pcores=1
elif [[ "$unamestr" == 'Darwin' ]]; then
    tabs='\t\t'
    cpuspeed1=$(sysctl -n hw.cpufrequency)
    cpuspeed=$(bc -l <<< "scale=0;$cpuspeed1 / 1000000")
    cpuspeed="$cpuspeed MHz"
    ntpacc=$(ntpq -p | awk '{if(NR==3){print $9}}')
    lcores=$(sysctl -n hw.physicalcpu)
    pcores=$(sysctl -n hw.logicalcpu)
    echo -e "\033[0;35mOS Version:\t\t\033[1;35m OS X $(sw_vers | grep 'ProductVersion:' | grep -o '[0-9]*\.[0-9]*\.[0-9]*')"
else
    memfree=$(free -g | grep Mem | awk '{ print $2 }')
    memused=$(free -g | grep Mem | awk '{ print $3 }')
    tabs='\t\t'
#    ntpacc=$($ntp -crv | grep "rootdisp" | /usr/bin/$theawk -F"=" '{print $5}'|cut -c -2)

    if command_exists ntpq ; then
        ntpacc=$($ntp -crv | grep "rootdisp" | cut -d"=" -f5 | cut -c -2)
    else
        ntpacc=""
    fi
    cpuspeed=$(grep GHz /proc/cpuinfo | sort -u | sed 's/.*@//')
    lcores=$(grep -c processor /proc/cpuinfo)
    pcores=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
    uptime="$(echo -e "${uptime}" | sed -e 's/^[[:space:]]*//')"
    echo -e "\033[0;35mKernel Information: \t\033[1;35m $kernelver ($(getconf LONG_BIT) bit)";
    if [ -f /etc/os-release ];
    then
        kernelver=$(grep PRETTY_NAME /etc/os-release | sed -r 's/[^\"]*([\"][^\"]*[\"][,]?)[^\"]*/\1 /g' | tr -d '\"')
	else
        kernelver=$(cat /etc/redhat-release)
    fi
fi

echo -e "\033[0;35mOS Version:$tabs\033[1;35m $kernelver"
if command_exists ntpq ; then
    echo -e "\033[0;35mToday is:$tabs\033[1;35m $(date) accurate to within $ntpacc ms";
else
    echo -e "\033[0;35mToday is:$tabs\033[1;35m $(date) which is \033[0;31mNOT ACCURATE - NTP is not running!!";
fi
echo -e "\033[0;35mCPU cores:$tabs\033[1;35m $lcores logical / $pcores physical @ $cpuspeed";
echo -e "\033[0;35mUptime:\t$tabs\033[1;35m $uptime"
echo -e "\033[0;35mMemory:\t$tabs\033[1;35m $memused GB used / $memfree GB total"
#echo -e "\033[0;35mUsers logged in:\t\033[1;35m $(w -h | $theawk '{print $1}'| uniq |$theawk '$1=$1' RS= OFS=', ')"
echo -e "\033[0;35mUsers logged in:\t\033[1;35m $(who | cut -d" " -f1| uniq | awk '{printf $0 ", " ;}' |rev | cut -c 3- | rev)"
echo -ne "\033[0m";

# shellcheck source=/dev/null
. ~/.bashrc
