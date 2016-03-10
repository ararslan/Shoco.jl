__precompile__()

module Shoco
    using BinDeps
    @BinDeps.load_dependencies

    export compress, decompress

    # Gets the fully qualified path to the library for use in ccall
    const LIB = shoco[1][2]

    function compress(s::AbstractString)
        compressed = Array(Cchar, sizeof(s))
        nbytes = ccall((:shoco_compress, LIB), Int,
                       (Ptr{Cchar}, Csize_t, Ptr{Cchar}, Csize_t),
                       s, 0, compressed, sizeof(s))
        nbytes == 0 && return ""
        compressed = compressed[1:nbytes]
        # Ensure null termination
        compressed[end] == Cchar(0) || push!(compressed, Cchar(0))
        return bytestring(pointer(compressed))
    end

    function decompress(s::AbstractString)
        # The decompressed string will be at most twice as long as the input
        decompressed = Array(Cchar, 2 * sizeof(s))
        nbytes = ccall((:shoco_decompress, LIB), Int,
                       (Ptr{Cchar}, Csize_t, Ptr{Cchar}, Csize_t),
                       s, sizeof(s), decompressed, 2 * sizeof(s))
        decompressed = decompressed[1:nbytes]
        decompressed[end] == Cchar(0) || push!(decompressed, Cchar(0))
        return bytestring(pointer(decompressed))
    end

end
