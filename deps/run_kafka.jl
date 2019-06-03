# download and run simple Kafka cluster, create topic "test" with a single partition
# requires Java to be installed and ports 2181 and 9092 to be open
# tested on Linux, might work with OS X; please run Kafka manually on other plarforms

using Pkg
import RDKafka


const KAFKA_RELEASE_URL = "https://www-eu.apache.org/dist/kafka/2.2.0/kafka_2.12-2.2.0.tgz"
const KAFKA_BASE_PATH = joinpath(pathof(RDKafka) |> dirname |> dirname, "deps", "kafka")
const KAFKA_ARCHIVE_PATH = joinpath(KAFKA_BASE_PATH, "archive.tgz")
const KAFKA_PATH = joinpath(KAFKA_BASE_PATH, "kafka_2.12-2.2.0")


function k_install()
    mkpath(KAFKA_PATH)
    download(KAFKA_RELEASE_URL, KAFKA_ARCHIVE_PATH)
    run(`tar -C $KAFKA_BASE_PATH -xzf $KAFKA_ARCHIVE_PATH`)
end


function k_run()
    cd(KAFKA_PATH) do
        zk = @async run(`bin/zookeeper-server-start.sh config/zookeeper.properties`)
        kb = @async run(`bin/kafka-server-start.sh config/server.properties`)
        try
            run(`bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic test '|' true`)
        catch
           @info "Can't create topic 'test', assuming it already exists"
        end
        wait(zk)  # block forever
    end
end


function main()
    if !isdir(KAFKA_PATH)
        k_install()
    end
    k_run()
end


main()
