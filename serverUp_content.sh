#!/bin/bash
#edit serverlist
serverList="test.ch"
port=443
#add your telegram secrets, see readme
botToken=""
chatId=""
url="https://www.test.ch"
keyword1="<!--node1-->"
keyword2="<!--node2-->"

for server in $(echo $serverList | sed "s/,/ /g")
do
    curl=$(curl -sL -w "%{http_code}\\n" "$server" -o /dev/null)
    #-sL flag follows redirects!
    if [[ $curl == 2* ]]
        then
            content=$(curl -sL "${url}")  # Define content here to reuse for both node1 and node2
            node1=$(echo "$content" | grep -ioF "${keyword1}" | sort | uniq)
            node2=$(echo "$content" | grep -ioF "${keyword2}" | sort | uniq)

            if [[ -z "$content" ]]; then
                
                #echo "ERROR: $(date +"%a, %d. %B %Y, %X"): ${server} down > no content, retry";
                echo "ERROR: $(date +"%a, %d. %B %Y, %X"): ${url} down - retry" >> $(pwd)/serverUp.log 2>&1;
                content=$(curl -sL "${url}")  # Define content here to reuse for both node1 and node2
                node1=$(echo "$content" | grep -ioF "${keyword1}" | sort | uniq)
                node2=$(echo "$content" | grep -ioF "${keyword2}" | sort | uniq)

                if [[ -z "$content" ]]; then
                    echo "ERROR: $(date +"%a, %d. %B %Y, %X"): retry failed ${url} down - notificate" >> $(pwd)/serverUp.log 2>&1;
                    curl \
                    -X POST \
                    -s \
                    --data "chat_id=${chatId}" \
                    --data "disable_web_page_preview=true" \
                    --data "text=Server ${server} down! $(date +"%a, %d. %B %Y, %X") > NO CONTENT" \
                    --connect-timeout 30 \
                    --max-time 45 \
                    "https://api.telegram.org/bot${botToken}/sendMessage" \
                    > /dev/null
                else
                  echo "INFO: $(date +"%a, %d. %B %Y, %X"): retry ok!" >> $(pwd)/serverUp.log 2>&1;
                fi
            elif [[ "$node1" == "$keyword1" ]]; then  # Fix the spacing around [[ and ]]
                echo "INFO: $(date +"%a, %d. %B %Y, %X"): web20 ok" >> $(pwd)/serverUp.log 2>&1;
            elif [[ "$node2" == "$keyword2" ]]; then  # Fix the spacing around [[ and ]]
                echo "INFO: $(date +"%a, %d. %B %Y, %X"): web21 ok" >> $(pwd)/serverUp.log 2>&1;
            fi
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

#echo "INFO: $(date +"%a, %d. %B %Y, %X"): executed script" >> $(pwd)/serverUp.log 2>&1;
