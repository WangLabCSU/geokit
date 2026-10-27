# Contributing to geokit

Thanks for considering a contribution!

## Development setup

geokit uses a Rust backend for URL resolution and SOFT parsing. To build
from source you need the Rust toolchain (`cargo` and `rustc`, see the
`SystemRequirements` field in DESCRIPTION) in addition to R.

``` sh
git clone https://github.com/WangLabCSU/geokit.git
Rscript -e 'pkgload::load_all(".")'
```

## Pull requests

- Work on a feature branch and keep pull requests focused on one change.
- Add or update tests in `tests/testthat/` for behavior changes. Tests
  that hit NCBI should use `skip_if_download_fail()` (download layer) so
  they skip gracefully when the network is unavailable.
- Keep roxygen documentation in `R/*.R` in sync with the code and
  regenerate the `man/` pages with `roxygen2::roxygenise()` when docs
  change.
- Record user-visible changes in `NEWS.md` under the development-version
  section.
- CI runs `R CMD check` on Linux, macOS, and Windows plus test coverage;
  please keep it green.

## Reporting issues

Include your R version, geokit version (`packageVersion("geokit")`), and
a minimal reproducible example. For download problems, mention whether
an NCBI API key (`ENTREZ_KEY`) is set and whether your environment can
reach `ftp.ncbi.nlm.nih.gov`.
