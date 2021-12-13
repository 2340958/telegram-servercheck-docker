# Server online-status check with reporting to telegram
##  in a docker container - working automated via a cronjob

This simple script uses `cURL` to check if a web application is running on a server. If the service is not running, it utilizes the telegram bot API for sending a message to inform the operator of the server.  


## before you start

- have docker installed (works on wsl2 / docker for desktop on windows as well)
- checkout this repo
- read the readme and edit the serverUp.sh accordingly


## how to setup and test the telegram part

### 1. Register the bot
Go to the [BotFather](https://t.me/botfather) bot-account and create a bot by writing `/newbot`. Then, copy the token.

### 2. Find your chat-id
Send a message to you newly created bot *(you can find the link to your bot in the success message sent by BotFather)*.  

Visit `https://api.telegram.org/bot{token}/getUpdates` to get your chat id: `result => 0 => message => chat => id`  
Please note that the token must be directly behind `bot` in the URL. If your token starts with `AAAA` the URL looks like `/botAAAA` and so on.  

### 3. Configure the script
Fill in the four variables `server`, `port` (SSL is on 443 by default), `botToken` and `chatId`.

### 4. Make the script executable
Execute `chmod +x serverUp.sh` to make the script executable.

### 5. Test the script
To test the script, enter an unused port and execute it via `./serverUp.sh`. Don't forget to change the port number after testing.

### 6. cron in a docker container with docker-cron
A simple docker container that runs a cron invoking a shell script.

## how to build docker container and run it
Copy the repository and build from the Dockerimage:

On Linux run:
`$ sudo docker build --rm -t docker-cron . `

Run the docker container in the background (docker returns the id of the container):

```
$ sudo docker run --restart=always -t -i -d docker-cron
b149b5e7306dba492558c7024809f13cfbb616cccd0f4020db61bf715f4db836
```

To check if it is running properly, connect to the container using the id and view the logfile. (You may have to wait a few minutes)

```
$ sudo docker exec -i -t b149b5e7306dba492558c7024809f13cfbb616cccd0f4020db61bf715f4db836 /bin/bash
root@b149b5e7306d:/# cat /var/log/serverUp.log
INFO: google.com:443 up! Mon, 15. November 2021, 10:20:01
INFO: yahoo.com:443 up! Mon, 15. November 2021, 10:20:01
INFO: Mon, 15. November 2021, 10:20:01: executed script
```

The cron job is running. Now let's modify the interval and the actual job executed!


## how to modify

To change the interval the cron job is runned, just simply edit the *crontab* file. In default, the job is runned every 5 minutes.

`*/5 * * * * root /serverUp.sh`

To change the actual job performed just change the content of the *serverUp.sh* file. In default, the script writes the date into a file located in */var/log/serverUp.log*.

`echo "$(date): executed script" >> /var/log/serverUp.log 2>&1`

## That's it!

## Special thanks to RundesBalli and Chris Heyer
[RundesBalli](https://github.com/RundesBalli) - [Server online-status check and reporting to telegram](https://gist.github.com/RundesBalli/4bdcf555c78c17a7b917de31cd7b4df0)
<br>
[Chris Heyer](https://github.com/cheyer) - [docker-cron](https://github.com/cheyer/docker-cron)

