#!/bin/bash

## PUT YOUR OWNCLOAD SHARED LINK HERE
owncloud_share=""


## PUT YOUR HASHCAT COMMANDS HERE
## Use 'timeout --foreground <DURATION>' to restrict the execution time!
## Examples
 # Crack ?a from 1 to 7 characters
 # timeout --foreground 8m hashcat -a 3 -m 0 hashes/hashes.txt ?a?a?a?a?a?a?a --remove -o hashes/cracked.txt -O -i --force 

 # Use wordlist with rules
 # hashcat -a 0 -m <type> hashes/hashes.txt wordlists/*.txt -r rules/custom.rule --remove -o hashes/cracked.txt -O --force


















## DO NOT ALTER ANYTHING BELOW THIS LINE
#========================================

## send results to OwnCloud
CLOUDURL=$(echo $owncloud_share | awk -F'index.php' '{print $1}')
FOLDERTOKEN=$(echo $owncloud_share | awk -F'/s/' '{print $2}')
echo -e "\n\nSending remaining and cracked hashes to OwnCloud..."
tar -czf hashes.tar.gz hashes
curl -k -T hashes.tar.gz -u "$FOLDERTOKEN:" -H 'X-Requested-With: XMLHttpRequest' "$CLOUDURL/public.php/webdav/$(date '+%d-%b-%Y')-hashes.tar.gz"

## stopping instance
sudo poweroff
