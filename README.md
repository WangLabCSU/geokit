
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geokit

<!-- badges: start -->

[![R-CMD-check](https://github.com/WangLabCSU/geokit/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/WangLabCSU/geokit/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/WangLabCSU/geokit/graph/badge.svg)](https://app.codecov.io/gh/WangLabCSU/geokit)
[![Ask
DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/WangLabCSU/geokit)
<!-- badges: end -->

The goal of `geokit` is to provide a comprehensive interface for most
interactions between R and [GEO
database](https://www.ncbi.nlm.nih.gov/geo/).

## Installation

You can install the development version of `geokit` from
[R-universe](https://wanglabcsu.r-universe.dev) (Recommended):

``` r
install.packages("geokit",
    repos = c(
        "https://wanglabcsu.r-universe.dev",
        "https://cloud.r-project.org"
    )
)
```

or from [GitHub](https://github.com/WangLabCSU/geokit) (Require `rust`
to compile) with:

``` r
if (!requireNamespace("pak")) {
    install.packages("pak",
        repos = sprintf(
            "https://r-lib.github.io/p/pak/devel/%s/%s/%s",
            .Platform$pkgType, R.Version()$os, R.Version()$arch
        )
    )
}
pak::pak("WangLabCSU/geokit")
```

## Learning geokit

Check out the [guides](https://wanglabcsu.github.io/geokit/) to learn
everything there is to know about the different features.

## Agent skill

geokit ships an [Agent Skills](https://agentskills.io) file that teaches
AI coding assistants how to use the package effectively — searching GEO,
downloading data, parsing metadata, and chatting with LLMs — without
reading the full documentation first. The file is served as plain
Markdown together with this website, so your assistant can fetch it
directly, no installation required:

``` bash
curl -fsSL https://wanglabcsu.github.io/geokit/skills/geokit/SKILL.md -o SKILL.md
```

- Skill file:
  <https://wanglabcsu.github.io/geokit/skills/geokit/SKILL.md>
- Landing page:
  <https://wanglabcsu.github.io/geokit/skills/geokit/SKILL.html>
- Source:
  [pkgdown/assets/skills/geokit/SKILL.md](https://github.com/WangLabCSU/geokit/blob/main/pkgdown/assets/skills/geokit/SKILL.md)

The file lives in this repository and is deployed with the documentation
site, so it stays in sync with the released docs.
