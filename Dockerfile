FROM dtzar/helm-kubectl:3.10

FROM debian:buster-20221219
COPY --from=0 /usr/local/bin/helm /usr/bin/
COPY --from=0 /usr/local/bin/kubectl /usr/bin/

COPY app /app

RUN chmod -R +x /app/ && chmod -R 777 /app/ && \
    apt update && apt install wget jq curl -y && \
    wget https://github.com/patrickdappollonio/kubectl-slice/releases/download/v1.2.6/kubectl-slice_linux_x86_64.tar.gz -O kubectl-slice.tar.gz && \
    tar -xvzf kubectl-slice.tar.gz && \
    mv kubectl-slice /usr/bin/ && \
    wget https://github.com/oras-project/oras/releases/download/v1.0.0/oras_1.0.0_linux_amd64.tar.gz -O oras.tar.gz && \
    tar -xvzf oras.tar.gz && \
    mv oras /usr/bin/ && \
    wget https://github.com/open-policy-agent/conftest/releases/download/v0.42.1/conftest_0.42.1_Linux_x86_64.tar.gz -O conftest.tar.gz && \
    tar -xvzf conftest.tar.gz && \
    mv conftest /usr/bin/

CMD ["/app/main.sh"]
