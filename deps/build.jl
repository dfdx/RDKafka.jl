import HTTP


const LIBRDKAFKA_REPO = "https://github.com/edenhill/librdkafka/"
# const RELEASE_URL = "https://github.com/edenhill/librdkafka/archive/v0.11.4-adminapi-post1.tar.gz"


# linux-only
cd(@__DIR__) do
    rm("librdkafka"; recursive=true, force=true)
    run(`git clone --depth 1 -b master $LIBRDKAFKA_REPO librdkafka`)
    cd("librdkafka") do
        run(`./configure`)
        run(`make`)        
    end
    cp("librdkafka/src/librdkafka.so.1", "librdkafka.so"; remove_destination=true)
end



# HTTP.open("GET", RELEASE_URL) do http
#     print(typeof(http))
#     # open(`vlc -q --play-and-exit --intf dummy -`, "w") do vlc
#     #     write(vlc, http)
#     # end
# end
