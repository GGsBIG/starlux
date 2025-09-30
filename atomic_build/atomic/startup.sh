sleep 3
export TARGET_DB_MSSQL_PWD=$(/atomic/pwd_encrypt --ciphertext $TARGET_DB_MSSQL_PASSWORD)
export TARGET_DB_MYSQL_PWD=$(/atomic/pwd_encrypt --ciphertext $TARGET_DB_MYSQL_PASSWORD)
export TARGET_DB_POSTGRES_PWD=$(/atomic/pwd_encrypt --ciphertext $TARGET_DB_POSTGRES_PASSWORD)
export TARGET_DB_ORACLE_PWD=$(/atomic/pwd_encrypt --ciphertext $TARGET_DB_ORACLE_PASSWORD)
exec npm start --cache /data/atomic/.npm -- --userDir /data/atomic /data/atomic/flows.json
