#!/bin/sh

service postgresql start

# Doing population manually on start, because `bconsole` awaits already populated DB. So it needs to wait on structure to be imported. Doing postgres import is not possible on Docker image build, because service can not be run.

su postgres -c /usr/lib/bareos/scripts/create_bareos_database
su postgres -c /usr/lib/bareos/scripts/make_bareos_tables
su postgres -c /usr/lib/bareos/scripts/grant_bareos_privileges

sed -i 's/^  Name = .*/  Name = '"$HOSTNAME"'-fd/g' /etc/bareos/bareos-fd.d/client/myself.conf
sed -i 's/^  Address = .*/  Address = '"$HOSTNAME"'/g' /etc/bareos/bareos-dir.d/storage/File.conf
sed -i 's/^  Address = .*/  Address = '"$HOSTNAME"'/g' /etc/bareos/bareos-dir.d/client/bareos-fd.conf

service bareos-dir start
# Add director user, access to console and open WebUI
echo 'configure add console name=admin password=secret profile=webui-admin' | bconsole
# Start storage daemon
service bareos-sd start
# Start file daemon (only for self-backup)
service bareos-fd start

apache2ctl restart

while true; do sleep 1000; done
