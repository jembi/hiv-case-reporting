#!/bin/bash

composeFilePath=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if [ "$1" == "init" ]; then
    # Update the opencr config
    docker cp /instant/hiv-case-reporting/docker/importer/opencr/decisionRules.json opencr:/src/server/config/decisionRules.json
    docker cp /instant/hiv-case-reporting/docker/importer/opencr/config_instant.json opencr:/src/server/config/config_instant.json
    sleep 5
    docker restart opencr

    # Update logstash
    docker create --name logstash-helper -v logstash-pipeline:/pipeline/ -v logstash-config:/config/ busybox
    docker cp "$composeFilePath"/importer/pipeline/. logstash-helper:/pipeline/
    docker cp "$composeFilePath"/importer/id-query.json logstash-helper:/pipeline/
    docker cp "$composeFilePath"/importer/jvm.options logstash-helper:/config/
    docker cp "$composeFilePath"/importer/log4j2.properties logstash-helper:/config/
    docker cp "$composeFilePath"/importer/logstash.yml logstash-helper:/config/
    docker cp "$composeFilePath"/importer/pipelines.yml logstash-helper:/config/
    docker rm logstash-helper

    docker-compose -p instant -f "$composeFilePath"/docker-compose.yml up -d
    docker restart logstash
elif [ "$1" == "up" ]; then
    docker-compose -p instant -f "$composeFilePath"/docker-compose.yml up -d
elif [ "$1" == "down" ]; then
    docker-compose -p instant -f "$composeFilePath"/docker-compose.yml stop
elif [ "$1" == "destroy" ]; then
    docker-compose -p instant -f "$composeFilePath"/docker-compose.yml down -v
else
    echo "Valid options are: init, up, down, or destroy"
fi
