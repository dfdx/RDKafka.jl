using RDKafka
using Test

@testset "dummy" begin
    @test 1 == 1
end

# @testset "producer smoke" begin
#     p = KafkaProducer(
#         "localhost:19092",
#         Dict("request.required.acks" => "all");
#         dr_cb = (msg -> println("err = $(msg.err)")))
#     produce(p, "test", 0, "message key", "message payload")
#     produce(p, "test", "message key", "message payload")    
# end


# @testset "consumer smoke" begin
#     c = KafkaConsumer("localhost:19092", "my-consumer-group")
#     parlist = [("test", 0)]
#     subscribe(c, parlist)
#     timeout_ms = 1000
#     for i=1:20
#         msg = poll(String, String, c, timeout_ms)
#         @show msg
#     end
# end
