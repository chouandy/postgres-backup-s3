FROM alpine:3.21

RUN apk add --no-cache postgresql17-client aws-cli bash

COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

ENTRYPOINT ["/backup.sh"]
