## wrapper for librdkafka C API, see:
## https://github.com/edenhill/librdkafka/blob/master/src/rdkafka.h

## rd_kafka_conf_t

function kafka_conf_new()
    return ccall((:rd_kafka_conf_new, LIBRDKAFKA), Ptr{Void}, ())
end

function kafka_conf_destroy(conf::Ptr{Void})
    ccall((:rd_kafka_conf_destroy, LIBRDKAFKA), Void, (Ptr{Void},), conf)
end


function kafka_conf_set(conf::Ptr{Void}, key::String, val::String)
    err_str = Array{UInt8}(512)
    return ccall((:rd_kafka_conf_set, LIBRDKAFKA), Void,
                 (Ptr{Void}, Cstring, Cstring, Ptr{UInt8}, Csize_t),
                 conf, key, val, pointer(err_str), sizeof(err_str))
end


function kafka_conf_get(conf::Ptr{Void}, key::String)
    dest = Array{UInt8}(512)
    sz_ref = Ref{Csize_t}(0)
    ccall((:rd_kafka_conf_get, LIBRDKAFKA), Void,
          (Ptr{Void}, Cstring, Ptr{UInt8}, Ptr{Csize_t}),
          conf, key, pointer(dest), sz_ref)
    return unsafe_string(pointer(dest))
end


## rd_kafka_t

const KAFKA_TYPE_PRODUCER = Cint(0)
const KAFKA_TYPE_CONSUMER = Cint(1)


function kafka_new(conf::Ptr{Void}, kafka_type::Cint)
    err_str = Array{UInt8}(512)
    client = ccall((:rd_kafka_new, LIBRDKAFKA),
                   Ptr{Void},
                   (Cint, Ptr{Void}, Ptr{UInt8}, Csize_t),
                   kafka_type, conf, pointer(err_str), sizeof(err_str))
    return client
end


function kafka_destroy(rk::Ptr{Void})
    ccall((:rd_kafka_destroy, LIBRDKAFKA), Void, (Ptr{Void},), rk)
end


## rd_kafka_topic_conf_t

function kafka_topic_conf_new()
    return ccall((:rd_kafka_topic_conf_new, LIBRDKAFKA), Ptr{Void}, ())
end


function kafka_topic_conf_destroy(conf::Ptr{Void})
    ccall((:rd_kafka_topic_conf_destroy, LIBRDKAFKA), Void, (Ptr{Void},), conf)
end


function kafka_topic_conf_set(conf::Ptr{Void}, key::String, val::String)
    err_str = Array{UInt8}(512)
    return ccall((:rd_kafka_topic_conf_set, LIBRDKAFKA), Void,
                 (Ptr{Void}, Cstring, Cstring, Ptr{UInt8}, Csize_t),
                 conf, key, val, pointer(err_str), sizeof(err_str))
end


function kafka_topic_conf_get(conf::Ptr{Void}, key::String)
    dest = Array{UInt8}(512)
    sz_ref = Ref{Csize_t}(0)
    ccall((:rd_kafka_topic_conf_get, LIBRDKAFKA), Void,
          (Ptr{Void}, Cstring, Ptr{UInt8}, Ptr{Csize_t}),
          conf, key, pointer(dest), sz_ref)
    return unsafe_string(pointer(dest))
end


# rd_kafka_topic_t

function kafka_topic_new(rk::Ptr{Void}, topic::String, topic_conf::Ptr{Void})
    return ccall((:rd_kafka_topic_new, LIBRDKAFKA), Ptr{Void},
                 (Ptr{Void}, Cstring, Ptr{Void}),
                 rk, topic, topic_conf)
end


function kafka_topic_destroy(rkt::Ptr{Void})
    ccall((:rd_kafka_topic_destroy, LIBRDKAFKA), Void, (Ptr{Void},), rkt)
end

## TODO: rd_kafka_poll - should be called, but I'm not sure yet when

function kafka_poll(rk::Ptr{Void}, timeout::Integer)
    return ccall((:rd_kafka_poll, LIBRDKAFKA), Cint,
                 (Ptr{Void}, Cint),
                 rk, timeout)
    
end


# int rd_kafka_produce(rd_kafka_topic_t *rkt, int32_t partition,
# 		      int msgflags,
# 		      void *payload, size_t len,
# 		      const void *key, size_t keylen,
# 		      void *msg_opaque);



function produce(rkt::Ptr{Void}, partition::Integer,
                 key::Vector{UInt8}, payload::Vector{UInt8})
    flags = Cint(0)
    errcode = ccall((:rd_kafka_produce, LIBRDKAFKA), Cint,
                    (Ptr{Void}, Int32, Cint,
                     Ptr{Void}, Csize_t,
                     Ptr{Void}, Csize_t,
                     Ptr{Void}),
                    rkt, Int32(partition), flags,
                    pointer(payload), length(payload),
                    pointer(key), length(key),
                    C_NULL)
    if errcode != 0
        error("Produce request failed with error code: $errcode")
    end
end



## topic list

function kafka_topic_partition_list_new(sz::Integer=0)
    rkparlist = ccall((:rd_kafka_topic_partition_list_new, LIBRDKAFKA), Ptr{Void},
                       (Cint,), sz)
    return rkparlist
end


function kafka_topic_partition_list_destroy(rkparlist::Ptr{Void})
    ccall((:rd_kafka_topic_partition_list_destroy, LIBRDKAFKA), Void, (Ptr{Void},), rkparlist)
end


function kafka_topic_partition_list_add(rkparlist::Ptr{Void},
                                        topic::String, partition::Integer)
    ccall((:rd_kafka_topic_partition_list_add, LIBRDKAFKA), Ptr{Void},
          (Ptr{Void}, Cstring, Int32,), rkparlist, topic, partition)
end


## partition assignment

function kafka_assignment(rk::Ptr{Void}, rkparlist::Ptr{Void})
    errcode = ccall((:rd_kafka_assignment, LIBRDKAFKA), Cint,
                    (Ptr{Void}, Ptr{Void}), rk, rkparlist)
    if errcode != 0
        error("Assignment retrieval failed with error $errcode")
    end
end
    

## subscribe

function kafka_subscribe(rk::Ptr{Void}, rkparlist::Ptr{Void})
    errcode = ccall((:rd_kafka_subscribe, LIBRDKAFKA), Cint,
                    (Ptr{Void}, Ptr{Void}), rk, rkparlist)
    if errcode != 0
        error("Subscription failed with error $errcode")
    end
end


struct CKafkaMessage
    err::Cint
    rkt::Ptr{Void}
    partition::Int32
    payload::Ptr{UInt8}
    len::Csize_t
    key::Ptr{UInt8}
    key_len::Csize_t
    offset::Int64
    _private::Ptr{Void}
end


function kafka_consumer_poll(rk::Ptr{Void}, timeout::Integer)
    msg_ptr = ccall((:rd_kafka_consumer_poll, LIBRDKAFKA), Ptr{CKafkaMessage},
                    (Ptr{Void}, Cint), rk, timeout)
    if msg_ptr != Ptr{CKafkaMessage}(0)
        return msg_ptr
    else
        return nothing
    end
        
end


function kafka_message_destroy(msg_ptr::Ptr{CKafkaMessage})
    ccall((:rd_kafka_message_destroy, LIBRDKAFKA), Void, (Ptr{Void},), msg_ptr)
end
