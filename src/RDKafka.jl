module RDKafka
using librdkafka_jll

export KafkaProducer,
    KafkaConsumer,
    KafkaClient,
    produce,
    subscribe,
    seek,
    poll

include("core.jl")

end # module
