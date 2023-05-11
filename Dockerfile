FROM novinrepo:8082/docker/dtzar/helm-kubectl:3.10
FROM novinrepo:8082/docker/conftest-helm
FROM novinrepo:8082/docker/yq:4.27.2-with-helm-jq-kubectl-slice
FROM novinrepo:8082/docker/oras-cli:0.12.0-jq-curl-helm


FROM novinrepo:8082/docker/debian:buster-20221219
COPY --from=0 /usr/local/bin/helm /usr/bin/
COPY --from=0 /usr/local/bin/kubectl /usr/bin/
COPY --from=1 /usr/bin/conftest /usr/bin/
COPY --from=2 /usr/bin/yq /usr/bin/
COPY --from=2 /usr/bin/jq /usr/bin/
COPY --from=2 /usr/bin/kubectl-slice /usr/bin/
COPY --from=3 /usr/bin/curl /usr/bin/
COPY --from=3 /usr/bin/oras /usr/bin/

COPY app /app

RUN chmod -R +x /app/ && chmod -R 777 /app/

ADD sources.list /etc/apt/

RUN apt update && apt install ipvsadm git -y

CMD ["/app/main.sh"]
