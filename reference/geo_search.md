# Search GEO database

Search the [GDS](https://www.ncbi.nlm.nih.gov/gds) database and return
search results as a data frame.

## Usage

``` r
geo_search(query, step = 500L, interval = NULL)
```

## Arguments

- query:

  A character string with the search term. The NCBI uses a fielded
  search syntax. For example, `"Homo sapiens[ORGN]"` searches the
  "Organism" field for *Homo sapiens*. See the [GEO query
  tutorial](https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html) for
  details. Searchable fields can be listed with
  [`rentrez::entrez_db_searchable("gds")`](https://docs.ropensci.org/rentrez/reference/entrez_db_searchable.html).

- step:

  Integer. Number of records to fetch per request. Use a smaller value
  if requests fail.

- interval:

  Numeric. Time interval (in seconds) between successive requests.
  Defaults to `0`. Increase this value if requests fail due to rate
  limits.

## Value

A data frame contains the search results

## Details

The NCBI allows higher request limits (10 per second) when using an API
key. You can set this key for the current R session with
[`rentrez::set_entrez_key()`](https://docs.ropensci.org/rentrez/reference/set_entrez_key.html),
or permanently by setting the `ENTREZ_KEY` environment variable via
[Sys.setenv()](https://rdrr.io/r/base/Sys.setenv.html). Once set,
`rentrez` will automatically use this key for all NCBI requests. See the
[rentrez
tutorial](https://docs.ropensci.org/rentrez/articles/rentrez_tutorial.html#rate-limiting-and-api-keys)
for details.

## Examples

``` r
# Ensure you have an active internet connection before running the search.
# The `geo_search` function queries NCBI Entrez, which may have network
# restrictions and limited bandwidth usage for large queries.
# \donttest{
out <- geo_search("diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]")
#> ■■■■■■■■■                        500/1893 [444/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■        1500/1893 [345/s] | ETA:  1s
#> Get records from NCBI for 1893 queries in 5.5s
#> 
#> → Parsing GEO records
head(out)
#>                                                                                                                                                                        Title
#> 1 Calpain inhibition prevents high-glucose-induced autophagy blockade and mitochondrial fragmentation in endothelial cells and preserves vascular functions in diabetic mice
#> 2                                                                                                   Nonviral delivery of chemically modified tRNA rescues nonsense mutations
#> 3                               Micro RNA expression profiling using NanoString technology from IgA Nephropathy patients and Non-IgA nephropathy patients from Indian cohort
#> 4                                                                      Protective IFIH1 variant reduces islet stress and dysfunction in a type 1 diabetes genetic background
#> 5              Single-nucleus and bulk transcriptomic atlas of human visceral adipose tissue across metabolic disease states identifies THBS1 as a fibro-inflammatory driver
#> 6                                                                  Engineering the insulin signal peptide to protect human pancreatic beta cells from autoimmune destruction
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             Summary
#> 1 Endothelial dysfunction is a major contributor to diabetic vascular complications, yet the mechanisms linking hyperglycemia to impaired endothelial homeostasis remain insufficiently defined. This study identifies calpains as key regulators of endothelial autophagy and mitophagy under diabetic conditions. In HUVECs and primary lung endothelial cells, hyperglycemia activated calpains and induced autophagic flux blockade, characterized by SQSTM1 accumulation, reduced LC3B expression, and impaired mitophagy associated with mitochondrial fragmentation. more...
#> 2                                                                                                                                              Suppressor transfer RNAs (sup-tRNAs) can rescue disease-causing nonsense mutations by promoting readthrough of premature termination codons (PTCs). Their clinical translation is limited by suboptimal activity and inefficient in vivo delivery. In this work, we combined site-specific chemical modification of sup-tRNAs with cargo-tailored pulmonary lipid nanoparticle (LNP) engineering to overcome these barriers. more...
#> 3                                                                                                   The current study makes use of NanoString targeted technology to profile urinary exosomal miRNAs from IgA nephropathy affected patients and corresponding healthy controls. In addition to IgA nephropathy, disease controls belonging to the condition of Lupus nephritis, Focal segmental glomerulosclerosis, Diabetic nephropathy, Minimal change disease, Membranous nephropathy and Hypertensive nephropathy were also assayed for their miRNA expression profile. more...
#> 4                                          Genome-wide association studies have identified IFIH1, which encodes the double-stranded RNA sensor MDA5, as a type 1 diabetes (T1D) risk locus. The IFIH1 E627* variant is associated with protection from T1D, whereas A946T is associated with increased risk. To examine how these variants influence islet responses to inflamattory and viral stress, we used CRISPR-Cas9 to engineer E627* or A946T into human pluripotent stem cells from a T1D donor and differentiated them into stem cell-derived islets (SC-islets). more...
#> 5                                                                                                                          The cellular complexity of adipose tissue plays a critical role in the pathogenesis of metabolic disease; however, mechanisms underlying adipose dysfunction remain poorly understood. Here, we constructed a single-nucleus and bulk transcriptomic atlas of human visceral adipose tissues from an ethnically homogeneous cohort with defined metabolic states: lean with normal glucose tolerance, obesity, and obesity with type 2 diabetes. more...
#> 6                                                                                                                              The autoreactive T cells that destroy beta cells in type 1 diabetes are largely targeting insulin signal peptide fragments. HLA knockout beta-cells have been proposed to create hypo-immune cells, but this strategy poses significant tumorigenic risks. As an alternative, we hypothesized that insulin signal peptide modification would give rise to beta-cells evading autoimmune recognition while maintaining insulin functionality. more...
#>       Organism                                               Type
#> 1 Homo sapiens Expression profiling by high throughput sequencing
#> 2 Homo sapiens                                              Other
#> 3 Homo sapiens                                              Other
#> 4 Homo sapiens Expression profiling by high throughput sequencing
#> 5 Homo sapiens Expression profiling by high throughput sequencing
#> 6 Homo sapiens Expression profiling by high throughput sequencing
#>                                                                          FTP download
#> 1       GEO (RESULTS, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE339nnn/GSE339355/
#> 2                GEO (CSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE326nnn/GSE326462/
#> 3                GEO (RCC) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE263nnn/GSE263198/
#> 4      GEO (CSV, MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE318nnn/GSE318038/
#> 5 GEO (CSV, MTX, TSV, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE342nnn/GSE342773/
#> 6                GEO (TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE324nnn/GSE324575/
#>          ID Project SRA Run Selector   Contains Datasets Platforms
#> 1 200339355    <NA>             <NA> 12 Samples     <NA>  GPL18573
#> 2 200326462    <NA>             <NA> 27 Samples     <NA>  GPL34281
#> 3 200263198    <NA>             <NA> 41 Samples     <NA>  GPL33820
#> 4 200318038    <NA>             <NA>  2 Samples     <NA>  GPL24676
#> 5 200342773    <NA>             <NA> 39 Samples     <NA>  GPL24676
#> 6 200324575    <NA>             <NA>  6 Samples     <NA>  GPL18573
#>   Series Accession
#> 1        GSE339355
#> 2        GSE326462
#> 3        GSE263198
#> 4        GSE318038
#> 5        GSE342773
#> 6        GSE324575
# }
```
