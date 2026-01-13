# Retrieve GEO SOFT file from NCBI GEO

Retrieve GEO SOFT file from NCBI GEO

## Usage

``` r
geo_soft(
  accession,
  famount = NULL,
  scope = NULL,
  ftp_over_https = NULL,
  handle_opts = list(),
  odir = getwd()
)
```

## Arguments

- accession:

  A character of GEO accession IDs. Examples:

  - DataSets (GDS): `"GDS505"`, `"GDS606"`, `"GDS1234"`, `"GDS9999"`,
    etc.

  - Series (GSE): `"GSE2"`, `"GSE22"`, `"GSE100"`, `"GSE2000"`, etc.

  - Platforms (GPL): `"GPL96"`, `"GPL570"`, `"GPL10558"`, etc.

  - Samples (GSM): `"GSM12345"`, `"GSM67890"`, `"GSM112233"`, etc.

- famount:

  A character string specifying either:

  - the file `format` on the GEO FTP server, or

  - the `amount` of data in the GEO Accession Display Bar.

  See
  [`geo_url()`](https://WangLabCSU.github.io/geokit/reference/geo_url.md)
  for details.

- scope:

  A character specifying which GEO accessions to include (Only
  applicable to Accession Display Bar access).

  - `"none"`: Applicable only to DataSets; for DataSets, this is also
    the sole valid option

  - `"self"`: the queried accession only.

  - `"gsm"`, `"gpl"`, `"gse"`: related samples, platforms, or series.

  - `"all"`: all accessions related to the query (family view).

- ftp_over_https:

  Logical scalar. If `TRUE`, connects to GEO FTP server via HTTPS
  (<https://ftp.ncbi.nlm.nih.gov/geo>); otherwise uses plain FTP
  (<ftp://ftp.ncbi.nlm.nih.gov/geo>). Only applicable to GEO FTP server
  access.

- handle_opts:

  A list of named options / headers to be set in the
  [`multi_download`](https://jeroen.r-universe.dev/curl/reference/multi_download.html).

- odir:

  Destination directory for downloads. Defaults to the current working
  directory.

## Value

A
[GEOSoft](https://WangLabCSU.github.io/geokit/reference/GEOSoft-class.md)
object

## Details

The Gene Expression Omnibus (GEO) from NCBI serves as a public
repository for a wide range of high-throughput experimental data. These
data include single and dual channel microarray-based experiments
measuring mRNA, genomic DNA, and protein abundance, as well as non-array
techniques such as serial analysis of gene expression (SAGE), and mass
spectrometry proteomic data. At the most basic level of organization of
GEO, there are three entity types that may be supplied by users:
Platforms, Samples, and Series. Additionally, there is a curated entity
called a GEO dataset.

A Platform record describes the list of elements on the array (e.g.,
cDNAs, oligonucleotide probesets, ORFs, antibodies) or the list of
elements that may be detected and quantified in that experiment (e.g.,
SAGE tags, peptides). Each Platform record is assigned a unique and
stable GEO accession number (GPLxxx). A Platform may reference many
Samples/Series that have been submitted by multiple submitters.

A Sample record describes the conditions under which an individual
Sample was handled, the manipulations it underwent, and the abundance
measurement of each element derived from it. Each Sample record is
assigned a unique and stable GEO accession number (GSMxxx). A Sample
entity must reference only one Platform and may be included in multiple
Series.

A Series record defines a set of related Samples considered to be part
of a group, how the Samples are related, and if and how they are
ordered. A Series provides a focal point and description of the
experiment as a whole. Series records may also contain tables describing
extracted data, summary conclusions, or analyses. Each Series record is
assigned a unique and stable GEO accession number (GSExxx).

GEO DataSets (GDSxxx) are curated sets of GEO Sample data. A GDS record
represents a collection of biologically and statistically comparable GEO
Samples and forms the basis of GEO's suite of data display and analysis
tools. Samples within a GDS refer to the same Platform, that is, they
share a common set of probe elements. Value measurements for each Sample
within a GDS are assumed to be calculated in an equivalent manner, that
is, considerations such as background processing and normalization are
consistent across the dataset. Information reflecting experimental
design is provided through GDS subsets.

## Examples

``` r
gse <- geo_soft("GSE10", odir = tempdir())
#> Finding 1 file already downloaded
gpl <- geo_soft("gpl98", odir = tempdir())
#> Downloading 1 file
gsm <- geo_soft("GSM1", odir = tempdir())
#> Downloading 1 file
gds <- geo_soft("GDS10", odir = tempdir())
#> Downloading 1 file
```
