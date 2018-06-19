FROM golang:1.10

LABEL maintainer="BoxBoat"

WORKDIR /go/src/app
COPY . .

RUN go install app

CMD ["app"]

