#!/bin/sh -x
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

# coreos nohup workaround
grep CoreOS /etc/os-release 2>&1 >>/dev/null
if [ $? -eq 0 ]; then
   if [ ! -f /tmp/firstrun ]; then
      touch /tmp/firstrun
      systemd-run $0
      exit
   fi
   
   cd /home/core/
fi

mount /dev/xvdh1 /mnt
userdatafile=/mnt/openstack/latest/user_data
sed -n '/SCRIPTSTARTSCRIPTSTARTSCRIPTSTART/q;p' $userdatafile > userdata
sed '1,/SCRIPTSTARTSCRIPTSTARTSCRIPTSTART/d' $userdatafile > scriptfile
if [ -s scriptfile ]
then
  chmod +x scriptfile
  script_to_run="./scriptfile"
else
  rm scriptfile
  script_to_run="coreos-cloudinit --from-file"
fi
umount /mnt
$script_to_run userdata 
echo rc=$?
echo all done
