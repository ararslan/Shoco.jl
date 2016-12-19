if is_windows()
    error("The shoco C library doesn't support Windows")
end

using BinDeps

@BinDeps.setup

shoco = library_dependency("shoco")

if isdir(srcdir(shoco))
    rm(srcdir(shoco), recursive=true)
    mkdir(srcdir(shoco))
end

if isdir(BinDeps.downloadsdir(shoco))
    rm(BinDeps.downloadsdir(shoco), recursive=true)
    mkdir(BinDeps.downloadsdir(shoco))
end

sha = "4dee0fc850cdec2bdb911093fe0a6a56e3623b71"

provides(Sources, URI("https://github.com/Ed-von-Schleck/shoco/archive/$(sha).zip"), shoco,
         unpacked_dir="shoco-$sha")

provides(BuildProcess, (@build_steps begin
    GetSources(shoco)
    CreateDirectory(joinpath(BinDeps.builddir(shoco), "shoco"))
    @build_steps begin
        ChangeDirectory(joinpath(BinDeps.builddir(shoco), "shoco"))
        FileRule(joinpath(libdir(shoco), "shoco." * BinDeps.shlib_ext), @build_steps begin
            CreateDirectory(libdir(shoco))
            CCompile(joinpath(srcdir(shoco), "shoco-$sha", "shoco.c"),
                     joinpath(libdir(shoco), "shoco." * BinDeps.shlib_ext),
                     ["-fPIC", "-std=c99", is_apple() ? "-dynamiclib" : "-shared"], [])
        end)
    end
end), shoco)

@BinDeps.install Dict(:shoco => :shoco)
