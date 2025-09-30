#!/bin/env bash

sql_file="DropTable.sql"
ns=gravity2-lab
pod_prefix="target-mssql"
pod=$(kubectl -n ${ns} get pods | awk '/^'"${pod_prefix}"'-/{print $1}')
sql_account="SA"
sql_pass='1qaz@WSX'
sql_db="TestDB"

## run sql command
sql_command="$(cat ${sql_file})"
kubectl -n ${ns} exec -it ${pod} -- bash -c "/opt/mssql-tools18/bin/sqlcmd -C -S localhost -U ${sql_account} -P \"${sql_pass}\" -Q \"${sql_command};\""
