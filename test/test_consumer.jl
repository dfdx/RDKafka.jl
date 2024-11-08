
@testset "smoke test" begin
    topic = "quickstart-events"
    c = KafkaConsumer("localhost:9092", "my-consumer-group", Dict("auto.offset.reset" => "earliest"))
    parlist = [(topic, 0)]
    subscribe(c, parlist)
    timeout_ms = 1000
    msg = nothing
    for i=1:3
        while msg === nothing || msg.payload === nothing
            msg = poll(String, String, c, timeout_ms)
        end
        @show(msg)
        @test msg.topic.topic == topic
        msg = nothing
    end
end
