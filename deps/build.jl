using Compat
using Compat.Libdl
using Compat.Sys: iswindows, isapple
using BinDeps
using BinDeps: downloadsdir, builddir

if iswindows()
    error("The Shoco C library does not support Windows")
end

BinDeps.@setup

shoco = library_dependency("shoco")

if isdir(srcdir(shoco))
    rm(srcdir(shoco), recursive=true)
    mkdir(srcdir(shoco))
end

if isdir(downloadsdir(shoco))
    rm(downloadsdir(shoco), recursive=true)
    mkdir(downloadsdir(shoco))
end

sha = "4dee0fc850cdec2bdb911093fe0a6a56e3623b71"

provides(Sources, URI("https://github.com/Ed-von-Schleck/shoco/archive/$(sha).zip"), shoco,
         unpacked_dir="shoco-$sha")

provides(BuildProcess, (@build_steps begin
    GetSources(shoco)
    CreateDirectory(joinpath(builddir(shoco), "shoco"))
    @build_steps begin
        ChangeDirectory(joinpath(builddir(shoco), "shoco"))
        FileRule(joinpath(libdir(shoco), "shoco." * Libdl.dlext), @build_steps begin
            CreateDirectory(libdir(shoco))
            CCompile(joinpath(srcdir(shoco), "shoco-$sha", "shoco.c"),
                     joinpath(libdir(shoco), "shoco." * Libdl.dlext),
                     ["-fPIC", "-std=c99", isapple() ? "-dynamiclib" : "-shared"], [])
        end)
    end
end), shoco)

BinDeps.@install Dict(:shoco => :shoco)
