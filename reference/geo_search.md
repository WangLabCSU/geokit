# Search GEO database

Search the [GDS](https://www.ncbi.nlm.nih.gov/gds) database and return
search results as a
[data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html).

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
# restrictions and limited bandwidth usage for large queries. To avoid
# interruptions due to network issues or rate limits, we wrap the call with
# try().
try(geo_search("diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"))
#> ■■■■■■■■■                        500/1765 [378/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1766/1765 [374/s] | ETA:  0s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1766/1765 [374/s] | ETA:  0s
#> Get records from NCBI for 1765 queries in 4.9s
#> 
#>                                                                                                                                    Title
#>                                                                                                                                   <char>
#>    1:    Functional gene regulatory networks and broad applications of the human expandable pancreatic progenitor-islet system [RNA-Seq]
#>    2: Functional gene regulatory networks and broad applications of the human expandable pancreatic progenitor-islet system [snATAC-seq]
#>    3:  Functional gene regulatory networks and broad applications of the human expandable pancreatic progenitor-islet system [scRNA-Seq]
#>    4:              Metabolic surgery mitigates early kidney injury in obese youth with diabetes by suppressing mTORC1/JAK–STAT signaling
#>    5:                    A stem cell knockout village reveals lineage rewiring and a non-canonical islet cell fate in monogenic diabetes
#>   ---                                                                                                                                   
#> 1761:                                          Gestational Diabetes Induces Placental Genes for Chronic Stress and Inflammatory Pathways
#> 1762:                                                           laughter regulates postprandial blood glucose levels and gene expression
#> 1763:                                                                                                               Diabetic nephropathy
#> 1764:                                                                                      Muscle - atypical diabetes protein expression
#> 1765:                                                                                             Type 2 diabetes and insulin resistance
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               Summary
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                <char>
#>    1: Investigating the precise gene regulatory programs directing pancreatic differentiation provides insights into the mechanisms of pancreatic development and diabetes progression. Here, we performed integrated single-cell multi-omic analyses of the expandable pancreatic progenitor (ePP)-islet system. We defined the dynamic transcriptomic and chromatin landscapes of pancreatic differentiation, inferred the sophisticated gene regulatory networks (GRNs) that govern ePP self-renewal, endocrine specification and islet function, and identified the essential roles and interesting mechanisms of the NKX2.2-CLEC16A/endosomal pathway axis during cell-fate transitions. more...
#>    2: Investigating the precise gene regulatory programs directing pancreatic differentiation provides insights into the mechanisms of pancreatic development and diabetes progression. Here, we performed integrated single-cell multi-omic analyses of the expandable pancreatic progenitor (ePP)-islet system. We defined the dynamic transcriptomic and chromatin landscapes of pancreatic differentiation, inferred the sophisticated gene regulatory networks (GRNs) that govern ePP self-renewal, endocrine specification and islet function, and identified the essential roles and interesting mechanisms of the NKX2.2-CLEC16A/endosomal pathway axis during cell-fate transitions. more...
#>    3: Investigating the precise gene regulatory programs directing pancreatic differentiation provides insights into the mechanisms of pancreatic development and diabetes progression. Here, we performed integrated single-cell multi-omic analyses of the expandable pancreatic progenitor (ePP)-islet system. We defined the dynamic transcriptomic and chromatin landscapes of pancreatic differentiation, inferred the sophisticated gene regulatory networks (GRNs) that govern ePP self-renewal, endocrine specification and islet function, and identified the essential roles and interesting mechanisms of the NKX2.2-CLEC16A/endosomal pathway axis during cell-fate transitions. more...
#>    4:                              Background Youth with type 2 diabetes (T2D) and severe obesity face high risk of diabetic kidney disease, which metabolic bariatric surgery (MBS) can mitigate. This study explores structural and molecular changes in kidneys after vertical sleeve gastrectomy (VSG), a form of MBS. Methods Paired analyses, including metabolic profiling, kidney volume assessment, histological evaluation, and single-cell RNA sequencing (scRNAseq) on kidney biopsies from five youth with T2D and obesity pre- and 12 months post-VSG in the IMPROVE-T2D (Impact of Metabolic surgery on Pancreatic, Renal and cardiOVascular hEalth in youth with T2D) cohort. more...
#>    5:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     This SuperSeries is composed of the SubSeries listed below.
#>   ---                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
#> 1761:                                                                                                                                                                          A physiological state of insulin resistance is required to preferentially direct maternal nutrients toward the feto-placental unit, allowing adequate growth of the fetus. When women develop gestational diabetes mellitus (GDM), insulin resistance is more severe and disrupts the intrauterine milieu, resulting in accelerated fetal development with increased risk of macrosomia. As a natural interface between mother and fetus, the placenta is the obligatory target of such environmental changes. more...
#> 1762:                                                                                                                                                                                                                                                                                                                                                                                                                       Sample tissue: peripheral blood Disease: diabetes Samples for gene expression analysis were obtained before the meal and 1.5 hours after the event. Event: listening to a Japanese comic story or a monotonous academic lecture without humor. Keywords: equivalent probe
#> 1763:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Gene expression profiling in glomeruli from human kidneys with diabetic nephropathy Keywords = Diabetes Keywords = kidney Keywords = glomeruli Keywords: other
#> 1764:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Skeletal muscle biopsies from atypical diabetics at presentation and remission. Protein expression determined with antibody arrays Keywords: other
#> 1765:                                                                                                                                                                                                                                                                                                                          Global transcript profiling to identify differentially expressed skeletal muscle genes in insulin resistance, a major risk factor for Type II (non-insulin-dependent) diabetes mellitus.  Compared gene expression profiles of skeletal muscle tissues from 18 insulin-sensitive versus 17 insulin-resistant equally obese, non-diabetic Pima Indians. Keywords: other
#>           Organism
#>             <char>
#>    1: Homo sapiens
#>    2: Homo sapiens
#>    3: Homo sapiens
#>    4: Homo sapiens
#>    5: Homo sapiens
#>   ---             
#> 1761: Homo sapiens
#> 1762: Homo sapiens
#> 1763: Homo sapiens
#> 1764: Homo sapiens
#> 1765: Homo sapiens
#>                                                                   Type
#>                                                                 <char>
#>    1:               Expression profiling by high throughput sequencing
#>    2: Genome binding/occupancy profiling by high throughput sequencing
#>    3:               Expression profiling by high throughput sequencing
#>    4:               Expression profiling by high throughput sequencing
#>    5:               Expression profiling by high throughput sequencing
#>   ---                                                                 
#> 1761:                                    Expression profiling by array
#> 1762:                                    Expression profiling by array
#> 1763:                                    Expression profiling by array
#> 1764:                               Protein profiling by protein array
#> 1765:                                    Expression profiling by array
#>                                                                             FTP download
#>                                                                                   <char>
#>    1:               GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284159/
#>    2: GEO (CSV, H5, TBI, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284103/
#>    3:          GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284101/
#>    4:          GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE315nnn/GSE315877/
#>    5:                     GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE315nnn/GSE315753/
#>   ---                                                                                   
#> 1761:                         GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE2nnn/GSE2956/
#> 1762:                         GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE1nnn/GSE1322/
#> 1763:                   GEO (CEL) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE1nnn/GSE1009/
#> 1764:                           GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE634/
#> 1765:                           GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE121/
#>              ID SRA Run Selector Project                       Contains
#>           <int>           <char>  <char>                         <char>
#>    1: 200284159             <NA>    <NA>                     12 Samples
#>    2: 200284103             <NA>    <NA>                      3 Samples
#>    3: 200284101             <NA>    <NA>                      5 Samples
#>    4: 200315877             <NA>    <NA>                     16 Samples
#>    5: 200315753             <NA>    <NA>                     21 Samples
#>   ---                                                                  
#> 1761: 200002956             <NA>    <NA>                       1 Sample
#> 1762: 200001322             <NA>    <NA>                     21 Samples
#> 1763: 200001009             <NA>    <NA>                      6 Samples
#> 1764: 200000634             <NA>    <NA>                      4 Samples
#> 1765: 200000121             <NA>    <NA> 5 related Platforms 50 Samples
#>                                 Datasets Platforms Series Accession
#>                                   <char>    <char>           <char>
#>    1:                               <NA>  GPL24676        GSE284159
#>    2:                               <NA>  GPL21697        GSE284103
#>    3:                               <NA>  GPL21697        GSE284101
#>    4:                               <NA>  GPL11154        GSE315877
#>    5:                               <NA>  GPL34281        GSE315753
#>   ---                                                              
#> 1761:                               <NA>    GPL310          GSE2956
#> 1762:                               <NA>    GPL887          GSE1322
#> 1763:                             GDS961   GPL8300          GSE1009
#> 1764:                               <NA>    GPL120           GSE634
#> 1765: GDS157 GDS158 GDS160 GDS161 GDS162      <NA>           GSE121
```
