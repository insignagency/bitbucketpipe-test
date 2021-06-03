#!/usr/bin/env bash
pwd
ls
echo "Un echo de test" 
test.sh
mysql -h 127.0.0.1 -u website -pdb_on_docker -e "show tables;"