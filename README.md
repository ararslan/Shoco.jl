# Shoco.jl

[![Coverage Status](https://coveralls.io/repos/github/ararslan/Shoco.jl/badge.svg?branch=master)](https://coveralls.io/github/ararslan/Shoco.jl?branch=master)

**Shoco.jl** is a Julia module that provides access to the compression and decompression functions in the [**shoco**](https://github.com/Ed-von-Schleck/shoco) C library.
The algorithms are optimized for short strings and perform well in comparison to [smaz](https://github.com/antirez/smaz), [gzip](https://en.wikipedia.org/wiki/Gzip), and [xz](https://en.wikipedia.org/wiki/Xz).
Compression is performed using [entropy encoding](https://en.wikipedia.org/wiki/Entropy_encoding).

Two functions are provided by the module: `compress` and `decompress`.
Both accept a single `AbstractString` argument and return a string.
Note that even though Julia likes to assume the output from `compress` is a `UTF8String`, depending on the input the output may not actually be valid UTF-8.

Here's an example using the functions at the REPL.

```julia
julia> using Shoco

julia> compress("what's happening")
"؉'s ⎨<g"

julia> decompress("؉'s ⎨<g")
"what's happening"
```
