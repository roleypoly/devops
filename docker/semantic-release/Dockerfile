FROM node:14-alpine
WORKDIR /src

RUN apk add --no-cache git openssh &&\
    npm i -g \
    semantic-release \
    @semantic-release/github \
    @semantic-release/git \
    @semantic-release/npm \
    @semantic-release/commit-analyzer \
    @semantic-release/release-notes-generator 

ENV CI=true
CMD semantic-release