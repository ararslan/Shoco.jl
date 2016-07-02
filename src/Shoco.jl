__precompile__()

module Shoco
    if isfile(joinpath(dirname(@__FILE__), "..", "deps", "deps.jl"))
        include("../deps/deps.jl")
    else
        error("Shoco not properly installed. Please run Pkg.build(\"Shoco\")",
              " and restart Julia.")
    end

    export compress, decompress

    if !isdefined(Base, :unsafe_string)
        const unsafe_string = bytestring
    end

    function compress(s::AbstractString)
        isempty(s) && return ""

        # The output should be no longer than the input
        compressed = Array(Cchar, sizeof(s))

        # The function modifies `compressed` and returns the number of bytes written
        nbytes = ccall((:shoco_compress, shoco), Int,
                       (Ptr{Cchar}, Csize_t, Ptr{Cchar}, Csize_t),
                       s, 0, compressed, sizeof(s))

        # Failed compression is shoco's fault, not ours >_>
        nbytes > 0 || throw(ErrorException("Compression failed for input $s"))

        compressed = compressed[1:nbytes]
        compressed[end] == Cchar(0) || push!(compressed, Cchar(0))

        return unsafe_string(pointer(compressed))
    end


    function decompress(s::AbstractString)
        isempty(s) && return ""

        # The decompressed string will be at most twice as long as the input
        decompressed = Array(Cchar, 2 * sizeof(s))

        nbytes = ccall((:shoco_decompress, shoco), Int,
                       (Ptr{Cchar}, Csize_t, Ptr{Cchar}, Csize_t),
                       s, sizeof(s), decompressed, 2 * sizeof(s))

        nbytes > 0 || throw(ErrorException("Decompression failed for input $s"))

        decompressed = decompressed[1:nbytes]
        decompressed[end] == Cchar(0) || push!(decompressed, Cchar(0))

        return unsafe_string(pointer(decompressed))
    end
end
