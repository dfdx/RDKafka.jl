
DIR = @__DIR__

if DIR != nothing
    const LIBRDKAFKA = DIR * "/../deps/librdkafka.so"
else
    const LIBRDKAFKA = Pkg.dir("RDKafka", "deps", "librdkafka.so")
end
