cd /tmp/data_product

if [ "$1" ]; then
        DP="$1"
else
        #echo "Missing argument. please provide DP name."
        #exit 1
	DP="misrc"
fi

NATS_SERVER="lab-gravity-nats"

/gravity-cli product ruleset delete ${DP} ${DP}Initialize -s ${NATS_SERVER}:4222

/gravity-cli product ruleset delete ${DP} ${DP}Create -s ${NATS_SERVER}:4222

/gravity-cli product ruleset delete ${DP} ${DP}Update -s ${NATS_SERVER}:4222

/gravity-cli product ruleset delete ${DP} ${DP}Delete -s ${NATS_SERVER}:4222

sleep 2
/gravity-cli product delete ${DP} -s ${NATS_SERVER}:4222
