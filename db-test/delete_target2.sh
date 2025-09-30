#!/bin/env bash

ns=gravity2-lab
pod_prefix="target2-mysql"
pod=$(kubectl -n ${ns} get pods | awk '/^'"${pod_prefix}"'-/{print $1}')
sql_account="mysql"
sql_pass='1qaz@WSX'
sql_db="testdb"
sql_table="target_id13"

for tb in ${sql_table}; do
	echo "TableName: $tb"
	table_name="$tb"
	sql_command="delete from ${tb}"
	kubectl -n ${ns} exec -it ${pod} -- bash -c "mysql --user=${sql_account} --password='${sql_pass}' --database=${sql_db} --execute='${sql_command};' 2>/dev/null"
done
