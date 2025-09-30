#!/bin/env bash
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
ns=gravity2-lab
pod_prefix="target2-mysql"
pod=$(kubectl -n ${ns} get pods | awk '/^'"${pod_prefix}"'-/{print $1}')

for i in demo00_id13 demo00_id2; do
	echo "TableName: $i"
	table_name="$i"
	#kubectl -n ${ns} exec -it ${pod} -- bash -c "mysql --user=mysql --password='1qaz@WSX' --database=testdb --execute='show columns from ${table_name}; select * from ${table_name}; select count(*) from ${table_name};' 2>/dev/null"
	kubectl -n ${ns} exec -it ${pod} -- bash -c "mysql --user=mysql --password='1qaz@WSX' --database=testdb --execute='select count(*) from ${table_name};' 2>/dev/null"
done
