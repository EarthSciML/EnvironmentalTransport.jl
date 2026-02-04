```@meta
CurrentModule = EnvironmentalTransport
```

# EnvironmentalTransport: Algorithms for Environmental Mass Transport

Documentation for [EnvironmentalTransport.jl](https://github.com/EarthSciML/EnvironmentalTransport.jl).

This package contains algorithms for simulating environmental mass transport, for use with the [EarthSciML](https://earthsci.dev) ecosystem.

## Installation

```julia
using Pkg
Pkg.add("EnvironmentalTransport")
```

## Feature Summary

This package contains types and functions designed to simplify the process of constructing and composing symbolically-defined Earth Science model components together.

## Feature List

  - Numerical Advection
  - General Circulation (Coriolis parameter, geostrophic wind, thermal wind)

## Contributing

  - Please refer to the
    [SciML ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://github.com/SciML/ColPrac/blob/master/README.md)
    for guidance on PRs, issues, and other matters relating to contributing.

## Reproducibility

```@raw html
<details><summary>The documentation of this EnvironmentalTransport package was built using these direct dependencies,</summary>
```

```@example
using Pkg # hide
Pkg.status() # hide
```

```@raw html
</details>
```

```@raw html
<details><summary>and using this machine and Julia version.</summary>
```

```@example
using InteractiveUtils # hide
versioninfo() # hide
```

```@raw html
</details>
```

```@raw html
<details><summary>A more complete overview of all dependencies and their versions is also provided.</summary>
```

```@example
using Pkg # hide
Pkg.status(; mode = PKGMODE_MANIFEST) # hide
```

```@raw html
</details>
```

```@raw html
You can also download the 
<a href="
```

```@eval
using TOML
using Markdown
version = TOML.parse(read("../../Project.toml", String))["version"]
name = TOML.parse(read("../../Project.toml", String))["name"]
link = Markdown.MD("https://github.com/EarthSciML/"*name*".jl/tree/gh-pages/v"*version*"/assets/Manifest.toml")
```

```@raw html
">manifest</a> file and the
<a href="
```

```@eval
using TOML
using Markdown
version = TOML.parse(read("../../Project.toml", String))["version"]
name = TOML.parse(read("../../Project.toml", String))["name"]
link = Markdown.MD("https://github.com/EarthSciML/"*name*".jl/tree/gh-pages/v"*version*"/assets/Project.toml")
```

```@raw html
">project</a> file.
```
