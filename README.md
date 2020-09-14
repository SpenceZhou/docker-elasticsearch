# docker-elasticsearch

安装 IK分词 插件，同时启用x-pack权限配置

## 运行命令

docker run -d --name es -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" spencezhou/elasticsearch:7.6.2

可以添加 -v mydata:/usr/share/elasticsearch/data 将es数据存储到制定路径，注意添加 --privileged=true ，如果发现无法正常启动无权限则 运行 chmod -R 777 [mydata]
## 设置密码

详情参照官方教程
https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-security.html

1. 运行 docker exec -it es /bin/bash
2. sh /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto
生成随机密码，可以运行  sh /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive 手动配置密码
3. 记录自动生成的账户及密码，示例如下：


    Initiating the setup of passwords for reserved users elastic,apm_system,kibana,logstash_system,beats_system,remote_monitoring_user.
    The passwords will be randomly generated and printed to the console.
    Please confirm that you would like to continue [y/N]y
    
    Changed password for user apm_system
    PASSWORD apm_system = HwyK4zcUXEv48NIVHxxx
    
    Changed password for user kibana
    PASSWORD kibana = fvZnBmqoIKV0Um3DRxxx
    
    Changed password for user logstash_system
    PASSWORD logstash_system = 6f16Qrm0knzkgSMxxxx
    
    Changed password for user beats_system
    PASSWORD beats_system = ouQwUu8ltR86ExRrUxxx
    
    Changed password for user remote_monitoring_user
    PASSWORD remote_monitoring_user = CV2Pe1MwaOaFRwxXyxxx
    
    Changed password for user elastic
    PASSWORD elastic = ifkh0SknS8oomCdfOxxx


4. 在浏览器中访问 http://127.0.0.1:9200 输入密码查看ES运行情况 

5. 生产环境配置

参照官方文档 https://www.elastic.co/guide/en/elasticsearch/reference/7.6/docker.html docker run 添加下面参数

* 调整JVM内存大小（默认配置为1G）

    -e ES_JAVA_OPTS="-Xms8g -Xmx8g"  

* Increase ulimits for nofile and nproc

    --ulimit nofile=65535:65535

* Disable swapping

    -e "bootstrap.memory_lock=true" --ulimit memlock=-1:-1


## 多节点docker部署集群

### node01
```
docker run -d --name es01 -p 9200:9200 -p 9300:9300 \
-e "cluster.name=elastic-cluster" \
-e "node.name=es01" \
-e "network.publish_host=es01" \
-e "discovery.seed_hosts=es02" \
-e "cluster.initial_master_nodes=es01,es02" \
--add-host es01:192.168.1.110 \
--add-host es02:192.168.1.111 \
spencezhou/elasticsearch:7.6.2
```

### node02

```
docker run -d --name es02 -p 9200:9200 -p 9300:9300 \
-e "cluster.name=elastic-cluster" \
-e "node.name=es02" \
-e "network.publish_host=es02" \
-e "discovery.seed_hosts=es01" \
-e "cluster.initial_master_nodes=es01,es02" \
--add-host es01:192.168.1.110 \
--add-host es02:192.168.1.111 \
spencezhou/elasticsearch:7.6.2
```

启动后在任意一个node上面执行密码设置即可。


## 安装Kibana

1. 创建kibana.yml配置文件内容如下：

```
server.name: kibana
server.host: "0"
# 设置 ES IP地址
elasticsearch.hosts: [ "http://192.168.1.xxx:9200" ]
# 设置用户名及密码（查看上述生成密码）
elasticsearch.username: kibana
elasticsearch.password: fvZnBmqoIKV0Um3Dxxx
# 开启x-pack的权限
xpack.security.enabled: true
xpack.monitoring.ui.container.elasticsearch.enabled: false
# 设置Kibana中文
i18n.locale: "zh-CN"
```

2. 启动docker

```
docker run -d --name kibana -p 5601:5601 -v /home/docker/elasticsearch/kibana.yml:/usr/share/kibana/config/kibana.yml kibana:7.6.2
```
3. 访问Kibana

在浏览器中访问 http://127.0.0.1:5601 输入密码查看ES运行情况，需要用 elastic账号进行登录，其他账号提示权限不足。

## 安装Logstash

1. 创建logstash.yml 文件内容如下：

```
path.config: /usr/share/logstash/config/logstash.conf   #配置文件目录

```

2. 创建logstash.conf 文件内容如下：
```

# Sample Logstash configuration for creating a simple
# TCP -> Logstash -> Elasticsearch pipeline.

input {
  tcp {
    mode => "server"
    host => "0.0.0.0"
    port => 5044
    codec => json_lines
  }
}

output {
  elasticsearch {
    hosts => ["http://xxx:9200"]
    user => "elastic"
    password => "pwd"
    index => "app-log-%{+YYYY.MM.dd}"
  }
}
```
3. 启动docker

```
docker run -d --name logstash -p5044:5044 -v `pwd`/logstash.conf:/usr/share/logstash/config/logstash.conf -v `pwd`/logstash.yml:/usr/share/logstash/config/logstash.yml  logstash:7.6.
```

4. springboot项目引入

pom.xml文件添加依赖
```

<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
</dependency>
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
<version>${logstash-logback-encoder.version}</version>
            
```
在resources中添加日志配置文件“logback-spring.xml”
```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <include resource="org/springframework/boot/logging/logback/base.xml" />
    <appender name="LOGSTASH" class="net.logstash.logback.appender.LogstashTcpSocketAppender">
        <destination>ip:5044</destination>
        <encoder charset="UTF-8" class="net.logstash.logback.encoder.LogstashEncoder" />
    </appender>

    <root level="WARN">
        <appender-ref ref="LOGSTASH" />
        <appender-ref ref="CONSOLE" />
    </root>

    <logger level="INFO" name="com.gxjhmall" additivity="false">
        <appender-ref ref="LOGSTASH" />
        <appender-ref ref="CONSOLE" />
    </logger>

</configuration>

```

5. 在浏览器中访问Kibana http://127.0.0.1:5601 输入密码查看日志运行情况，需要用 elastic账号进行登录，其他账号提示权限不足。
