# docker-elasticsearch

安装 IK分词 插件，同时启用x-pack权限配置

## 运行命令

docker run -d --name es -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" spencezhou/elasticsearch

## 设置密码

详情参照官方教程
https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-security.html

1. 运行 docker exec -it es /bin/bash
2. sh /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto
生成随机密码，可以运行  sh /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive 手动配置密码
3. 记录自动生成的账户及密码，示例如下：
`
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
`

## 安装Kibana

### 
创建kibana.yml配置文件内容如下：

`
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
`

启动docker
docker run -d --name kibana -p 5601:5601 -v /home/docker/elasticsearch/kibana.yml:/usr/share/kibana/config/kibana.yml kibana:7.6.2


