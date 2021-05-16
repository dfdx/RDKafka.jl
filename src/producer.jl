## KafkaProducer

mutable struct KafkaProducer
    client::KafkaClient
    topics::Dict{String, KafkaTopic}
end


function KafkaProducer(conf::Dict; dr_cb=nothing, err_cb=nothing)
    kc = KafkaClient(KAFKA_TYPE_PRODUCER, conf; dr_cb=dr_cb, err_cb=err_cb)
    if dr_cb != nothing || err_cb != nothing
        @async begin
            while true
                kafka_poll(kc.rk, 1000)
                sleep(1)
            end
        end
    end
    return KafkaProducer(kc, Dict())
end


function KafkaProducer(bootstrap_servers::String, conf::Dict=Dict(); dr_cb=nothing, err_cb=nothing)
    conf["bootstrap.servers"] = bootstrap_servers
    return KafkaProducer(conf; dr_cb=dr_cb, err_cb=err_cb)
end

function Base.show(io::IO, p::KafkaProducer)
    bootstrap_servers = p.client.conf["bootstrap.servers"]
    print(io, "KafkaProducer($bootstrap_servers)")
end


function produce(kt::KafkaTopic, partition::Integer, key, payload)
    # produce(kt.rkt, partition, convert(Vector{UInt8}, key), convert(Vector{UInt8}, payload))
    produce(kt.rkt, partition, Vector{UInt8}(key), Vector{UInt8}(payload))
end


function produce(p::KafkaProducer, topic::String, partition::Integer, key, payload)
    if !haskey(p.topics, topic)
        p.topics[topic] = KafkaTopic(p.client, topic, Dict())
    end
    produce(p.topics[topic], partition, key, payload)
end


function produce(p::KafkaProducer, topic::String, key, payload)
    partition_unassigned = -1
    produce(p, topic, partition_unassigned, key, payload)
end
