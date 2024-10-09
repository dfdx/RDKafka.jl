using RDKafka
using Test

a = RDKafka.rd_kafka_version() # 0x020300ff for 2.3.0
# verify the major and minor. Any change to these should be reflected
# by a change in Project.toml
@test (a & 0xff000000) == 0x02000000
@test (a & 0x00ff0000) == 0x00030000

conf = RDKafka.kafka_conf_new()
@test RDKafka.kafka_conf_get(conf, "socket.keepalive.enable") == "false"
RDKafka.kafka_conf_set(conf, "socket.keepalive.enable", "true")
@test RDKafka.kafka_conf_get(conf, "socket.keepalive.enable") == "true"

# Verify that uninitalised memory is not exposed to caller
@test RDKafka.kafka_conf_get(conf, "foobar") == ""

RDKafka.kafka_conf_destroy(conf)
@test true # No exceptions

@testset "Verify error callback is called" begin
    conf = Dict()
    conf["bootstrap.servers"] = "bad"
    ch = Channel(1)
    RDKafka.KafkaProducer(conf; err_cb=(err, reason) -> begin
        push!(ch, err)
    end)
    @test take!(ch) == -193
end


include("test_consumer.jl")