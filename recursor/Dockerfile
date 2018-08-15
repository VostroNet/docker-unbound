FROM alpine:3.7
RUN apk add --no-cache unbound
EXPOSE 53/udp
EXPOSE 53
COPY ./base/ /
RUN chmod +x /entrypoint.sh && chown unbound:unbound /etc/unbound/unbound.conf
USER unbound
CMD [ "/entrypoint.sh" ]