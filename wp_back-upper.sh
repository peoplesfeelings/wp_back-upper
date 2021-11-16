#!/bin/bash

# back up a wordpress site
#   put the script file anywhere
#   run it from anywhere
# 3 required arguments:
#   directory of wordpress site
#   directory for backup files
#   name for backup

INSTR=$'must supply 3 arguments:\n(1) directory of wordpress site\n(2) directory for backup files\n(3) name for backup'

if [ $# -ne 3 ]
  then
    echo "$INSTR"
    exit 1
fi

wp_root=$(readlink -f $1)
backup_dir=$(readlink -f $2)

if [[ ! -d $wp_root ]]
then
    echo "$wp_root is not a directory"
    exit 1
fi
if [[ ! -r $wp_root ]]
then
    echo "$wp_root is not readable"
    exit 1
fi
if [[ ! -d $backup_dir ]]
then
    echo "$backup_dir is not a directory"
    exit 1
fi
if [[ ! -w $backup_dir ]]
then
    echo "$backup_dir is not writable"
    exit 1
fi
if [[ ! $3 =~ ^[A-Za-z0-9_\-]+$ ]]
then
    echo "backup name can only contain letters, numbers, underscore and hyphen"
    exit 1
fi

archive="$backup_dir/$3.zip"
sql_dump="$backup_dir/$3.sql"

if [[ -f $archive ]]
then
    echo "$archive already exists"
    exit 1
fi
if [[ -f $sql_dump ]]
then
    echo "$sql_dump already exists"
    exit 1
fi

echo "back up:"
echo "$wp_root"
echo "to:"
echo "$archive"
echo "$sql_dump"
echo
echo "disk free space:"
df -h
echo
echo "directory size:"
du -sh $wp_root
echo
read -p "CONFIRM? [y/n] " -n 1 -r
echo 
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo 'ok bye!'
    exit 1
fi

config="$wp_root"/"wp-config.php"

if [[ ! -f $config ]]
then
    echo "$config not found"
    exit 1
fi

host=$(grep DB_HOST "$config" |cut -d "'" -f 4)
username=$(grep DB_USER "$config" | cut -d "'" -f 4)
password=$(grep DB_PASSWORD "$config" | cut -d "'" -f 4)
db_name=$(grep DB_NAME "$config" |cut -d "'" -f 4)

mysqldump --no-tablespaces -h "$host" -u "$username" -p"$password" "$db_name" > $sql_dump 2>/dev/null
if [ "$?" -eq 0 ]
then
    echo "mysqldump successful"
else
    echo "mysqldump failed"
    exit 1
fi

cd $wp_root
zip -r $archive . 1>/dev/null
if [ "$?" -eq 0 ]
then
    echo "zip successful"
else
    echo "zip failed"
    exit 1
fi

echo
echo "all done"