#!/usr/bin/python
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

import os,sys
import subprocess
import time


def get_master_rc(pkey, bootstrap_user, bootstrap_publicip, master_privateip):

    currenv = os.environ.copy()

    a = ['ssh', '-i', pkey, '-o', 'StrictHostKeyChecking=no', '-o', 'UserKnownHostsFile=/dev/null' ,bootstrap_user+'@'+bootstrap_publicip, 'curl', '-ksw', '\'%{http_code}\'', 'https://'+master_privateip, '-o', '/dev/null', '--connect-timeout', '5']

    ssh = subprocess.Popen(a, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=currenv)
    result = ssh.stdout.readlines()
    if (result == []) or (int(result[0]) == 0):
       error = ssh.stderr.readlines()
       raise Exception(error)

    return int(result[0])


if not len(sys.argv) == 5:
    usagestring = "usage: {} <pkey> <bootstrap_user> <bootstrap_publicip> <master_privateip>"
    print usagestring.format(sys.argv[0])
    sys.exit(1)

while True:
    try:
       rc = get_master_rc(sys.argv[1], 'core' if 'coreos' in sys.argv[2].lower() else 'root', sys.argv[3], sys.argv[4])
       if (rc == 401) or (rc == 200):
          print rc
          break
       print "{}, master not up yet".format(r.status_code)
    except:
       print "please wait, masters not up yet"
    time.sleep(1)
