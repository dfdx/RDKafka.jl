
struct KafkaClient
    conf::Dict{Any, Any}
    typ::Cint
    rk::Ptr{Void}
end


function KafkaClient(typ::Integer, conf::Dict=Dict())
    c_conf = kafka_conf_new()
    for (k, v) in conf
        kafka_conf_set(c_conf, string(k), string(v))
    end
    rk = kafka_new(c_conf, Cint(typ))
    return KafkaClient(conf, typ, rk)
end


# KafkaProducer(conf::Dict{String, String}) = KafkaClient(conf, KAFKA_TYPE_PRODUCER)
# KafkaConsumer(conf::Dict{String, String}) = KafkaClient(conf, KAFKA_TYPE_CONSUMER)

Base.show(io::IO, kc::KafkaClient) = print(io, "KafkaClient($(kc.typ))")



struct KafkaTopic
    conf::Dict{Any, Any}
    topic::String
    rkt::Ptr{Void}
end


function KafkaTopic(kc::KafkaClient, topic::String, conf::Dict=Dict())
    c_conf = kafka_topic_conf_new()
    for (k, v) in conf
        kafka_topic_conf_set(c_conf, string(k), string(v))
    end
    rkt = kafka_topic_new(kc.rk, "mytopic", c_conf)
    return KafkaTopic(conf, topic, rkt)
end


Base.show(io::IO, kt::KafkaTopic) = print(io, "KafkaTopic($(kt.topic))")



function produce(kt::KafkaTopic, partition::Integer, key, payload)
    produce(kt.rkt, partition, convert(Vector{UInt8}, key), convert(Vector{UInt8}, payload))
end



function main()
    conf = kafka_conf_new()
    kafka_conf_set(conf, "compression.codec", "snappy")
    # key = "compression.codec"
    rk = kafka_new(conf, Cint(0))    
    topic_conf = kafka_topic_conf_new()
    topic = kafka_topic_new(rk, "mytopic", topic_conf)


    kc = KafkaClient(KAFKA_TYPE_PRODUCER, Dict{String,String}())
    kt = KafkaTopic(kc, "mytopic")
    
end
