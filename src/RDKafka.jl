module RDKafka
using librdkafka_jll

export KafkaProducer,
    KafkaConsumer,
    KafkaClient,
    # produce,
    subscribe,
    poll

include("core.jl")

end # module
