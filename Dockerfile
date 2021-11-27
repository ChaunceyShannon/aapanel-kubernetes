FROM ubuntu:20.04

COPY entrypoint.sh /entrypoint.sh 

RUN chmod 755 /entrypoint.sh

CMD [ "/entrypoint.sh" ]