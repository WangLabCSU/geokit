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
