import Libdl: dlext

DIR = @__DIR__

if DIR != nothing
    const DEP_DIR = joinpath(DIR, "..", "deps", "usr")
else
    const DEP_DIR = Pkg.dir("RDKafka", "deps", "usr")
end


function find_librdkafka(dep_dir)
    base = "librdkafka"
    for fname in [
        "$base.$dlext",
        "$base.$dlext.1",
        "$base.1.$dlext",        
    ]
        path = abspath(joinpath(dep_dir, fname))
        if isfile(path)
            return path
        end
    end
    return nothing
end

const LIBRDKAFKA = find_librdkafka(DEP_DIR)
