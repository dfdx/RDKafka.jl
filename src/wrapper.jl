## wrapper for librdkafka C API, see:
## https://github.com/edenhill/librdkafka/blob/master/src/rdkafka.h

## rd_kafka_conf_t

function kafka_conf_new()
    return ccall((:rd_kafka_conf_new, LIBRDKAFKA), Ptr{Cvoid}, ())
end

function kafka_conf_destroy(conf::Ptr{Cvoid})
    ccall((:rd_kafka_conf_destroy, LIBRDKAFKA), Cvoid, (Ptr{Cvoid},), conf)
end


function kafka_conf_set(conf::Ptr{Cvoid}, key::String, val::String)
    err_str = Array{UInt8}(undef, 512)
    return ccall((:rd_kafka_conf_set, LIBRDKAFKA), Cvoid,
                 (Ptr{Cvoid}, Cstring, Cstring, Ptr{UInt8}, Csize_t),
                 conf, key, val, pointer(err_str), sizeof(err_str))
end


function kafka_conf_get(conf::Ptr{Cvoid}, key::String)
    dest = Array{UInt8}(undef, 512)
    sz_ref = Ref{Csize_t}(0)
    ccall((:rd_kafka_conf_get, LIBRDKAFKA), Cvoid,
          (Ptr{Cvoid}, Cstring, Ptr{UInt8}, Ptr{Csize_t}),
          conf, key, pointer(dest), sz_ref)
    return unsafe_string(pointer(dest))
end


## rd_kafka_t

const KAFKA_TYPE_PRODUCER = Cint(0)
const KAFKA_TYPE_CONSUMER = Cint(1)


function kafka_new(conf::Ptr{Cvoid}, kafka_type::Cint)
    err_str = Array{UInt8}(undef, 512)
    client = ccall((:rd_kafka_new, LIBRDKAFKA),
                   Ptr{Cvoid},
                   (Cint, Ptr{Cvoid}, Ptr{UInt8}, Csize_t),
                   kafka_type, conf, pointer(err_str), sizeof(err_str))
    return client
end


function kafka_destroy(rk::Ptr{Cvoid})
    ccall((:rd_kafka_destroy, LIBRDKAFKA), Cvoid, (Ptr{Cvoid},), rk)
end


## rd_kafka_topic_conf_t

function kafka_topic_conf_new()
    return ccall((:rd_kafka_topic_conf_new, LIBRDKAFKA), Ptr{Cvoid}, ())
end


function kafka_topic_conf_destroy(conf::Ptr{Cvoid})
    ccall((:rd_kafka_topic_conf_destroy, LIBRDKAFKA), Cvoid, (Ptr{Cvoid},), conf)
end


function kafka_topic_conf_set(conf::Ptr{Cvoid}, key::String, val::String)
    err_str = Array{UInt8}(undef, 512)
    return ccall((:rd_kafka_topic_conf_set, LIBRDKAFKA), Cvoid,
                 (Ptr{Cvoid}, Cstring, Cstring, Ptr{UInt8}, Csize_t),
                 conf, key, val, pointer(err_str), sizeof(err_str))
end


function kafka_topic_conf_get(conf::Ptr{Cvoid}, key::String)
    dest = Array{UInt8}(undef, 512)
    sz_ref = Ref{Csize_t}(0)
    ccall((:rd_kafka_topic_conf_get, LIBRDKAFKA), Cvoid,
          (Ptr{Cvoid}, Cstring, Ptr{UInt8}, Ptr{Csize_t}),
          conf, key, pointer(dest), sz_ref)
    return unsafe_string(pointer(dest))
end


# rd_kafka_topic_t

function kafka_topic_new(rk::Ptr{Cvoid}, topic::String, topic_conf::Ptr{Cvoid})
    return ccall((:rd_kafka_topic_new, LIBRDKAFKA), Ptr{Cvoid},
                 (Ptr{Cvoid}, Cstring, Ptr{Cvoid}),
                 rk, topic, topic_conf)
end


function kafka_topic_destroy(rkt::Ptr{Cvoid})
    ccall((:rd_kafka_topic_destroy, LIBRDKAFKA), Cvoid, (Ptr{Cvoid},), rkt)
end


function kafka_poll(rk::Ptr{Cvoid}, timeout::Integer)
    return ccall((:rd_kafka_poll, LIBRDKAFKA), Cint,
                 (Ptr{Cvoid}, Cint),
                 rk, timeout)
    
end


# int rd_kafka_produce(rd_kafka_topic_t *rkt, int32_t partition,
# 		      int msgflags,
# 		      void *payload, size_t len,
# 		      const void *key, size_t keylen,
# 		      void *msg_opaque);



function produce(rkt::Ptr{Cvoid}, partition::Integer,
                 key::Vector{UInt8}, payload::Vector{UInt8})
    flags = Cint(0)
    errcode = ccall((:rd_kafka_produce, LIBRDKAFKA), Cint,
                    (Ptr{Cvoid}, Int32, Cint,
                     Ptr{Cvoid}, Csize_t,
                     Ptr{Cvoid}, Csize_t,
                     Ptr{Cvoid}),
                    rkt, Int32(partition), flags,
                    pointer(payload), length(payload),
                    pointer(key), length(key),
                    C_NULL)   

    if errcode != 0
        #error("Produce request failed with error code (unix): $errcode")
        ## errno is c global var
	errnr = unsafe_load(cglobal(:errno, Int32))
        errmsg = unsafe_string(ccall(:strerror, Cstring, (Int32,), errnr))
        error("Produce request failed with error code: $errmsg")  
    end
end



## topic list

function kafka_topic_partition_list_new(sz::Integer=0)
    rkparlist = ccall((:rd_kafka_topic_partition_list_new, LIBRDKAFKA), Ptr{Cvoid},
                       (Cint,), sz)
    return rkparlist
end


function kafka_topic_partition_list_destroy(rkparlist::Ptr{Cvoid})
    ccall((:rd_kafka_topic_partition_list_destroy, LIBRDKAFKA), Cvoid, (Ptr{Cvoid},), rkparlist)
end


function kafka_topic_partition_list_add(rkparlist::Ptr{Cvoid},
                                        topic::String, partition::Integer)
    ccall((:rd_kafka_topic_partition_list_add, LIBRDKAFKA), Ptr{Cvoid},
          (Ptr{Cvoid}, Cstring, Int32,), rkparlist, topic, partition)
end


## partition assignment

function kafka_assignment(rk::Ptr{Cvoid}, rkparlist::Ptr{Cvoid})
    errcode = ccall((:rd_kafka_assignment, LIBRDKAFKA), Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}), rk, rkparlist)
    if errcode != 0
        error("Assignment retrieval failed with error $errcode")
    end
end
    

## subscribe

function kafka_subscribe(rk::Ptr{Cvoid}, rkparlist::Ptr{Cvoid})
    errcode = ccall((:rd_kafka_subscribe, LIBRDKAFKA), Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}), rk, rkparlist)
    if errcode != 0
        error("Subscription failed with error $errcode")
    end
end


struct CKafkaMessage
    err::Cint
    rkt::Ptr{Cvoid}
    partition::Int32
    payload::Ptr{UInt8}
    len::Csize_t
    key::Ptr{UInt8}
    key_len::Csize_t
    offset::Int64
    _private::Ptr{Cvoid}
end


function kafka_consumer_poll(rk::Ptr{Cvoid}, timeout::Integer)
    msg_ptr = ccall((:rd_kafka_consumer_poll, LIBRDKAFKA), Ptr{CKafkaMessage},
                    (Ptr{Cvoid}, Cint), rk, timeout)
    if msg_ptr != Ptr{CKafkaMessage}(0)
        return msg_ptr
    else
        return nothing
    end
        
end


function kafka_message_destroy(msg_ptr::Ptr{CKafkaMessage})
    ccall((:rd_kafka_message_destroy, LIBRDKAFKA), Cvoid, (Ptr{Cvoid},), msg_ptr)
end
