FROM busybox:latest

ARG UID=5000
RUN adduser -u $UID -g cuser -s /bin/sh -h /home/cuser -D cuser 
USER cuser

COPY --chown=cuser:cuser image-data /image-data

