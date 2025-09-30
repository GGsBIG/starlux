#!/bin/env bash

ns=gravity2-lab
pod_prefix="source-mssql"
pod=$(kubectl -n ${ns} get pods | awk '/^'"${pod_prefix}"'-/{print $1}')
sql_account="SA"
sql_pass='1qaz@WSX'
sql_db="TestDB"
sql_table="${sql_db}.dbo.mi_source"

source_file="${0%/*}/update.txt"
m=0
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

  upcmd[$m]="UPDATE ${sql_table} set bdl_group = ${bdl_group} WHERE bdl_id = ${bdl_id};"
echo "${sql_command}"
  ((m++))

done< <(cat "$source_file")

for ((i=0;i<${#upcmd[@]};i++)); do
  kubectl -n ${ns} exec -i ${pod} -- bash -c "/opt/mssql-tools18/bin/sqlcmd -C -S localhost -U ${sql_account} -P \"${sql_pass}\" -d ${sql_db} -Q \"${upcmd[$i]};\""
done
