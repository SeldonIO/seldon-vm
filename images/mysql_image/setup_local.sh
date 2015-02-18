#! /bin/bash
#mysqld --user=root stop
rm -rf /usr/local/mysql/data
ln -s /mysql_data /usr/local/mysql/data
mysql_install_db
/entrypoint.sh 'mysqld' '--user=root'
