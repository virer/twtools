#!/bin/sh
##############
# ViReR 2013 #
# TWINEF     #
# TriWire    #
# Ignore     #
# Not        #
# Existing   #
# Files      #
##############
IGNOREFILELIST=/tmp/tw_files2ignored
touch $IGNOREFILELIST
chmod 600 $IGNOREFILELIST

# Get the last report file
REPORTFILE=`ls -1rt /var/lib/tripwire/report/ | tail -1`

# Get the list of files to be ignored
/usr/sbin/twprint -m r -r /var/lib/tripwire/report/$REPORTFILE | grep "File system error" -A 1 | awk '/Filename/ { print $2 }' > $IGNOREFILELIST

# Backup twpol.txt 
[ ! -e /etc/tripwire/twpol.txt.BAK ] && cp /etc/tripwire/twpol.txt /etc/tripwire/twpol.txt.BAK

# Get currently used Pol file
/usr/sbin/twadmin -m p > /etc/tripwire/twpol.txt

# Modify the pol file
for fil2ign in `cat $IGNOREFILELIST` ; do 
        cat /etc/tripwire/twpol.txt | grep -v $fil2ign > /etc/tripwire/twpol.txt.1 
        [ -e /etc/tripwire/twpol.txt.1 ] && rm -f /etc/tripwire/twpol.txt
        mv /etc/tripwire/twpol.txt.1 /etc/tripwire/twpol.txt
done

# Modify hostname in the pol file
sed -i "s/^HOSTNAME=.*$/HOSTNAME=$HOSTNAME;/1" /etc/tripwire/twpol.txt

# Sign new Pol file
/usr/sbin/twadmin --create-polfile /etc/tripwire/twpol.txt

[ -e /var/lib/tripwire/$HOSTNAME.twd.BAK ] && rm -f /var/lib/tripwire/$HOSTNAME.twd.BAK
mv /var/lib/tripwire/$HOSTNAME.twd /var/lib/tripwire/$HOSTNAME.twd.BAK

# Now let's generate a new report
/usr/sbin/tripwire --init

# EOF
