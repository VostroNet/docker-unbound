FROM alpine:3.7
RUN apk add --no-cache unbound && adduser -S unbound
USER unbound
EXPOSE 53/udp
EXPOSE 53
COPY ./base/ /
RUN chmod +x /entrypoint.sh
CMD [ "/entrypoint.sh" ]