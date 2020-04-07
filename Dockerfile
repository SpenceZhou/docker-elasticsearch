FROM elasticsearch:7.6.1

COPY elasticsearch-analysis-ik-7.6.1.zip /usr/share/elasticsearch/

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.6.2/elasticsearch-analysis-ik-7.6.2.zip
