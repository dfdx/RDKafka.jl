
function unsafe_load_array(p::Ptr{T}, len::Integer) where T
    @assert T != Nothing "Cannot load array from Ptr{Void}, perhaps you meant to use a typed pointer?"
    a = Array{T}(undef, len)
    for i in 1:len
        a[i] = unsafe_load(p, i)
    end
    return a
end
