#!/bin/bash
#*******************************************************************************
# Copyright (c) 2016 IBM Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#*******************************************************************************

# redirect stdout and error to our logfile
exec 1<&-
exec 2<&-
if [ $(which yum) ]; then
   exec 1<>/root/startup.`date +"%m%d%y.%H%M"`
else
   exec 1<>/home/core/startup.`date +"%m%d%y.%H%M"`
fi
exec 2>&1


echo ">>> stop and disable coreos update manager"
echo "REBOOT_STRATEGY=off" >> /etc/coreos/update.conf
systemctl stop locksmithd.service
systemctl disable locksmithd.service

echo ">>> if centos basic os prep"
if [ $(which yum) ]; then
   yum upgrade -y
   systemctl stop firewalld
   systemctl disable firewalld

   yum install -y ntp ntpdate ntp-doc
   systemctl start ntpd
   systemctl enable ntpd

   tee /etc/modules-load.d/overlay.conf <<-'EOF'
overlay
EOF

   tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

   #yum install --assumeyes --tolerant docker-engine
   yum install -y docker-engine-1.11.2
   systemctl start docker
   systemctl enable docker

   mkdir -p /etc/systemd/system/docker.service.d
   tee /etc/systemd/system/docker.service.d/override.conf <<-'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon --storage-driver=overlay -H unix:///var/run/docker.sock
EOF
else # coreos
   echo "disabling systemd-resolved"
   systemctl stop systemd-resolved
   systemctl disable systemd-resolved
fi


echo ">>> read input parameters"
source $1


echo ">>> setting up firewall"
cat > /var/lib/iptables/rules-save <<EOF
*filter
:INPUT DROP [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -i eth0 -j ACCEPT
-A INPUT -p tcp --dport 22 -j ACCEPT
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
COMMIT
EOF

if $FIREWALL 
then 
   systemctl start iptables-restore.service
   systemctl enable iptables-restore.service 
fi

echo ">>> if centos then reboot necessary to activate overlayfs"
if [ $(which yum) ]; then
   reboot
fi

