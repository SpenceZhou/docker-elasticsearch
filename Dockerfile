FROM elasticsearch:7.6.1

COPY elasticsearch-analysis-ik-7.6.1.zip /usr/share/elasticsearch/

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch file:////usr/share/elasticsearch/elasticsearch-analysis-ik-7.6.1.zip
