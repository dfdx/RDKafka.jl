# RDKafka

Julia wrapper for [librdkafka](https://github.com/edenhill/librdkafka).

## Build

```julia
using Pkg
Pkg.add("RDKafka")
```

Prebuilt binaries of the `librdkafka` native library is downloaded. The binaries are available for all supported Julia platforms. 

## Usage

### Start Kafka server

If you don't have one already started, download Kafka server and run it according to the official [QuickStart Guide](https://kafka.apache.org/quickstart). Here's a short version of that guide:

`cd` to the kafka folder and in run the following commands in 2 different terminals:

```
# start ZooKeeper server
bin/zookeeper-server-start.sh config/zookeeper.properties
# start Kafka broker
bin/kafka-server-start.sh config/server.properties
```

In yet another terminal create a topic:

```
# create topic
bin/kafka-topics.sh --create --topic quickstart-events --bootstrap-server localhost:9092
# describe it
bin/kafka-topics.sh --describe --topic quickstart-events --bootstrap-server localhost:9092
```

### Produce and consume some messages

Now in Julia console start polling using `KafkaConsumer`:

```julia
using RDKafka

c = KafkaConsumer("localhost:9092", "my-consumer-group")
parlist = [("quickstart-events", 0)]
subscribe(c, parlist)
timeout_ms = 1000
while true
    msg = poll(String, String, c, timeout_ms)
    @show(msg)
end
```

And produce a few messages using `KafkaProducer`

```julia
using RDKafka
import RDKafka.produce

p = KafkaProducer("localhost:9092")
partition = 0
produce(p, "quickstart-events", partition, "message key", "message payload")
```

In the consumer window you should see something like:

```
msg = nothing
msg = Message(message key: message payload)
msg = nothing
msg = nothing
```
where `nothing` means that there were no new messages in that polling interval while `Message(...)` is actual message we sent from producer.

### Configuration

`librdkafka` is highly customizable, see [CONFIGURATION.md](https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md) for the list of supported properties. To set a particular property, pass a `conf` object to `KafkaProducer` or `KafkaConsumer`, e.g.:

```julia
conf = Dict("socket.timeout.ms" => 300000)
p = KafkaProducer("localhost:9092", conf)
```

### Error handling

Add the `err_cb` argument to either KafkaConsumer or KafkaProducer.

```
c = KafkaConsumer("localhost:9092", "my-consumer-group", err_cb=(err::Int, reason::String) -> throw(error(reason)))
```

### Delivery reports

Add the `dr_cb` argument to a KafkaProducer.

```
p = KafkaProducer("localhost:9092", dr_cb=msg -> if msg.err != 0 throw(error("Delivery failed") end))
```

### Seeking

```
c = KafkaConsumer("localhost:9092", "my-consumer-group")
RDKafka.seek(c, timestamp_ms, timeout_ms)
```
