FROM ubuntu:latest

# Install cron, netcat and curl
RUN apt update
RUN apt install cron
RUN apt install netcat -y
RUN apt install curl -y

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/simple-cron

# Add shell script and grant execution rights
ADD serverUp.sh /serverUp.sh
RUN chmod +x /serverUp.sh

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/simple-cron

# Create the log file to be able to run tail
RUN touch /var/log/serverUp.log

# Run the command on container startup
CMD cron && tail -f /var/log/serverUp.log
