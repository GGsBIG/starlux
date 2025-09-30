#!/bin/env bash

ns=gravity2-lab
pod_prefix="target2-mysql"
pod=$(kubectl -n ${ns} get pods | awk '/^'"${pod_prefix}"'-/{print $1}')
table_name="testdb"

sql_file="Target2Table.sql"
sql_command=$(cat ${sql_file})

kubectl -n ${ns} exec -it ${pod} -- bash -c "mysql --user=mysql --password='1qaz@WSX' --database=testdb --execute='$(cat ${sql_file})'"
