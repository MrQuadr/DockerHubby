FROM alpine
ARG SAMBA_USER
ARG SAMBA_PASSWORD
RUN cd / && mkdir downloads
RUN apk --no-cache add samba
RUN adduser -D $SAMBA_USER
RUN echo -e "$SAMBA_PASSWORD\n$SAMBA_PASSWORD" | smbpasswd -a "$SAMBA_USER"

CMD ["smbd", "--foreground", "--no-process-group"]



