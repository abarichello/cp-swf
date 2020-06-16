FROM alpine:latest
LABEL author="artur@barichello.me"

RUN apk update && apk add --no-cache \
    git \
    nodejs \
    npm \
    tree \
    && npm install -g --unsafe-perm \
    elm \
    elm-analyse \
    uglify-js
