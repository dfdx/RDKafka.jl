## consumer

mutable struct PartitionList
    rkparlist::Ptr{CKafkaTopicPartitionList}
end

function PartitionList()
    ptr = kafka_topic_partition_list_new()
    parlist = PartitionList(ptr)
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

function offsets_for_timestamp(c::KafkaConsumer, timestamp::Int64, timeout::Int=1000)
    rkparlist = c.parlist.rkparlist
    kafka_assignment(c.client.rk, rkparlist)
    tpl = unsafe_load(rkparlist)::CKafkaTopicPartitionList
    for i in 1:tpl.cnt
        e = unsafe_load(tpl.elems, i)
        e.offset = timestamp
        unsafe_store!(tpl.elems, e, i)
    end
    kafka_offsets_for_times(c.client.rk, rkparlist, timeout)
end

function seek(c::KafkaConsumer, timestamp::Int64, timeout::Int=1000)
    offsets_for_timestamp(c, timestamp, timeout)
    rkparlist = c.parlist.rkparlist
    kafka_assign(c.client.rk, rkparlist)
    tpl = unsafe_load(rkparlist)::CKafkaTopicPartitionList
    for i in 1:tpl.cnt
        e = unsafe_load(tpl.elems, i)
        topic = unsafe_string(e.topic)
        kt = KafkaTopic(c.client, topic, Dict())
        kafka_seek(kt.rkt, e.partition, e.offset, timeout)
    end
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

function Base.close(c::KafkaConsumer)
    kafka_topic_partition_list_destroy(c.parlist.rkparlist)
    kafka_consumer_close(c.client.rk)
    kafka_destroy(c.client.rk)
end

poll(c::KafkaConsumer, timeout::Int=1000) = poll(Vector{UInt8}, Vector{UInt8}, c, timeout)
