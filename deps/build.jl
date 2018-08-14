Sys.iswindows() && error("The Shoco C library does not support Windows")

using BinaryProvider

const verbose = "--verbose" in ARGS
const prefix = Prefix(get(filter(!isequal("verbose"), ARGS), 1, joinpath(@__DIR__, "usr")))
products = [LibraryProduct(prefix, ["libshoco"], :libshoco)]

bin_prefix = "https://github.com/ararslan/ShocoBuilder/releases/download/v0.1.0"

downloads = Dict(
    FreeBSD(:x86_64) =>
        ("$bin_prefix/Shoco.v0.1.0.x86_64-unknown-freebsd11.1.tar.gz",
         "d96d79c5302ff90b5ff3f5051893988c4029e3bc351a8b2b8c3ba1deb4f81cce"),
    Linux(:aarch64, :glibc) =>
        ("$bin_prefix/Shoco.v0.1.0.aarch64-linux-gnu.tar.gz",
         "053c6375973758bbe477b2f2d36d7aa8c1e15d39476eb293f5e2704556a2b289"),
    Linux(:aarch64, :musl) =>
        ("$bin_prefix/Shoco.v0.1.0.aarch64-linux-musl.tar.gz",
         "7ce8c33e688ce177f5e4f8dc38a8861c3a20dab0555ec165d51ad0086fc14e78"),
    Linux(:armv7l, :glibc, :eabihf) =>
        ("$bin_prefix/Shoco.v0.1.0.arm-linux-gnueabihf.tar.gz",
         "0133cc0dbcd619902cbd340ea3277d5b9aea2f338ef89176f61f8c0faf64d2bb"),
    Linux(:armv7l, :musl, :eabihf) =>
        ("$bin_prefix/Shoco.v0.1.0.arm-linux-musleabihf.tar.gz",
         "1df02541a066099c818b9d260589cf479167568faf2b720183b748e6eed1f2f7"),
    Linux(:i686, :glibc) =>
        ("$bin_prefix/Shoco.v0.1.0.i686-linux-gnu.tar.gz",
         "5066fa8421f8d3b37c0dcfe12486ff87a8bbfb407429cad7f751c40ccd4d395d"),
    Linux(:i686, :musl) =>
        ("$bin_prefix/Shoco.v0.1.0.i686-linux-musl.tar.gz",
         "89669f0c72afaf974b3aae11445dee1ed6a96dd94cf016acf45041c54d463ecc"),
    Linux(:powerpc64le, :glibc) =>
        ("$bin_prefix/Shoco.v0.1.0.powerpc64le-linux-gnu.tar.gz",
         "7befe4ba16b6b6c99fe626a1949252782bedf04f82aae43333db9db6285f95bc"),
    Linux(:x86_64, :glibc) =>
        ("$bin_prefix/Shoco.v0.1.0.x86_64-linux-gnu.tar.gz",
         "72feff5505b72dd712c6673cef6e30cc23b6e42f750fd434f9ad51262cc6ba5d"),
    Linux(:x86_64, :musl) =>
        ("$bin_prefix/Shoco.v0.1.0.x86_64-linux-musl.tar.gz",
         "d32b95617506858168bfdc5c3a6c1754590eb495152f9eeb5608dff5450cf1e5"),
    MacOS(:x86_64) =>
        ("$bin_prefix/Shoco.v0.1.0.x86_64-apple-darwin14.tar.gz",
         "1dfcb16c8c3becad52225015001910fb8e322e685c7f577478661024f14f2a7f"),
)

unsatisfied = any(p->!satisfied(p, verbose=verbose), products)

if haskey(downloads, platform_key())
    url, hash = downloads[platform_key()]
    if unsatisfied || !isinstalled(url, hash, prefix=prefix)
        install(url, hash, prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    error("Your platform ($(triplet(platform_key()))) is not supported")
end

write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
