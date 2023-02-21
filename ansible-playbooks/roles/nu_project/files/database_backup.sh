#!/usr/bin/env bash
BACK_UP_FOLDER="back_up_data/$(date +%Y-%m-%d)"
environment="$1" #Take first argurment as docker environment
readonly sources=('classdb' 'imagedb' 'keycloak-db' 'lmsdb' 'tenantdb')

#Move to source path
cd "$(dirname "$0")"

#Create folder
mkdir -p $BACK_UP_FOLDER

for i in "${sources[@]}"; do
    logger "Nu-backup: Start backup data for $i"

    file_name="${i}_"$(date +%Y-%m-%d_%H%M%S)
    logger "Nu-backup: Backup data in $file_name.sql"
    if [[ $i == "keycloak-db" ]];
    then 
        docker exec -t ${environment}$i pg_dumpall -c --insert -U keycloak > $file_name.sql
    else 
        docker exec -t ${environment}$i pg_dumpall -c --insert -U testuser > $file_name.sql
    fi

    logger "Nu-backup: Tar file $file_name.sql"
    tar -czvf $file_name.tar.gz $file_name.sql

    logger "Nu-backup: Move $file_name.tar.gz to folder $BACK_UP_FOLDER"
    mv "$file_name.tar.gz" $BACK_UP_FOLDER

    logger "Nu-backup: Delete $file_name.sql"
    rm $file_name.sql

    logger "Nu-backup: End backup data for $i"
done
