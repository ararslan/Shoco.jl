__precompile__()

module Shoco

if isfile(joinpath(dirname(@__FILE__), "..", "deps", "deps.jl"))
    include("../deps/deps.jl")
else
    error("Shoco not properly installed. Please run Pkg.build(\"Shoco\")",
          " and restart Julia.")
end

export compress, decompress

function compress{T<:AbstractString}(s::T)
    isempty(s) && return s

    # The output should be no longer than the input
    compressed = Vector{UInt8}(sizeof(s))

    # The function modifies `compressed` and returns the number of bytes written
    nbytes = ccall((:shoco_compress, shoco), Int,
                   (Ptr{Cchar}, Csize_t, Ptr{UInt8}, Csize_t),
                   s, 0, compressed, sizeof(s))

    # Failed compression is shoco's fault, not ours >_>
    nbytes > 0 || error("Compression failed for input $s")

    resize!(compressed, nbytes)

    return T(String(compressed))
end

function decompress{T<:AbstractString}(s::T)
    isempty(s) && return s

    # The decompressed string will be at most twice as long as the input
    decompressed = Vector{UInt8}(2 * sizeof(s))

    nbytes = ccall((:shoco_decompress, shoco), Int,
                   (Ptr{Cchar}, Csize_t, Ptr{UInt8}, Csize_t),
                   s, sizeof(s), decompressed, 2 * sizeof(s))

    nbytes > 0 || error("Decompression failed for input $s")

    resize!(decompressed, nbytes)

    return T(String(decompressed))
end

end # module
