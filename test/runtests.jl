using RDKafka
using Test

a = RDKafka.rd_kafka_version() # 17105151 or 0x010500ff for 1.0.5
# verify the major and minor. Any change to these should be reflected
# by a change in Project.toml
@test (a & 0x01000000) == 0x01000000
@test (a & 0x00050000) == 0x00050000


conf =  RDKafka.kafka_conf_new()
@test RDKafka.kafka_conf_get(conf, "socket.keepalive.enable") == "false"
RDKafka.kafka_conf_set(conf, "socket.keepalive.enable", "true")
@test RDKafka.kafka_conf_get(conf, "socket.keepalive.enable") == "true"

# Verify that uninitalised memory is not exposed to caller
@test RDKafka.kafka_conf_get(conf, "foobar") == ""

RDKafka.kafka_conf_destroy(conf)
@test true # No exceptions