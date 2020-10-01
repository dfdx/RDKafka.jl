# RDKafka

Julia wrapper for [librdkafka](https://github.com/edenhill/librdkafka).

## Build

```julia
using Pkg
Pkg.add("RDKafka")
```

Prebuilt binaries of the `librdkafka` native library is downloaded. The binaries are available for all supported Julia platforms. 

## Usage


Producer:

```julia
p = KafkaProducer("localhost:9092")
partition = 0
produce(p, "mytopic", partition, "message key", "message payload")
```

Consumer:
```julia
c = KafkaConsumer("localhost:9092", "my-consumer-group")
parlist = [("mytopic", 0), ("mytopic", 1), ("mytopic", 2)]
subscribe(c, parlist)
timeout_ms = 1000
for i=1:10
    msg = poll(String, String, c, timeout_ms)
    show(msg)
end
```
