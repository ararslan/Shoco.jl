using Shoco
using Base.Test

s = "What's up, doc?"
c = compress(s)
@test 0 < sizeof(c) < sizeof(s)
@test decompress(c) == s
