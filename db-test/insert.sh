#!/bin/env bash

ns=gravity2-lab
pod_prefix="source-mssql"
pod=$(kubectl -n ${ns} get pods | awk '/^'"${pod_prefix}"'-/{print $1}')
sql_account="SA"
sql_pass='1qaz@WSX'
sql_db="TestDB"
sql_table="${sql_db}.dbo.mi_source"

source_file="${0%/*}/source_1.txt"
while read line; do
  n=0
  while read field; do
	src[$n]="$field"
	((n++))
  done< <(echo "$line" | tr ',' '\n')

  bdl_id="'${src[0]}'"
  bdl_pat_no="${src[1]}"
  bdl_ipd_no="'${src[2]}'"
  bdl_in_dtti="'${src[3]}'"
  bdl_in_dtti_v="'${src[4]}'"
  if [ -z "${src[5]// /}" ]; then bdl_chg_bed="NULL"; else bdl_chg_bed="'${src[5]}'"; fi
  bdl_group="'${src[6]}'"

  if [ -z "${values}" ]; then
	values="(${bdl_id},${bdl_pat_no},${bdl_ipd_no},${bdl_in_dtti},${bdl_in_dtti_v},${bdl_chg_bed},${bdl_group})"
  else
	values="${values},(${bdl_id},${bdl_pat_no},${bdl_ipd_no},${bdl_in_dtti},${bdl_in_dtti_v},${bdl_chg_bed},${bdl_group})"
  fi
done< <(cat "$source_file")

#echo "${values}"

## run sql command
sql_command="INSERT INTO ${sql_table} values${values}"
kubectl -n ${ns} exec -it ${pod} -- bash -c "/opt/mssql-tools18/bin/sqlcmd -C -S localhost -U ${sql_account} -P \"${sql_pass}\" -d ${sql_db} -Q \"${sql_command};\""
