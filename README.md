# RDKafka

Julia wrapper for [librdkafka](https://github.com/edenhill/librdkafka).

## Build

Currently this package builds only on Linux and requires `git` and `make` to
be available in command line.

```julia
using Pkg
Pkg.clone("https://github.com/dfdx/RDKafka.jl")
Pkg.build("RDKafka")
```


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
    println(msg)
end
```
