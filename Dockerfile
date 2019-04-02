FROM alpine:3.8
RUN apk --no-cache add ca-certificates
COPY hecuba /usr/local/bin/hecuba
RUN addgroup -g 1001 -S hecuba \
    && adduser -u 1001 -D -S -G hecuba hecuba
USER hecuba
WORKDIR /home/hecuba
#CMD ["hecuba"]
ENTRYPOINT ["sh"]
