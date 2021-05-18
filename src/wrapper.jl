## wrapper for librdkafka C API, see:
## https://github.com/edenhill/librdkafka/blob/master/src/rdkafka.h

function rd_kafka_version()
    ccall((:rd_kafka_version, RDKafka.librdkafka), Cint, ())
end

## rd_kafka_conf_t

function kafka_conf_new()
    return ccall((:rd_kafka_conf_new, librdkafka), Ptr{Cvoid}, ())
end

function kafka_conf_destroy(conf::Ptr{Cvoid})
    ccall((:rd_kafka_conf_destroy, librdkafka), Cvoid, (Ptr{Cvoid},), conf)
end


function kafka_conf_set(conf::Ptr{Cvoid}, key::String, val::String)
    err_str = zeros(UInt8, 512)
    return ccall((:rd_kafka_conf_set, librdkafka), Cvoid,
                 (Ptr{Cvoid}, Cstring, Cstring, Ptr{UInt8}, Csize_t),
                 conf, key, val, pointer(err_str), sizeof(err_str))
end


function kafka_conf_get(conf::Ptr{Cvoid}, key::String)
    dest = zeros(UInt8, 512)
    sz_ref = Ref{Csize_t}(0)
    ccall((:rd_kafka_conf_get, librdkafka), Cvoid,
          (Ptr{Cvoid}, Cstring, Ptr{UInt8}, Ptr{Csize_t}),
          conf, key, pointer(dest), sz_ref)
    return unsafe_string(pointer(dest))
end


function kafka_conf_set_error_cb(conf::Ptr{Cvoid}, c_fn::Ptr{Cvoid})
    ccall((:rd_kafka_conf_set_error_cb, librdkafka), Cvoid,
          (Ptr{Cvoid}, Ptr{Cvoid}), conf, c_fn)
end

function kafka_conf_set_dr_msg_cb(conf::Ptr{Cvoid}, c_fn::Ptr{Cvoid})
    ccall((:rd_kafka_conf_set_dr_msg_cb, librdkafka), Cvoid,
          (Ptr{Cvoid}, Ptr{Cvoid}), conf, c_fn)
end


## rd_kafka_t

const KAFKA_TYPE_PRODUCER = Cint(0)
const KAFKA_TYPE_CONSUMER = Cint(1)


function kafka_new(conf::Ptr{Cvoid}, kafka_type::Cint)
    err_str = zeros(UInt8, 512)
    client = ccall((:rd_kafka_new, librdkafka),
                   Ptr{Cvoid},
                   (Cint, Ptr{Cvoid}, Ptr{UInt8}, Csize_t),
                   kafka_type, conf, pointer(err_str), sizeof(err_str))
    return client
end


function kafka_destroy(rk::Ptr{Cvoid})
    ccall((:rd_kafka_destroy, librdkafka), Cvoid, (Ptr{Cvoid},), rk)
end


## rd_kafka_topic_conf_t

function kafka_topic_conf_new()
    return ccall((:rd_kafka_topic_conf_new, librdkafka), Ptr{Cvoid}, ())
end


function kafka_topic_conf_destroy(conf::Ptr{Cvoid})
    ccall((:rd_kafka_topic_conf_destroy, librdkafka), Cvoid, (Ptr{Cvoid},), conf)
end


function kafka_topic_conf_set(conf::Ptr{Cvoid}, key::String, val::String)
    err_str = Array{UInt8}(undef, 512)
    return ccall((:rd_kafka_topic_conf_set, librdkafka), Cvoid,
                 (Ptr{Cvoid}, Cstring, Cstring, Ptr{UInt8}, Csize_t),
                 conf, key, val, pointer(err_str), sizeof(err_str))
end


function kafka_topic_conf_get(conf::Ptr{Cvoid}, key::String)
    dest = Array{UInt8}(undef, 512)
    sz_ref = Ref{Csize_t}(0)
    ccall((:rd_kafka_topic_conf_get, librdkafka), Cvoid,
          (Ptr{Cvoid}, Cstring, Ptr{UInt8}, Ptr{Csize_t}),
          conf, key, pointer(dest), sz_ref)
    return unsafe_string(pointer(dest))
end


# rd_kafka_topic_t

function kafka_topic_new(rk::Ptr{Cvoid}, topic::String, topic_conf::Ptr{Cvoid})
    return ccall((:rd_kafka_topic_new, librdkafka), Ptr{Cvoid},
                 (Ptr{Cvoid}, Cstring, Ptr{Cvoid}),
                 rk, topic, topic_conf)
end


function kafka_topic_destroy(rkt::Ptr{Cvoid})
    ccall((:rd_kafka_topic_destroy, librdkafka), Cvoid, (Ptr{Cvoid},), rkt)
end


function kafka_poll(rk::Ptr{Cvoid}, timeout::Integer)
    return ccall((:rd_kafka_poll, librdkafka), Cint,
                 (Ptr{Cvoid}, Cint),
                 rk, timeout)
    
end


function produce(rkt::Ptr{Cvoid}, partition::Integer,
                 key::Vector{UInt8}, payload::Vector{UInt8})
    flags = Cint(0)
    errcode = ccall((:rd_kafka_produce, librdkafka), Cint,
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



## topic partition list

mutable struct CKafkaTopicPartition
    topic::Cstring
    partition::Cint
    offset::Clonglong
    metadata::Ptr{Cvoid}
    metadata_size::Csize_t
    opaque::Ptr{Cvoid}
    err::Cint
    _private::Ptr{Cvoid}
end
mutable struct CKafkaTopicPartitionList
    cnt::Cint
    size::Cint
    elems::Ptr{CKafkaTopicPartition}
end

function kafka_topic_partition_list_new(sz::Integer=0)
    rkparlist = ccall((:rd_kafka_topic_partition_list_new, librdkafka), Ptr{CKafkaTopicPartitionList},
                       (Cint,), sz)
    if rkparlist != Ptr{CKafkaTopicPartitionList}(0)
        return rkparlist
    end
    return nothing
end


function kafka_topic_partition_list_destroy(rkparlist::Ptr{CKafkaTopicPartitionList})
    ccall((:rd_kafka_topic_partition_list_destroy, librdkafka), Cvoid, (Ptr{CKafkaTopicPartitionList},), rkparlist)
end


function kafka_topic_partition_list_add(rkparlist::Ptr{CKafkaTopicPartitionList},
                                        topic::String, partition::Integer)
    ccall((:rd_kafka_topic_partition_list_add, librdkafka), Ptr{CKafkaTopicPartition},
          (Ptr{CKafkaTopicPartitionList}, Cstring, Int32,), rkparlist, topic, partition)
end


## partition assignment

function kafka_assignment(rk::Ptr{Cvoid}, rkparlist::Ptr{CKafkaTopicPartitionList})
    errcode = ccall((:rd_kafka_assignment, librdkafka), Cint,
                    (Ptr{Cvoid}, Ref{Ptr{CKafkaTopicPartitionList}}), rk, rkparlist)
    if errcode != 0
        error("Assignment retrieval failed with error $errcode")
    end
end
    

## subscribe

function kafka_subscribe(rk::Ptr{Cvoid}, rkparlist::Ptr{CKafkaTopicPartitionList})
    errcode = ccall((:rd_kafka_subscribe, librdkafka), Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}), rk, rkparlist)
    if errcode != 0
        error("Subscription failed with error $errcode")
    end
end


## seek

function kafka_offsets_for_times(rk::Ptr{Cvoid}, rkparlist::Ptr{CKafkaTopicPartitionList}, timeout::Integer)
    errcode = ccall((:rd_kafka_offsets_for_times, librdkafka), Cint,
                    (Ptr{Cvoid}, Ptr{CKafkaTopicPartitionList}, Cint), rk, rkparlist, timeout)
    if errcode != 0
        error("kafka_offsets_for_times failed with error $errcode")
    end
end

function kafka_seek(rkt::Ptr{Cvoid}, partition::Int32, offset::Int64, timeout::Int=1000)
    errcode = ccall((:rd_kafka_seek, librdkafka), Cint,
                    (Ptr{Cvoid}, Cint, Clonglong, Cint), 
                    rkt, partition, offset, timeout)
    if errcode != 0
        error("kafka_seek failed with error $errcode")
    end
end

function kafka_assign(rk::Ptr{Cvoid}, rkparlist::Ptr{CKafkaTopicPartitionList})
    errcode = ccall((:rd_kafka_assign, librdkafka), Cint,
                    (Ptr{Cvoid}, Ptr{CKafkaTopicPartitionList}), 
                    rk, rkparlist)
    if errcode != 0
        error("kafka_assign failed with error $errcode")
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
    msg_ptr = ccall((:rd_kafka_consumer_poll, librdkafka), Ptr{CKafkaMessage},
                    (Ptr{Cvoid}, Cint), rk, timeout)
    if msg_ptr != Ptr{CKafkaMessage}(0)
        return msg_ptr
    else
        return nothing
    end
        
end


function kafka_message_destroy(msg_ptr::Ptr{CKafkaMessage})
    ccall((:rd_kafka_message_destroy, librdkafka), Cvoid, (Ptr{Cvoid},), msg_ptr)
end
5