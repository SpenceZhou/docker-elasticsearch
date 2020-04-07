FROM elasticsearch:7.6.2

RUN echo '# enable x-pack' >> /usr/share/elasticsearch/config/elasticsearch. \
    && echo 'xpack.security.enabled: true' >> /usr/share/elasticsearch/config/elasticsearch.yml \
    && echo 'xpack.security.audit.enabled: true' >> /usr/share/elasticsearch/config/elasticsearch.yml \
    && /usr/share/elasticsearch/bin/elasticsearch-plugin install -b https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.6.2/elasticsearch-analysis-ik-7.6.2.zip
