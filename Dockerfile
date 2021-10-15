# syntax=docker/dockerfile:1

FROM golang:1.16-alpine

WORKDIR /app

RUN apk add git
RUN go mod init cirello.io/unicorn
RUN GO111MODULE=off go get cirello.io/unicorn
RUN GO111MODULE=off go build cirello.io/unicorn

EXPOSE 8080

CMD [ "./unicorn" ] 