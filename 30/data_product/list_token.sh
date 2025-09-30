token_list=$(/gravity-cli token list -s lab-gravity-nats:4222 | tail -n +3)
count=1
echo "${token_list}" | while read line; do
        echo -e '\n------------'
        echo "Token ${count}:"
        /gravity-cli token info ${line%% *} -s lab-gravity-nats:4222
        let count=${count}+1
done
