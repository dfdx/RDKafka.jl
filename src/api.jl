
# TODO: add finalizers for all disposable objects
# TODO: ensure all require _poll methods are invoked in fixed intervals

mutable struct KafkaClient
    conf::Dict{Any, Any}
    typ::Cint
    rk::Ptr{Void}
end


# # TODO: save task and stop it in finalizer
# @async begin
#     while true
#         println("calling kafka_poll")
#         kafka_poll(rk, 1000)
#     end
# end


function KafkaClient(typ::Integer, conf::Dict=Dict())
    c_conf = kafka_conf_new()
    for (k, v) in conf
        kafka_conf_set(c_conf, string(k), string(v))
    end
    rk = kafka_new(c_conf, Cint(typ))
    client = KafkaClient(conf, typ, rk)
    # seems like `kafka_destroy` also destroys its config, so we don't attempt it twice
    finalizer(client, client -> kafka_destroy(rk))
    return client
end


Base.show(io::IO, kc::KafkaClient) = print(io, "KafkaClient($(kc.typ))")


mutable struct KafkaTopic
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
    topic = KafkaTopic(conf, topic, rkt)
    finalizer(topic, topic -> (kafka_topic_destroy(rkt)))
    return topic
end


Base.show(io::IO, kt::KafkaTopic) = print(io, "KafkaTopic($(kt.topic))")


## KafkaProducer

mutable struct KafkaProducer
    client::KafkaClient
    topics::Dict{String, KafkaTopic}
end


function KafkaProducer(conf::Dict)
    kc = KafkaClient(KAFKA_TYPE_PRODUCER, conf)
    return KafkaProducer(kc, Dict())
end


function KafkaProducer(bootstrap_servers::String, conf::Dict=Dict())
    conf["bootstrap.servers"] = bootstrap_servers
    return KafkaProducer(conf)
end

function Base.show(io::IO, p::KafkaProducer)
    bootstrap_servers = p.client.conf["bootstrap.servers"]
    print(io, "KafkaProducer($bootstrap_servers)")
end


function produce(kt::KafkaTopic, partition::Integer, key, payload)
    produce(kt.rkt, partition, convert(Vector{UInt8}, key), convert(Vector{UInt8}, payload))
end


function produce(p::KafkaProducer, topic::String, partition::Integer, key, payload)
    if !haskey(p.topics, topic)
        p.topics[topic] = KafkaTopic(p.client, topic, Dict())
    end
    produce(p.topics[topic], partition, key, payload)
end


## consumer

struct Message{K,P}
    err::Int
    topic::KafkaTopic
    partition::Int32
    key::Union{K, Void}
    payload::Union{P, Void}
    offset::Int64
end


function Message{K,P}(c_msg::CKafkaMessage) where {K,P}
    topic = KafkaTopic(Dict(), "<unkown>", c_msg.rkt)
    if c_msg.err == 0
        key = convert(K, unsafe_load_array(c_msg.key, c_msg.key_len))
        payload = convert(P, unsafe_load_array(c_msg.payload, c_msg.len))
        return Message(Int(c_msg.err), topic, c_msg.partition, key, payload, c_msg.offset)
    else
        return Message{K,P}(Int(c_msg.err), topic, c_msg.partition, nothing, nothing, c_msg.offset)
    end
end

Base.show(io::IO, msg::Message) = print(io, "Message($(msg.key): $(msg.payload))")


mutable struct PartitionList
    rkparlist::Ptr{Void}
end

function PartitionList()
    ptr = kafka_topic_partition_list_new()
    parlist = PartitionList(ptr)
    finalizer(parlist, parlist -> kafka_topic_partition_list_destroy(ptr))
    return parlist
end


mutable struct KafkaConsumer
    client::KafkaClient
    parlist::PartitionList
end


function KafkaConsumer(conf::Dict)
    @assert haskey(conf, "bootstrap.servers") "`bootstrap.servers` should be specified in conf"
    @assert haskey(conf, "group.id") "`group.id` should be specified in conf"
    client = KafkaClient(KAFKA_TYPE_CONSUMER, conf)
    parlist = PartitionList()
    return KafkaConsumer(client, parlist)
end


function KafkaConsumer(bootstrap_servers::String, group_id::String, conf::Dict=Dict())
    conf["bootstrap.servers"] = bootstrap_servers
    conf["group.id"] = group_id
    return KafkaConsumer(conf)
end


function Base.show(io::IO, c::KafkaConsumer)
    group_id = c.client.conf["group.id"]
    bootstrap_servers = c.client.conf["bootstrap.servers"]
    print(io, "KafkaConsumer($group_id @ $bootstrap_servers)")
end


function subscribe(c::KafkaConsumer, topic_partitions::Vector{Tuple{String, Int}})
    rkparlist = c.parlist.rkparlist
    for (topic, partition) in topic_partitions
        kafka_topic_partition_list_add(rkparlist, topic, partition)
    end
    kafka_subscribe(c.client.rk, rkparlist)
end


function poll(::Type{K}, ::Type{P}, c::KafkaConsumer, timeout::Int=1000) where {K,P}
    c_msg_ptr = kafka_consumer_poll(c.client.rk, timeout)
    if c_msg_ptr != nothing
        c_msg = unsafe_load(c_msg_ptr)
        msg = Message{K,P}(c_msg)
        kafka_message_destroy(c_msg_ptr)
        return msg
    else
        return nothing
    end
end


poll(c::KafkaConsumer, timeout::Int=1000) = poll(Vector{UInt8}, Vector{UInt8}, c, timeout)
