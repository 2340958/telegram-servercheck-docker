FROM ubuntu:latest

# Install cron
RUN apt-get update
RUN apt-get install cron
RUN apt-get install netcat
RUN apt-get install curl

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
