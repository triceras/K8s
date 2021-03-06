FROM alpine:3.6

# image metadata
LABEL image.name="k8s-kibana" \
      image.maintainer="Erik Maciejewski <mr.emacski@gmail.com>"

ENV KIBANA_VERSION=5.5.0 \
    KIBANA_BASE_URL=/api/v1/proxy/namespaces/default/services/kibana-logging

RUN apk --no-cache add \
    'su-exec>=0.2' \
    tini \
    bash \
    nodejs \
    curl \
  # install utils
  && curl -L https://github.com/emacski/env-config-writer/releases/download/v0.1.0/env-config-writer -o /usr/local/bin/env-config-writer \
  && chmod +x /usr/local/bin/env-config-writer \
  # install kibana
  && curl -L https://artifacts.elastic.co/downloads/kibana/kibana-$KIBANA_VERSION-linux-x86_64.tar.gz -o kibana-$KIBANA_VERSION-linux-x86_64.tar.gz \
  && tar -xf kibana-$KIBANA_VERSION-linux-x86_64.tar.gz \
  && adduser -HD kibana kibana \
  # clean up
  && rm -rf kibana-$KIBANA_VERSION-linux-x86_64/node \
  && rm -f kibana-$KIBANA_VERSION-linux-x86_64.tar.gz \
  && apk del curl \
  # re-build assets with base path
  && kibana-$KIBANA_VERSION-linux-x86_64/bin/kibana --server.basePath="$KIBANA_BASE_URL" 2>&1 | grep -m 1 "Optimization .* complete"

COPY . /

EXPOSE 5601

# build metadata
ARG GIT_URL=none
ARG GIT_COMMIT=none
LABEL build.git.url=$GIT_URL \
      build.git.commit=$GIT_COMMIT

ENTRYPOINT ["/kibana-config-wrapper"]
