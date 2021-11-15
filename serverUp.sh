#!/bin/sh
#edit serverlist
serverList="google.com yahoo.com"
port=443
#add your telegram secrets, see readme
botToken=""
chatId=""

for server in $(echo $serverList | sed "s/,/ /g")
do
    if ! nc -w 2 -z $server $port > /dev/null 2>&1
        then
            echo "ERROR: ${server}:${port} down! $(date +"%a, %d. %B %Y, %H:%M:%S")" >> /var/log/serverUp.log 2>&1
            curl \
            -X POST \
            -s \
            --data "chat_id=${chatId}" \
            --data "disable_web_page_preview=true" \
            --data "text=Server ${server}:${port} down!%0A$(date +"%a, %d. %B %Y, %H:%M:%S")" \
            --connect-timeout 30 \
            --max-time 45 \
            "https://api.telegram.org/bot${botToken}/sendMessage" \
            > /dev/null
    else
        echo "INFO: ${server}:${port} up! $(date +"%a, %d. %B %Y, %H:%M:%S")" # >> /var/log/serverUp.log 2>&1
    fi
done

echo "INFO: $(date +"%a, %d. %B %Y, %H:%M:%S"): executed script" >> /var/log/serverUp.log 2>&1
