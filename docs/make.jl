using EnvironmentalTransport
using Documenter

DocMeta.setdocmeta!(
    EnvironmentalTransport, :DocTestSetup,
    :(using EnvironmentalTransport); recursive = true
)

makedocs(;
    modules = [EnvironmentalTransport],
    authors = "EarthSthSciML authors and contributors",
    repo = "https://github.com/EarthSciML/EnvironmentalTransport.jl/blob/{commit}{path}#{line}",
    sitename = "EnvironmentalTransport.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://EarthSciML.github.io/EnvironmentalTransport.jl",
        edit_link = "main",
        assets = String[],
        repolink = "https://github.com/EarthSciML/EnvironmentalTransport.jl"
    ),
    pages = [
        "Home" => "index.md",
        "Advection" => "advection.md",
        "Puff Model" => "puff.md",
        "Surface Runoff" => "surface_runoff.md",
        "API" => "api.md",
        "🔗 Benchmarks" => "benchmarks.md",
    ]
)

deploydocs(;
    repo = "github.com/EarthSciML/EnvironmentalTransport.jl",
    devbranch = "main"
)
