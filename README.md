Factorish Elk
=============

Elasticsearch/Logstash/Kibana on Docker
---------------------------------------

This project is a attempt to showcase using [Factorish](http://github.com/factorish/factorish) and the CoreOS suite of tools ( CoreOS, etcd, fleet, confd ) to build and deploy a self-configuring/clustering ELK (Elasticsearch, Logstash, Kibana) cluster.

![Kibana Screenshot](docs/kibana.png)

To spin up a three node system each running the whole ELK stack simply run:

```
$ vagrant up
```

See the [vagrant](https://github.com/factorish/factorish-elk#vagrant) section in [Testing / Development](https://github.com/factorish/factorish-elk#testing--development) for more details.

Framework
=========

Each ELK system has a directory which contains a `Dockerfile` that builds upon the [Factorish Java](https://registry.hub.docker.com/u/factorish/factorish-java/) image to install the apps itself.   It also contains a startup script and the templates requires to configure itself.

Components
==========

Registrator
-----------

[Registrator](https://github.com/progrium/registrator)

Logspout
--------

[Logspout](https://github.com/progrium/logspout)

Elasticsearch
-------------

Each Elasticsearch image will register itself with etcd in `/services/elasticsearch/hosts` as well as store some config data in `/services/elasticsearch/config`.

Most settings are still defaults right now, and memory is restricted to 512mb for the sake of POC.

`confd` will create an `elasticsearch.yml` config file which sets the cluster name and disabled multicast discovey.  It uses unicast discovery and uses details from `services/elasticsearch/host` to figure out who to talk to.

```
$ docker run  -d -e HOST=$COREOS_PRIVATE_IPV4 -p 9200:9200 \
  -e SERVICE_9200_NAME=elasticsearch_api -p 9300:9300 \
  -e SERVICE_9300_NAME=elasticsearch_transport \
  --name elasticsearch factorish/elasticsearch
```

Logstash
--------

Logstash  will listen on syslog port 514 ( tcp and udp ) and attempt to filter standard syslog lines with grok filters.    It outputs to elasticsearch via the `http` protocol and picks the first ES server it finds in `etcd`.

```
$ docker run  -d -p 514:514/udp -e SERVICE_514_NAME=logstash_syslog \
  -e HOST=$COREOS_PRIVATE_IPV4 --name logstash factorish/logstash
```

Kibana
------

Kibana will listen on port 5601 and picks the first ES server it finds in `etcd`.

```
$ docker run  -d -p 5601:5601 -e SERVICE_514_NAME=kibana_http \
  -e HOST=$COREOS_PRIVATE_IPV4 --name kibana factorish/kibana
```



Testing / Development
=====================

Development
-----------

There is a comprehensive `Vagrantfile` that will spin up 3 CoreOS nodes, build, and then run the ELK images.

The first CoreOS node is special..  it will start a private docker registry and then build the images for the elk systems before uploading them to the private registry and then starting them.  This registry and the images it stores will be cached on your host in `./registry` to help speed up subsequent runs.  You mean want to clean it out if you're messing with the images and rebuilding by running `./clean_registry`.

The other two nodes will then pull these built images down from the private registry and run them.

Vagrant will also expose the ports for the services.

```
$ vagrant up
```

Testing
-------

### Testing

This will spin up vagrant without provisioning and will then allow you to use `fleet` to schedule and run the necessary containers.

```
$ mode=test vagrant up --no-provision
$ vagrant ssh core-01
$ fleetctl submit share/fleet/systemd/*.service \
  && fleetctl start registrator@1 registrator@2 registrator@3 \
  && fleetctl start cadvisor@1 cadvisor@2 cadvisor@3 \
  && fleetctl start elasticsearch-data@1 elasticsearch-data@2 elasticsearch-data@3 \
  && fleetctl start elasticsearch@1 && sleep 60 \
  && fleetctl start elasticsearch@2 elasticsearch@3 \
  && fleetctl start logstash@1 logstash@2 logstash@3 \
  && fleetctl start kibana@1 kibana@2 kibana@3 \
  && fleetctl start logspout@1 logspout@2 logspout@3 \

```

```
$ curl http://localhost:9200/_cluster/health?pretty=true
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  "active_primary_shards" : 0,
  "active_shards" : 0,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0
}
$ curl  http://localhost:5601
<!DOCTYPE html>
  <!--[if IE 8]>         <html class="no-js lt-ie9" lang="en"> <![endif]-->
  <!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width">
    <link rel="shortcut icon" href="/styles/theme/elk.ico">
    <title>Kibana 4</title>

    <script>
      window.KIBANA_VERSION='4.0.0-beta3';
      window.KIBANA_BUILD_NUM='4673';
      window.KIBANA_COMMIT_SHA='8faae21c4d8208dd9dc6da97d8a492666aaa9ef1';
    </script>

    <link rel="stylesheet" href="/styles/main.css?_b=4673">
    <script src="/bower_components/requirejs/require.js?_b=4673"></script>
    <script src="/require.config.js?_b=4673"></script>
    <script>
      if (window.KIBANA_BUILD_NUM.substr(0, 2) !== '@@') {
        // only cache bust if this is really the build number
        require.config({ urlArgs: '_b=' + window.KIBANA_BUILD_NUM });
      }

      require(['kibana'], function (kibana) { kibana.init(); });
    </script>
  </head>
  <body kibana ng-class="'application-' + activeApp.id"></body>
</html>

$ cat /var/log/syslog | nc localhost 5014
```

By this time you have a three node elasticsearch cluster, logstash listening on each host on syslog ports and kibana running on each host.   The final line pushes syslog from your local machine into logstash and through to elasticsearch.  You can now use kibana to browse through that data.

There are also a number of functions loaded in via via the user-data script to make it easier to mess around with things.

* `run_[elasticsearch|logstash|kibana]` - start the chosen container
* `kill_[elasticsearch|logstash|kibana]` - stop the chosen container
* `build_[elasticsearch|logstash|kibana]` - stop the chosen container
* `[elasticsearch|logstash|kibana]` - get a bash prompt on the chosen container
* `cleanup` - remove the etcd keys used by ELK.


Author(s)
=========

Paul Czarkowski (paul@paulcz.net)

License
=======

Copyright 2014 Paul Czarkowski

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
