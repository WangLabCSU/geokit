# Apply log2 Transformation to Expression Data

Checks whether the input data is already log-transformed; if not,
applies a log2 transformation. This helps ensure comparability of
expression values across datasets.

## Usage

``` r
log_trans(data, pseudo = 1, ...)

# S3 method for class 'matrix'
log_trans(data, pseudo = 1, ...)

# S3 method for class 'ExpressionSet'
log_trans(data, pseudo = 1, ...)
```

## Arguments

- data:

  A matrix-like data object.

- pseudo:

  A numeric value added before transformation to avoid taking log of
  zero. For example, `log2(exprs + pseudo)`.

- ...:

  Additional arguments passed to methods.

## Value

A `matrix` or an ExpressionSet with log2-transformed expression values.

## Details

The function heuristically determines whether `data` has been
log-transformed, following the methodology used in
[GEO2R](https://www.ncbi.nlm.nih.gov/geo/geo2r/). If not, it applies
[`log2()`](https://rdrr.io/r/base/Log.html) with the specified `pseudo`
offset.

## References

NCBI GEO2R: <https://www.ncbi.nlm.nih.gov/geo/geo2r/?acc=GSE1122>

## Examples

``` r
sample_means <- 2^runif(2, 2, 10)
sample_disp <- 100 / sample_means + 0.5
data <- matrix(
    rnbinom(4, mu = sample_means, size = 1 / sample_disp),
    nrow = 2
)
log_trans(data)
#> Applying log2 transformation with a pseudo count of 1 to the data.
#>          [,1]     [,2]
#> [1,] 5.321928 0.000000
#> [2,] 3.584963 8.864186
log_trans(log2(data))
#> The data is already log-transformed. No transformation applied.
#>          [,1]     [,2]
#> [1,] 5.285402     -Inf
#> [2,] 3.459432 8.861087
```
