#!/bin/bash

#Script to pull details for baseline compare
#cat > baseline.sh
#After copying to server set execute permission "chmod 744 ./baseline.sh"

mkdir /var/baseline/ > /dev/null 2>&1

#Serial number, IP, MAC, active logins, uptime
dmidecode -t system | grep 'Serial\|Version' | tee /var/tmp/baselinestatus.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt
ifconfig | grep 'inet addr:\|HWaddr' | tee -a /var/tmp/baselinestatus.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt
w | tee -a /var/tmp/baselinestatus.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt
df -h | tee -a /var/tmp/baselinestatus.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt
echo "20% Complete"

#Accounts, Password exp.
cut -d: -f1 /etc/passwd | tee /var/tmp/baselineaccounts.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt
cut -d: -f1 /etc/passwd | grep 'idirect\|root' | xargs -n1 -I {} bash -c " echo -e '\n{}' ; chage -l {}" | tee /var/tmp/baselinepass.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt
echo "40% Complete"

#Software + versions
rpm -qa | sort -d | tee /var/tmp/baselinesoftware.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt
echo "60% Complete"

#Running Services, Active connections, Ports
service --status-all | sort -d | grep -E --color=auto 'is running|/' | tee /var/tmp/baselineservices.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt
netstat -antpul 2>&1 | tail -n +3 | tee /var/tmp/baselineconnections.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt
echo "80% Complete"

#Startup 
chkconfig --list | grep -E --color=auto ':on|$' | tee /var/tmp/baselinestartup.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt

#Directory structure ***error at /proc.. maybe just target specific dirs for review
#ls -hlaRt --group-directories-first  --color=auto / > /var/tmp/baselinedirectory.txt

#Scheduled Tasks, Syslog
ls -hlRt /etc/cron.* | tee /var/tmp/baselinecron.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt
cat /etc/logrotate.d/syslog | tee /var/tmp/baselinesyslog.txt >> /var/baseline/baseline-$(date +"%Y-%m-%d").txt
echo "100% Complete"
