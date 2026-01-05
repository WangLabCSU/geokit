# GEO accession type

Determine the type of a GEO accession ID (e.g. DataSet, Series, Sample,
Platform). This function inspects the accession prefix and returns its
corresponding GEO type, optionally in an abbreviated form.

## Usage

``` r
geo_gtype(accession, abbre = FALSE)
```

## Arguments

- accession:

  A character of GEO accession IDs. Examples:

  - DataSets (GDS): `"GDS505"`, `"GDS606"`, `"GDS1234"`, `"GDS9999"`,
    etc.

  - Series (GSE): `"GSE2"`, `"GSE22"`, `"GSE100"`, `"GSE2000"`, etc.

  - Platforms (GPL): `"GPL96"`, `"GPL570"`, `"GPL10558"`, etc.

  - Samples (GSM): `"GSM12345"`, `"GSM67890"`, `"GSM112233"`, etc.

- abbre:

  A logical scalar indicating whether to abbreviate the GEO type in the
  return value. If `FALSE` (default), the full type name is returned; if
  `TRUE`, a short abbreviation is used.

## Value

A character of GEO accession type.
