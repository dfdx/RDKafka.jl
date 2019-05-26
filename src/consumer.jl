## consumer

mutable struct PartitionList
    rkparlist::Ptr{Cvoid}
end

function PartitionList()
    ptr = kafka_topic_partition_list_new()
    parlist = PartitionList(ptr)
    finalizer(parlist -> kafka_topic_partition_list_destroy(ptr), parlist)
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
