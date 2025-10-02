#!/bin/env bash

ns=gravity2-lab
pod_prefix="target3-postgres"
pod=$(kubectl -n ${ns} get pods | awk '/^'"${pod_prefix}"'-/{print $1}')
sql_user="postgres"
sql_pass='1qaz@WSX'
sql_db="testdb"

sql_file="Target3Table.sql"

kubectl -n ${ns} exec -it ${pod} -- bash -c "PGPASSWORD='${sql_pass}' psql -U ${sql_user} -d ${sql_db} -f /dev/stdin" < ${sql_file}
