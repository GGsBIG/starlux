#!/bin/env bash

ns=gravity2-lab
pod_prefix="target-mssql"
pod=$(kubectl -n ${ns} get pods | awk '/^'"${pod_prefix}"'-/{print $1}')
sql_account="SA"
sql_pass='1qaz@WSX'
sql_db="TestDB"
sql_table="${sql_db}.dbo.target_id2"

## show result
sql_command="SELECT * FROM ${sql_table}"
kubectl -n ${ns} exec -it ${pod} -- bash -c "/opt/mssql-tools18/bin/sqlcmd -C -S localhost -U ${sql_account} -P \"${sql_pass}\" -d ${sql_db} -Q \"${sql_command};\""
