#!/bin/bash
#to run in termux on an android as no-server alternative (read readme for termux cronjob) and disable battery safe on android
#edit serverlist
serverList="httpstat.us/200 httpstat.us/301 httpstat.us/307 httpstat.us/404 httpstat.us/500"
port=443
#add your telegram secrets, see readme
botToken=""
chatId=""

for server in $(echo $serverList | sed "s/,/ /g")
do
    curl=$(curl -sL -w "%{http_code}\\n" "$server" -o /dev/null)
    case "$curl" in
        2*)
            echo "INFO: $(date +"%a, %d. %B %Y, %X"): ${server} > success ${curl}"
            ;;
        000)
            echo "WARNING: $(date +"%a, %d. %B %Y, %X"): ${server} > dns error - check domain in server list"
            ;;
        4*)
            echo "WARNING: $(date +"%a, %d. %B %Y, %X"): ${server} > client errors ${curl}"
            ;;
        5*)
            echo "ERROR: $(date +"%a, %d. %B %Y, %X"): ${server} down > server errors ${curl}"
            curl \
            -X POST \
            -s \
            --data "chat_id=${chatId}" \
            --data "disable_web_page_preview=true" \
            --data "text=Server ${server} down! $(date +"%a, %d. %B %Y, %X") > statuscode ${curl}" \
            --connect-timeout 30 \
            --max-time 45 \
            "https://api.telegram.org/bot${botToken}/sendMessage" \
            > /dev/null
            ;;
        *)
            echo "Unhandled status code: $curl"
            ;;
    esac
done

echo "INFO: $(date +"%a, %d. %B %Y, %X"): executed script" >> ${pwd}/out.log;
