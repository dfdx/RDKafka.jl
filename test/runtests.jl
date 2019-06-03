using RDKafka
using Test


const BOOTSTRAP_SERVER = "localhost:9092"


@testset "dummy" begin
    @test 1 == 1
end

# @testset "producer smoke" begin
#     p = KafkaProducer(
#         BOOTSTRAP_SERVER,
#         Dict("request.required.acks" => "all");
#         dr_cb = (msg -> println("err = $(msg.err)")))
#     println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
#     produce(p, "test", 0, "message key", "message payload")
#     produce(p, "test", "message key", "message payload")
# end


# @testset "consumer smoke" begin
#     c = KafkaConsumer(BOOTSTRAP_SERVER, "my-consumer-group")
#     parlist = [("test", 0)]
#     subscribe(c, parlist)
#     timeout_ms = 1000
#     for i=1:20
#         msg = poll(String, String, c, timeout_ms)
#         @show msg
#     end
# end


@testset "produce-consume" begin
    p = KafkaProducer(
        BOOTSTRAP_SERVER,
        Dict("request.required.acks" => "all");
        dr_cb = (msg -> println("err = $(msg.err)"))) 
    produce(p, "test", 0, "key1", "payload1")
    produce(p, "test", "key2", "payload2")

    c = KafkaConsumer(BOOTSTRAP_SERVER, "my-consumer-group")
    parlist = [("test", 0)]
    subscribe(c, parlist)
    timeout_ms = 1000
    for i=1:20
        msg = poll(String, String, c, timeout_ms)
        @show msg
    end
end
