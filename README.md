# GH19

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ggebbie.github.io/GH19.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ggebbie.github.io/GH19.jl/dev/)
[![Build Status](https://github.com/ggebbie/GH19.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ggebbie/GH19.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/ggebbie/GH19.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ggebbie/GH19.jl)

# Examples

See `test/runtest.jl` for examples

# Usage

Download 6 output files totaling about 10 GB of output
`download_all()`

Download output from a specific experiment.
`function download(experiment::String;anomaly=false)`

## Arguments
- `experiment::String`: name of experiment, use `explist()` to get possible names
- `anomaly::Bool`: true to load θ anomaly, false to load full θ
## Output
- `outputfile`: name of loaded file, found in the `datadir()` directory

