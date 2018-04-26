#  Internal errors to rdkafka:
#  Begin internal error codes
const RD_KAFKA_RESP_ERR__BEGIN = -200
#  Received message is incorrect
const RD_KAFKA_RESP_ERR__BAD_MSG = -199
#  Bad/unknown compression
const RD_KAFKA_RESP_ERR__BAD_COMPRESSION = -198
#  Broker is going away
const RD_KAFKA_RESP_ERR__DESTROY = -197
#  Generic failure
const RD_KAFKA_RESP_ERR__FAIL = -196
#  Broker transport failure
const RD_KAFKA_RESP_ERR__TRANSPORT = -195
#  Critical system resource
const RD_KAFKA_RESP_ERR__CRIT_SYS_RESOURCE = -194
#  Failed to resolve broker
const RD_KAFKA_RESP_ERR__RESOLVE = -193
#  Produced message timed out*/
const RD_KAFKA_RESP_ERR__MSG_TIMED_OUT = -192
#  Reached the end of the topic+partition queue on
#  the broker. Not really an error.
const RD_KAFKA_RESP_ERR__PARTITION_EOF = -191
#  Permanent: Partition does not exist in cluster.
const RD_KAFKA_RESP_ERR__UNKNOWN_PARTITION = -190
#  File or filesystem error
const RD_KAFKA_RESP_ERR__FS = -189
#  Permanent: Topic does not exist in cluster.
const RD_KAFKA_RESP_ERR__UNKNOWN_TOPIC = -188
#  All broker connections are down.
const RD_KAFKA_RESP_ERR__ALL_BROKERS_DOWN = -187
#  Invalid argument, or invalid configuration
const RD_KAFKA_RESP_ERR__INVALID_ARG = -186
#  Operation timed out
const RD_KAFKA_RESP_ERR__TIMED_OUT = -185
#  Queue is full
const RD_KAFKA_RESP_ERR__QUEUE_FULL = -184
#  ISR count < required.acks
const RD_KAFKA_RESP_ERR__ISR_INSUFF = -183
#  Broker node update
const RD_KAFKA_RESP_ERR__NODE_UPDATE = -182
#  SSL error
const RD_KAFKA_RESP_ERR__SSL = -181
#  Waiting for coordinator to become available.
const RD_KAFKA_RESP_ERR__WAIT_COORD = -180
#  Unknown client group
const RD_KAFKA_RESP_ERR__UNKNOWN_GROUP = -179
#  Operation in progress
const RD_KAFKA_RESP_ERR__IN_PROGRESS = -178
#  Previous operation in progress, wait for it to finish.
const RD_KAFKA_RESP_ERR__PREV_IN_PROGRESS = -177
#  This operation would interfere with an existing subscription
const RD_KAFKA_RESP_ERR__EXISTING_SUBSCRIPTION = -176
#  Assigned partitions (rebalance_cb)
const RD_KAFKA_RESP_ERR__ASSIGN_PARTITIONS = -175
#  Revoked partitions (rebalance_cb)
const RD_KAFKA_RESP_ERR__REVOKE_PARTITIONS = -174
#  Conflicting use
const RD_KAFKA_RESP_ERR__CONFLICT = -173
#  Wrong state
const RD_KAFKA_RESP_ERR__STATE = -172
#  Unknown protocol
const RD_KAFKA_RESP_ERR__UNKNOWN_PROTOCOL = -171
#  Not implemented
const RD_KAFKA_RESP_ERR__NOT_IMPLEMENTED = -170
#  Authentication failure*/
const RD_KAFKA_RESP_ERR__AUTHENTICATION = -169
#  No stored offset
const RD_KAFKA_RESP_ERR__NO_OFFSET = -168
#  Outdated
const RD_KAFKA_RESP_ERR__OUTDATED = -167
#  Timed out in queue
const RD_KAFKA_RESP_ERR__TIMED_OUT_QUEUE = -166
#  Feature not supported by broker
const RD_KAFKA_RESP_ERR__UNSUPPORTED_FEATURE = -165
#  Awaiting cache update
const RD_KAFKA_RESP_ERR__WAIT_CACHE = -164
#  Operation interrupted (e.g., due to yield))
const RD_KAFKA_RESP_ERR__INTR = -163
#  Key serialization error
const RD_KAFKA_RESP_ERR__KEY_SERIALIZATION = -162
#  Value serialization error
const RD_KAFKA_RESP_ERR__VALUE_SERIALIZATION = -161
#  Key deserialization error
const RD_KAFKA_RESP_ERR__KEY_DESERIALIZATION = -160
#  Value deserialization error
const RD_KAFKA_RESP_ERR__VALUE_DESERIALIZATION = -159
#  Partial response
const RD_KAFKA_RESP_ERR__PARTIAL = -158
#  Modification attempted on read-only object
const RD_KAFKA_RESP_ERR__READ_ONLY = -157
#  No such entry / item not found
const RD_KAFKA_RESP_ERR__NOENT = -156
#  Read underflow
const RD_KAFKA_RESP_ERR__UNDERFLOW = -155

#  End internal error codes
const RD_KAFKA_RESP_ERR__END = -100

##  Kafka broker errors:
#  Unknown broker error
const RD_KAFKA_RESP_ERR_UNKNOWN = -1
#  Success
const RD_KAFKA_RESP_ERR_NO_ERROR = 0
#  Offset out of range
const RD_KAFKA_RESP_ERR_OFFSET_OUT_OF_RANGE = 1
#  Invalid message
const RD_KAFKA_RESP_ERR_INVALID_MSG = 2
#  Unknown topic or partition
const RD_KAFKA_RESP_ERR_UNKNOWN_TOPIC_OR_PART = 3
#  Invalid message size
const RD_KAFKA_RESP_ERR_INVALID_MSG_SIZE = 4
#  Leader not available
const RD_KAFKA_RESP_ERR_LEADER_NOT_AVAILABLE = 5
#  Not leader for partition
const RD_KAFKA_RESP_ERR_NOT_LEADER_FOR_PARTITION = 6
#  Request timed out
const RD_KAFKA_RESP_ERR_REQUEST_TIMED_OUT = 7
#  Broker not available
const RD_KAFKA_RESP_ERR_BROKER_NOT_AVAILABLE = 8
#  Replica not available
const RD_KAFKA_RESP_ERR_REPLICA_NOT_AVAILABLE = 9
#  Message size too large
const RD_KAFKA_RESP_ERR_MSG_SIZE_TOO_LARGE = 10
#  StaleControllerEpochCode
const RD_KAFKA_RESP_ERR_STALE_CTRL_EPOCH = 11
#  Offset metadata string too large
const RD_KAFKA_RESP_ERR_OFFSET_METADATA_TOO_LARGE = 12
#  Broker disconnected before response received
const RD_KAFKA_RESP_ERR_NETWORK_EXCEPTION = 13
#  Group coordinator load in progress
const RD_KAFKA_RESP_ERR_GROUP_LOAD_IN_PROGRESS = 14
#  Group coordinator not available
const RD_KAFKA_RESP_ERR_GROUP_COORDINATOR_NOT_AVAILABLE = 15
#  Not coordinator for group
const RD_KAFKA_RESP_ERR_NOT_COORDINATOR_FOR_GROUP = 16
#  Invalid topic
const RD_KAFKA_RESP_ERR_TOPIC_EXCEPTION = 17
#  Message batch larger than configured server segment size
const RD_KAFKA_RESP_ERR_RECORD_LIST_TOO_LARGE = 18
#  Not enough in-sync replicas
const RD_KAFKA_RESP_ERR_NOT_ENOUGH_REPLICAS = 19
#  Message(s) written to insufficient number of in-sync replicas
const RD_KAFKA_RESP_ERR_NOT_ENOUGH_REPLICAS_AFTER_APPEND = 20
#  Invalid required acks value
const RD_KAFKA_RESP_ERR_INVALID_REQUIRED_ACKS = 21
#  Specified group generation id is not valid
const RD_KAFKA_RESP_ERR_ILLEGAL_GENERATION = 22
#  Inconsistent group protocol
const RD_KAFKA_RESP_ERR_INCONSISTENT_GROUP_PROTOCOL = 23
#  Invalid group.id
const RD_KAFKA_RESP_ERR_INVALID_GROUP_ID = 24
#  Unknown member
const RD_KAFKA_RESP_ERR_UNKNOWN_MEMBER_ID = 25
#  Invalid session timeout
const RD_KAFKA_RESP_ERR_INVALID_SESSION_TIMEOUT = 26
#  Group rebalance in progress
const RD_KAFKA_RESP_ERR_REBALANCE_IN_PROGRESS = 27
#  Commit offset data size is not valid
const RD_KAFKA_RESP_ERR_INVALID_COMMIT_OFFSET_SIZE = 28
#  Topic authorization failed
const RD_KAFKA_RESP_ERR_TOPIC_AUTHORIZATION_FAILED = 29
#  Group authorization failed
const RD_KAFKA_RESP_ERR_GROUP_AUTHORIZATION_FAILED = 30
#  Cluster authorization failed
const RD_KAFKA_RESP_ERR_CLUSTER_AUTHORIZATION_FAILED = 31
#  Invalid timestamp
const RD_KAFKA_RESP_ERR_INVALID_TIMESTAMP = 32
#  Unsupported SASL mechanism
const RD_KAFKA_RESP_ERR_UNSUPPORTED_SASL_MECHANISM = 33
#  Illegal SASL state
const RD_KAFKA_RESP_ERR_ILLEGAL_SASL_STATE = 34
#  Unuspported version
const RD_KAFKA_RESP_ERR_UNSUPPORTED_VERSION = 35
#  Topic already exists
const RD_KAFKA_RESP_ERR_TOPIC_ALREADY_EXISTS = 36
#  Invalid number of partitions
const RD_KAFKA_RESP_ERR_INVALID_PARTITIONS = 37
#  Invalid replication factor
const RD_KAFKA_RESP_ERR_INVALID_REPLICATION_FACTOR = 38
#  Invalid replica assignment
const RD_KAFKA_RESP_ERR_INVALID_REPLICA_ASSIGNMENT = 39
#  Invalid config
const RD_KAFKA_RESP_ERR_INVALID_CONFIG = 40
#  Not controller for cluster
const RD_KAFKA_RESP_ERR_NOT_CONTROLLER = 41
#  Invalid request
const RD_KAFKA_RESP_ERR_INVALID_REQUEST = 42
#  Message format on broker does not support request
const RD_KAFKA_RESP_ERR_UNSUPPORTED_FOR_MESSAGE_FORMAT = 43
#  Isolation policy volation
const RD_KAFKA_RESP_ERR_POLICY_VIOLATION = 44
#  Broker received an out of order sequence number
const RD_KAFKA_RESP_ERR_OUT_OF_ORDER_SEQUENCE_NUMBER = 45
#  Broker received a duplicate sequence number
const RD_KAFKA_RESP_ERR_DUPLICATE_SEQUENCE_NUMBER = 46
#  Producer attempted an operation with an old epoch
const RD_KAFKA_RESP_ERR_INVALID_PRODUCER_EPOCH = 47
#  Producer attempted a transactional operation in an invalid state
const RD_KAFKA_RESP_ERR_INVALID_TXN_STATE = 48
#  Producer attempted to use a producer id which is not
#  currently assigned to its transactional id
const RD_KAFKA_RESP_ERR_INVALID_PRODUCER_ID_MAPPING = 49
#  Transaction timeout is larger than the maximum
#  value allowed by the broker's max.transaction.timeout.ms
const RD_KAFKA_RESP_ERR_INVALID_TRANSACTION_TIMEOUT = 50
#  Producer attempted to update a transaction while another
#  concurrent operation on the same transaction was ongoing
const RD_KAFKA_RESP_ERR_CONCURRENT_TRANSACTIONS = 51
#  Indicates that the transaction coordinator sending a
#  WriteTxnMarker is no longer the current coordinator for a
#  given producer
const RD_KAFKA_RESP_ERR_TRANSACTION_COORDINATOR_FENCED = 52
#  Transactional Id authorization failed
const RD_KAFKA_RESP_ERR_TRANSACTIONAL_ID_AUTHORIZATION_FAILED = 53
#  Security features are disabled
const RD_KAFKA_RESP_ERR_SECURITY_DISABLED = 54
#  Operation not attempted
const RD_KAFKA_RESP_ERR_OPERATION_NOT_ATTEMPTED = 55
