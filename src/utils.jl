
function unsafe_load_array(p::Ptr{T}, len::Integer) where T
    @assert T != Nothing "Cannot load array from Ptr{Void}, perhaps you meant to use a typed pointer?"
    a = Array{T}(undef, len)
    for i in 1:len
        a[i] = unsafe_load(p, i)
    end
    return a
end

# Internal method to convert a key/payload to a bytestream for Kafka
# Numeric types can be represented as a byte stream using hton and reinterpret.
# We will need to do the opposite on the consumer side to convert bac
_tobytestream(o::Number) = reinterpret(UInt8, [hton(payload)])
_tobytestream(o::Vector{UInt8}) = o
_tobytestream(o::AbstractString) = Vector{UInt8}(o)
_tobytestream(::Nothing) = [UInt8(0)]
# The generic version will convert to String first. This is used for symbols and any complex object.
# Callers would be better off using JSON or byte stream instead
_tobytestream(o) = _tobytestream(string(o))

# Internal method to convert a byte stream to a Julia object
_frombytestream(::Type{T}, stream::Vector{UInt8}) where {T<:Number} = ntoh(reinterpret(T, stream)[1])
_frombytestream(::Type{Vector{UInt8}}, stream::Vector{UInt8}) = stream
_frombytestream(::Type{T}, stream::Vector{UInt8}) where {T<:AbstractString}= T(stream)
