#!/bin/env bash

ns=gravity2-lab
pod_prefix="target2-mysql"
pod=$(kubectl -n ${ns} get pods | awk '/^'"${pod_prefix}"'-/{print $1}')

for i in target_id13 target_id2; do
	echo "Deleting from $i"
	table_name="$i"
	kubectl -n ${ns} exec -it ${pod} -- bash -c "mysql --user=mysql --password='1qaz@WSX' --database=testdb --execute='delete from ${table_name}; select count(*) from ${table_name};' 2>/dev/null"
done
