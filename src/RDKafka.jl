module RDKafka

export KafkaProducer,
    KafkaConsumer,
    KafkaClient,
    # produce,
    subscribe,
    poll

include("core.jl")

end # module
