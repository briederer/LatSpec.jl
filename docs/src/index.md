# LatSpec.jl
[![Build status](https://github.com/bernd1995/LatSpec.jl/workflows/CI/badge.svg)](https://github.com/bernd1995/LatSpec.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![codecov](https://codecov.io/gh/bernd1995/LatSpec.jl/branch/master/graph/badge.svg?token=QDQVBL8B4X)](https://codecov.io/gh/bernd1995/LatSpec.jl)
[![Docs-dev](https://img.shields.io/badge/docs-latest-blue.svg)](https://bernd1995.github.io/LatSpec.jl/dev/)
[![Docs-stable](https://img.shields.io/badge/docs-stable-lightgrey.svg)](https://bernd1995.github.io/LatSpec.jl/)

**LatSpec.jl** is a package for performing spectroscopical analyses for [Lattice Field Theories](https://en.wikipedia.org/wiki/Lattice_field_theory). The package provides functions and suitable for all phases of the analysation process:

 - **Statistics**: calculating autocorrelations, expectation values, ...
 - **Spectroscopy**: performing variational analysis, extracting masses from correlators, ...
 - **Output**: representation of data and results(, efficient storing?)


# **❗️ Warning: This package is in a very early stage ❗️**
  - The package is neither registered yet, nor really working at this moment.
  - So just be patient and add [Issues](https://github.com/bernd1995/LatSpec.jl/issues) or [Pull-Requests](https://github.com/bernd1995/LatSpec.jl/pulls) if you want something to be added.

## Installation

The package can be installed with the Julia package manager (though not yet registered). From the Julia REPL, type `]` to enter the Pkg REPL mode and run:

```julia
pkg> add https://github.com/bernd1995/LatSpec.jl
```
Or, equivalently, via the Pkg API:
```julia
julia> import Pkg; Pkg.add(url="https://github.com/bernd1995/LatSpec.jl")
```

## Usage

Short description of how to use and add to project here

## Special Features

Any special features and examples go here

## Created by

#### Bernd Riederer ([@bernd1995](https://github.com/bernd1995))

[![Contact-me](https://img.shields.io/badge/@-Contact%20me-009DDC)](mailto:bernd_riederer@hotmail.com?subject=[GitHub]%20LatSpec.jl)
[![Linktr.ee](https://img.shields.io/badge/-Linktree%20-lightgrey?logo=linktree)](https://linktr.ee/b_riederer)
[![Website](https://img.shields.io/badge/Web-Work-fddc05?labelColor=cccccc&logo=data:image/png;base64,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)](https://homepage.uni-graz.at/en/bernd.riederer)
[![Gitlab-b_riederer](https://img.shields.io/badge/GitLab-%40b__riederer-lightgrey?style=social&logo=gitlab)](https://gitlab.com/b_riederer)
[![Twitter-b_riederer](https://img.shields.io/badge/Twitter-%40b__riederer-lightgrey?style=social&logo=twitter)](https://twitter.com/b_riederer)

#### Fabian Zierler ([@fzierler](https://github.com/fzierler))

[![Contact-me](https://img.shields.io/badge/@-Contact%20me-009DDC)](mailto:fabian.zierler@uni-graz.at?subject=[GitHub]%20LatSpec.jl)
