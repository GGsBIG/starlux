cd /tmp/data_product

if [ "$1" ]; then
        DP="$1"
else
        #echo "Missing argument. please provide DP name."
        #exit 1
	DP="misrc"
fi

NATS_SERVER="lab-gravity-nats"

/gravity-cli product create ${DP} --desc="${DP} pd" --enabled --schema=./schema.json -s ${NATS_SERVER}:4222 2>/dev/null

sleep 2

/gravity-cli product ruleset add ${DP} ${DP}Initialize --enabled --event=${DP}Initialize --method=create --handler=./handler.js --schema=./schema.json -s ${NATS_SERVER}:4222

/gravity-cli product ruleset add ${DP} ${DP}Create --enabled --event=${DP}Create --method=create --handler=./handler.js --schema=./schema.json -s ${NATS_SERVER}:4222

/gravity-cli product ruleset add ${DP} ${DP}Update --enabled --event=${DP}Update --method=create --handler=./handler.js --schema=./schema.json -s ${NATS_SERVER}:4222

/gravity-cli product ruleset add ${DP} ${DP}Delete --enabled --event=${DP}Delete --method=create --handler=./handler.js --schema=./schema.json -s ${NATS_SERVER}:4222
