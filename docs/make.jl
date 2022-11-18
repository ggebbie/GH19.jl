using GH19
using Documenter

DocMeta.setdocmeta!(GH19, :DocTestSetup, :(using GH19); recursive=true)

makedocs(;
    modules=[GH19],
    authors="G Jake Gebbie <ggebbie@whoi.edu>",
    repo="https://github.com/ggebbie/GH19.jl/blob/{commit}{path}#{line}",
    sitename="GH19.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ggebbie.github.io/GH19.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ggebbie/GH19.jl",
    devbranch="main",
)
