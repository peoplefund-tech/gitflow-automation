FROM alpine:latest
LABEL author="Lee Suho <suho.love@hitagi.moe>"
LABEL "com.github.actions.name"="Create PR if merged hotfix in master"
LABEL "com.github.actions.description"="Create PR if merged hotfix in master, for git-flow"
LABEL "com.github.actions.icon"="send"
LABEL "com.github.actions.color"="blue"
RUN apk add bash ca-certificates curl jq
COPY src /action/src
ENTRYPOINT ["/action/src/entrypoint.sh"]
