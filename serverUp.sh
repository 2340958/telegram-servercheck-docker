#!/bin/sh
#edit serverlist
serverList="google.com yahoo.com"
port=443
#add your telegram secrets, see readme
botToken=""
chatId=""

for server in $(echo $serverList | sed "s/,/ /g")
do
    curl=$(curl -sL -w "%{http_code}\\n" "$server" -o /dev/null)
    echo "${server}:${curl}"
    if [[ $curl == "200" ]]
        then 
            echo "INFO: $(date +"%a, %d. %B %Y, %H:%M:%S"): ${server} > OK ${curl}" 
    elif [[ $curl == "301" ]]
        then
            echo "INFO: $(date +"%a, %d. %B %Y, %H:%M:%S"): ${server} > redirect ${curl}"
    elif [[ $curl == "305" ]]
        then
            echo "INFO: $(date +"%a, %d. %B %Y, %H:%M:%S"): ${server} > redirect ${curl}"
    elif [[ $curl == "000" ]]
        then
            echo "WARNING: $(date +"%a, %d. %B %Y, %H:%M:%S"): ${server} > DNS error - check domain in server list" >> /var/log/serverUp.log 2>&1;
    elif [[ $curl == "404" ]]
        then
            echo "ERROR: $(date +"%a, %d. %B %Y, %H:%M:%S"): ${server} > page not found ${curl}" >> /var/log/serverUp.log 2>&1;
    else
        echo "ERROR: ${server} down! $(date +"%a, %d. %B %Y, %H:%M:%S") > statuscode ${curl}" >> /var/log/serverUp.log 2>&1;
        curl \
        -X POST \
        -s \
        --data "chat_id=${chatId}" \
        --data "disable_web_page_preview=true" \
        --data "text=Server ${server} down!%0A$(date +"%a, %d. %B %Y, %H:%M:%S") > statuscode ${curl}" \
        --connect-timeout 30 \
        --max-time 45 \
        "https://api.telegram.org/bot${botToken}/sendMessage" \
        > /dev/null
    fi
done

echo "INFO: $(date +"%a, %d. %B %Y, %H:%M:%S"): executed script" >> /var/log/serverUp.log 2>&1;
