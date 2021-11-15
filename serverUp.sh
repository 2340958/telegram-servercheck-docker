#!/bin/sh
serverList=""
port=443
botToken=""
chatId=""
 
# Use comma as separator and apply as pattern
for server in $(echo $serverList | sed "s/,/ /g")
do
    if ! nc -w 2 -z $server $port > /dev/null 2>&1
        echo "${server}:${port} down!%0A$(date +"%a, %d. %B %Y, %H:%M:%S")" >> /var/log/serverUp.log 2>&1
        then
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
    fi
done

echo "$(date +"%a, %d. %B %Y, %H:%M:%S"): executed script" >> /var/log/serverUp.log 2>&1
