#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "STARTING: import data script from DIR=$DIR"

# create the data pump dir
mkdir -p /opt/oracle/admin/$ORACLE_SID/dpdump/

# unzip the data dump
unzip -n $DIR/crs_artifacts/atg_crs.dmp.zip -d /opt/oracle/admin/$ORACLE_SID/dpdump/

# run the import
impdp system/$ORACLE_PWD@$ORACLE_SID schemas=c##crs_pub,c##crs_core,c##crs_cata,c##crs_catb directory=data_pump_dir dumpfile=atg_crs.dmp logfile=atg_crsdmp.log table_exists_action=replace

echo "DONE: import data script"