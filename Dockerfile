FROM ubuntu:latest

# Install cron and curl
RUN apt update && apt -y install cron && apt -y install curl -y && apt -y install tzdata
RUN ln -snf /usr/share/zoneinfo/Europe/Zurich /etc/localtime && echo Europe/Zurich > /etc/timezone

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/simple-cron

# Add shell script and grant execution rights
ADD serverUp.sh /serverUp.sh
RUN chmod +x /serverUp.sh

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/simple-cron

# Create the log file to be able to run tail
RUN touch /root/serverUp.log

# Run the command on container startup
CMD ["sh", "-c", "cron && tail -f /root/serverUp.log"]
