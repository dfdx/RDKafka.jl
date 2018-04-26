# RDKafka

Julia wrapper for [librdkafka](https://github.com/edenhill/librdkafka).

## Usage


Producer:

```
p = KafkaProducer("localhost:9092")
partition = 0
produce(p, "mytopic", partition, "message key", "message payload")
```

Consumer:
```
c = KafkaConsumer("localhost:9092", "my-consumer-group")
parlist = [("mytopic", 0), ("mytopic", 1), ("mytopic", 2)]
subscribe(c, parlist)
timeout_ms = 1000
for i=1:10
    msg = poll(String, String, c, timeout_ms)
    println(msg)
end
```