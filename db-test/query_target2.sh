#!/bin/env bash

ns=gravity2-lab
pod_prefix="target2-mysql"
pod=$(kubectl -n ${ns} get pods | awk '/^'"${pod_prefix}"'-/{print $1}')
sql_table="target_id13"

for i in ${sql_table}; do
	echo "TableName: $i"
	table_name="$i"
	kubectl -n ${ns} exec -it ${pod} -- bash -c "mysql --user=mysql --password='1qaz@WSX' --database=testdb --execute='select * from ${table_name}; select count(*) from ${table_name};' 2>/dev/null"
done
