AWSL
====

ASWL (short for **A**mazon **W**eb **S**ervice **L**auncher) is a simple bash script that can be used to automate the process of password cracking on an AWS EC2 instance.
It can perform the following steps:

- starting the AWS EC2 instance
- copying the contents of the *sync_me* folder to it
- running specified hashcat commands
- transfering the results to your shared OwnCloud folder
- stopping the AWS EC2 instance

<br/>

Overview
----
The *sync_me* folder will be synced with the AWS instance and contains the following:

**commands.sh**

This file contains all hashcat commands you want to execute on the EC2 instance.
You also have to add the link to your shared OwnCloud folder (make sure it is editable).

**hashes**

Put the hashes you want to crack in this folder.

**masks**

If you want to use masks, you can put the mask file(s) in here.

**policies**

This folder can be used to add custom policies.

**rules**

Add rules to this folder.

**wordlists**

You can use this folder to add custom wordlists.

<br/>

Installation
----
The script installs all missing dependencies automatically.
You can also install them manually as follows:
```
apt-get update
apt-get -y install jq python3-pip rsync
python3 -m pip install awscli
``` 
You also have to configure AWS:
```
aws configure
```

Make sure you use [Kali Linux](https://aws.amazon.com/marketplace/pp/B01M26MMTT?ref_=hmpg_products_os_B01M26MMTT_4) on your AWS EC2 Instance, since it has most needed tools preinstalled.
However, its always better to double check it:
```
sudo apt-get install hashcat hashcat-utils pack princeprocessor python3-setuptools python3-tk lzma
```
Note: Generally only hashcat is needed. All other tools are optional. Their usefulness depends on which cracking methodology you want to use.

<br/>

Usage
----
**Pre-Requirements**
1. Ensure that *ssh_key.pem* of your AWS instance is in the same folder as this script. It is needed to connect to the AWS instance
2. Ensure that the correct *INSTACE_ID*, *REGION* and *USERNAME* are set according to your instance within 'awsl.sh'
3. Add hashes, rules, wordlists, etc. in corresponding 'sync_me' folders
4. Set the *owncloud_share* to your shared OwnCloud folder in 'sync_me/commands.sh'
5. Also specify the hashcat commands you want to execute in this file

**Using the tool**

Simply run the script:

	bash awsl.sh

All cracked and uncracked hashes are sent to your OwnCloud share when the cracking process is complete.

<br/>

Bug Reporting
----
Bug reports are welcome! Please report all bugs on the [issue tracker](https://github.com/mgm-sp/awsl/issues).

<br/>

Links
----

* Download: [.tar.gz](https://github.com/mgm-sp/awsl/tarball/master) or [.zip](https://github.com/mgm-sp/awsl/archive/master.zip)
* Changelog: [Here](https://github.com/mgm-sp/awsl/blob/master/CHANGELOG.md)
* Issue tracker: [Here](https://github.com/mgm-sp/awsl/issues)

<br/>

Authors
---

* Jan Rude (https://github.com/whoot/)

<br/>

# Copyright

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/)