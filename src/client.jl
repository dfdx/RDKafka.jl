################################################################################
##                                 CALLBACKS                                  ##
################################################################################

# librdkafka provides several callback (CB) functions such as delivery report CB and error CB
# we defne fixed @cfunction callbacks to pass them during compilation
# these @cfunction's then call corresponding Julia functions from XXX_CALLBACKS dictionaries
const DELIVERY_CALLBACKS = Dict{Ptr{Cvoid}, Function}()
function delivery_callback(rk::Ptr{Cvoid}, rkmessage::Ptr{CKafkaMessage}, opaque::Ptr{Cvoid})::Cvoid
    msg = Message(unsafe_load(rkmessage))
    if haskey(DELIVERY_CALLBACKS, rk)
        cb = DELIVERY_CALLBACKS[rk]
        cb(msg)
    end
end


# error callbacks are called with the arguments (err::Int, reason::String)
function error_callback(rk::Ptr{Cvoid}, err::Cint, reason::Ptr{Cchar}, opaque::Ptr{Cvoid})::Cvoid
    reason = unsafe_string(reason)
    if haskey(ERROR_CALLBACKS, rk)
        cb = ERROR_CALLBACKS[rk]
        cb(err, reason)
    end
end
const ERROR_CALLBACKS = Dict{Ptr, Function}()


mutable struct KafkaClient
    conf::Dict{Any, Any}
    typ::Cint
    rk::Ptr{Cvoid}
end


function KafkaClient(typ::Integer, conf::Dict=Dict(); dr_cb=nothing, err_cb=nothing)
    c_conf = kafka_conf_new()
    for (k, v) in conf
        kafka_conf_set(c_conf, string(k), string(v))
    end
    # set callbacks in config before creating rk
    if dr_cb != nothing
        kafka_conf_set_dr_msg_cb(c_conf, @cfunction(delivery_callback, Cvoid, (Ptr{Cvoid}, Ptr{CKafkaMessage}, Ptr{Cvoid})))
    end
    if err_cb != nothing
        kafka_conf_set_error_cb(c_conf, @cfunction(error_callback, Cvoid, (Ptr{Cvoid}, Cint, Ptr{Cchar}, Ptr{Cvoid})))
    end
    rk = kafka_new(c_conf, Cint(typ))
    client = KafkaClient(conf, typ, rk)
    polling = dr_cb != nothing || err_cb != nothing
    # seems like `kafka_destroy` also destroys its config, so we don't attempt it twice
    finalizer(client -> begin 
        polling = false
        kafka_destroy(rk)
    end, client)
    if dr_cb != nothing
        # set Julia callback after rk is created
        DELIVERY_CALLBACKS[rk] = dr_cb
    end
    if err_cb != nothing
        ERROR_CALLBACKS[rk] = err_cb
    end
    @async while polling
        kafka_poll(rk, 0)
        sleep(1)
    end
    return client
end


Base.show(io::IO, kc::KafkaClient) = print(io, "KafkaClient($(kc.typ))")


mutable struct KafkaTopic
    conf::Dict{Any, Any}
    topic::String
    rkt::Ptr{Cvoid}
end

function KafkaTopic(kc::KafkaClient, topic::String, conf::Dict=Dict())
    c_conf = kafka_topic_conf_new()
    for (k, v) in conf
        kafka_topic_conf_set(c_conf, string(k), string(v))
    end
    rkt = kafka_topic_new(kc.rk, topic, c_conf)
    topic = KafkaTopic(conf, topic, rkt)
    finalizer(topic -> (kafka_topic_destroy(rkt)), topic)
    return topic
end

Base.show(io::IO, kt::KafkaTopic) = print(io, "KafkaTopic($(kt.topic))")


struct Message{K,P}
    err::Int
    topic::KafkaTopic
    partition::Int32
    key::Union{K, Cvoid}
    payload::Union{P, Cvoid}
    offset::Int64
end

Base.convert(::Type{String}, data::Vector{UInt8}) = String(data)

function Message{K,P}(c_msg::CKafkaMessage) where {K,P}
    topic = KafkaTopic(Dict(), "<unkown>", c_msg.rkt)
    if c_msg.err == 0
        key = _frombytestream(K, unsafe_load_array(c_msg.key, c_msg.key_len))
        payload = _frombytestream(P, unsafe_load_array(c_msg.payload, c_msg.len))
        return Message(Int(c_msg.err), topic, c_msg.partition, key, payload, c_msg.offset)
    else
        return Message{K,P}(Int(c_msg.err), topic, c_msg.partition, nothing, nothing, c_msg.offset)
    end
end
Message(c_msg::CKafkaMessage) = Message{Vector{UInt8}, Vector{UInt8}}(c_msg)

Base.show(io::IO, msg::Message) = print(io, "Message($(msg.key): $(msg.payload))")
