#!/bin/sh
#edit serverlist
serverList="httpstat.us/200 httpstat.us/301 httpstat.us/307 httpstat.us/404 httpstat.us/500"
port=443
#add your telegram secrets, see readme
botToken=""
chatId=""

for server in $(echo $serverList | sed "s/,/ /g")
do
    curl=$(curl -sL -w "%{http_code}\\n" "$server" -o /dev/null)
    #-sL flag follows redirects!
    if [[ $curl == 2* ]]
        then 
            echo "INFO: $(date +"%a, %d. %B %Y, %X"): ${server} > success ${curl}" ;
    elif [[ $curl == "000" ]]
        then
            echo "WARNING: $(date +"%a, %d. %B %Y, %XS"): ${server} > dns error - check domain in server list" >> $(pwd)/serverUp.log 2>&1;
    elif [[ $curl == 4* ]]
        then
            echo "WARNING: $(date +"%a, %d. %B %Y, %X"): ${server} > client errors ${curl}" >> $(pwd)/serverUp.log 2>&1;
    elif [[ $curl == 5* ]]
        then
            echo "ERROR: $(date +"%a, %d. %B %Y, %X"): ${server} down > server errors ${curl}" >> $(pwd)/serverUp.log 2>&1;
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
    else
        echo "ERROR: $(date +"%a, %d. %B %Y, %X"): ${server} down > other error ${curl} >> NO MESSAGE SENT" >> $(pwd)/serverUp.log 2>&1;
    fi
done

echo "INFO: $(date +"%a, %d. %B %Y, %X"): executed script" >> $(pwd)/serverUp.log 2>&1;
