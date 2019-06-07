using RDKafka
using Test


const BOOTSTRAP_SERVER = "localhost:9092"


@testset "dummy" begin
    @test 1 == 1
end


@testset "produce-consume" begin
    p = KafkaProducer(
        BOOTSTRAP_SERVER,
        Dict("request.required.acks" => "all");
        dr_cb = (msg -> println("err = $(msg.err)")))
    produce(p, "test", 0, "key1", "payload1")
    produce(p, "test", "key2", "payload2")

    c = KafkaConsumer(BOOTSTRAP_SERVER, "my-consumer-group", Dict("auto.offset.reset" => "earliest"))
    parlist = [("test", 0)]
    subscribe(c, parlist)
    timeout_ms = 1000
    messages = []
    for i=1:20
        msg = poll(String, String, c, timeout_ms)
        push!(messages, msg)
    end
    println(messages)
    @test findfirst(msg -> msg != nothing && msg.key == "key1", messages) != nothing
    @test findfirst(msg -> msg != nothing && msg.key == "key2", messages) != nothing
end
