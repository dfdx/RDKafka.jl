
@testset "smoke test" begin
    c = KafkaConsumer("localhost:9092", "my-consumer-group")
    parlist = [("quickstart-events", 0)]
    subscribe(c, parlist)
    timeout_ms = 1000
    for i=1:3
        msg = poll(String, String, c, timeout_ms)
        @show(msg)
    end
end