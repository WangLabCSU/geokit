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

A
[data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
contains the search results

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
geo_search("diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]")
#> ■■■■■■■■■■                       500/1760 [375/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■      1500/1760 [370/s] | ETA:  1s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■      1500/1760 [370/s] | ETA:  1s
#> Get records from NCBI for 1760 queries in 5.6s
#> 
#>                                                                                                                            Title
#>                                                                                                                           <char>
#>    1:                          Natural daylight during office hours improves glucose control and whole-body substrate metabolism
#>    2: Epigenome-wide association study of differential DNA-methylation in background mucosa among adults with colorectal adenoma
#>    3:                                      HUMAN ALVEOLAR MACROPHAGE FUNCTION IS IMPAIRED IN TUBERCULOSIS CONTACTS WITH DIABETES
#>    4:                                            Defining the vascular niche of human adipose tissue across metabolic conditions
#>    5:                Transcriptomic profiling of senescent human stromal cells upon medicinal intervention with dihydromyricetin
#>   ---                                                                                                                           
#> 1756:                                  Gestational Diabetes Induces Placental Genes for Chronic Stress and Inflammatory Pathways
#> 1757:                                                   laughter regulates postprandial blood glucose levels and gene expression
#> 1758:                                                                                                       Diabetic nephropathy
#> 1759:                                                                              Muscle - atypical diabetes protein expression
#> 1760:                                                                                     Type 2 diabetes and insulin resistance
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Summary
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     <char>
#>    1: Chronic lack of daylight is increasingly considered as a risk factor for metabolic diseases, such as type 2 diabetes (T2D). In a randomized cross-over design (NCT05263232), 13 individuals with T2D were exposed to natural daylight facilitated through windows vs. constant artificial lighting during office hours for 4.5 consecutive days. Continuous glucose monitoring revealed that participants spent more time in the normal glucose range and whole-body substrate metabolism shifted towards a greater reliance on fat oxidation upon daylight. more...
#>    2:                                                 Background: Colorectal adenoma is the primary precursor in colorectal cancer development, partially driven by epigenetic alteration occurring at a very early stage. While aberrant DNA-methylations have been observed in mucosa adjacent to primary tumors, this study aimed to investigate whether such alterations exist in distant background mucosa as global defect rather than local transition, and identify adenoma-related CpG sites which may serve as potential targets for early intervention. more...
#>    3:                                                           Patients with type 2 diabetes (T2D) are more susceptible to Mycobacterium tuberculosis (M.tb) infection and severe tuberculosis (TB). The underlying mechanisms contributing to this remain largely unknown. To fill this critical knowledge gap, we obtained human alveolar macrophages (HAMs) and monocyte-derived macrophages (MDMs) from TB-exposed individuals with and without T2D in South Africa. We infected HAMs and MDMs ex vivo with live M.tb then collected RNA for RNAseq after 2, 24, 72h.
#>    4:                                                 White adipose tissue requires a well-maintained vascular network to function properly. Although advances in single-cell transcriptomics have allowed the development of comprehensive human white adipose tissue atlases, there has been a little focus on deciphering the heterogeneity and the functional states of adipose vascular cells, including blood adipose endothelial cells (AdECs), adipose lymphatic endothelial cells (AdLECs), and mural cells (pericytes and vascular smooth muscle cells). more...
#>    5:  Aging and age-related pathologies can be delayed by specifically targeting the senescence-associated secretory phenotype (SASP), a hallmark feature of senescent cells. Achieving the goal using natural or synthetic agents would have a tremendous impact on the quality of lifespan and burden of age-related chronic diseases. We report the potential of dihydromyricetin (DMY), a bioactive phytochemical constituent that can be found in natural plants such as Rattan tea extract (RTE), in targeting senescent cells via suppression of the SASP. more...
#>   ---                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
#> 1756:                                               A physiological state of insulin resistance is required to preferentially direct maternal nutrients toward the feto-placental unit, allowing adequate growth of the fetus. When women develop gestational diabetes mellitus (GDM), insulin resistance is more severe and disrupts the intrauterine milieu, resulting in accelerated fetal development with increased risk of macrosomia. As a natural interface between mother and fetus, the placenta is the obligatory target of such environmental changes. more...
#> 1757:                                                                                                                                                                                                                                                                                            Sample tissue: peripheral blood Disease: diabetes Samples for gene expression analysis were obtained before the meal and 1.5 hours after the event. Event: listening to a Japanese comic story or a monotonous academic lecture without humor. Keywords: equivalent probe
#> 1758:                                                                                                                                                                                                                                                                                                                                                                                                       Gene expression profiling in glomeruli from human kidneys with diabetic nephropathy Keywords = Diabetes Keywords = kidney Keywords = glomeruli Keywords: other
#> 1759:                                                                                                                                                                                                                                                                                                                                                                                                                   Skeletal muscle biopsies from atypical diabetics at presentation and remission. Protein expression determined with antibody arrays Keywords: other
#> 1760:                                                                                                                                                                                               Global transcript profiling to identify differentially expressed skeletal muscle genes in insulin resistance, a major risk factor for Type II (non-insulin-dependent) diabetes mellitus.  Compared gene expression profiles of skeletal muscle tissues from 18 insulin-sensitive versus 17 insulin-resistant equally obese, non-diabetic Pima Indians. Keywords: other
#>           Organism                                               Type
#>             <char>                                             <char>
#>    1: Homo sapiens Expression profiling by high throughput sequencing
#>    2: Homo sapiens       Methylation profiling by genome tiling array
#>    3: Homo sapiens Expression profiling by high throughput sequencing
#>    4: Homo sapiens Expression profiling by high throughput sequencing
#>    5: Homo sapiens Expression profiling by high throughput sequencing
#>   ---                                                                
#> 1756: Homo sapiens                      Expression profiling by array
#> 1757: Homo sapiens                      Expression profiling by array
#> 1758: Homo sapiens                      Expression profiling by array
#> 1759: Homo sapiens                 Protein profiling by protein array
#> 1760: Homo sapiens                      Expression profiling by array
#>                                                                     FTP download
#>                                                                           <char>
#>    1:       GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE309nnn/GSE309688/
#>    2: GEO (IDAT, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284238/
#>    3:      GEO (XLSX) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE283nnn/GSE283452/
#>    4:  GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE268nnn/GSE268904/
#>    5:      GEO (XLSX) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE190nnn/GSE190280/
#>   ---                                                                           
#> 1756:                 GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE2nnn/GSE2956/
#> 1757:                 GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE1nnn/GSE1322/
#> 1758:           GEO (CEL) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE1nnn/GSE1009/
#> 1759:                   GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE634/
#> 1760:                   GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE121/
#>              ID                                           SRA Run Selector
#>           <int>                                                     <char>
#>    1: 200309688                                                       <NA>
#>    2: 200284238                                                       <NA>
#>    3: 200283452                                                       <NA>
#>    4: 200268904                                                       <NA>
#>    5: 200190280 https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA786574
#>   ---                                                                     
#> 1756: 200002956                                                       <NA>
#> 1757: 200001322                                                       <NA>
#> 1758: 200001009                                                       <NA>
#> 1759: 200000634                                                       <NA>
#> 1760: 200000121                                                       <NA>
#>       Project                       Contains                           Datasets
#>        <char>                         <char>                             <char>
#>    1:    <NA>                     48 Samples                               <NA>
#>    2:    <NA>                     44 Samples                               <NA>
#>    3:    <NA>                     89 Samples                               <NA>
#>    4:    <NA>                     14 Samples                               <NA>
#>    5:    <NA>                      9 Samples                               <NA>
#>   ---                                                                          
#> 1756:    <NA>                       1 Sample                               <NA>
#> 1757:    <NA>                     21 Samples                               <NA>
#> 1758:    <NA>                      6 Samples                             GDS961
#> 1759:    <NA>                      4 Samples                               <NA>
#> 1760:    <NA> 5 related Platforms 50 Samples GDS157 GDS158 GDS160 GDS161 GDS162
#>       Platforms Series Accession
#>          <char>           <char>
#>    1:  GPL24676        GSE309688
#>    2:  GPL33022        GSE284238
#>    3:  GPL21290        GSE283452
#>    4:  GPL28038        GSE268904
#>    5:  GPL11154        GSE190280
#>   ---                           
#> 1756:    GPL310          GSE2956
#> 1757:    GPL887          GSE1322
#> 1758:   GPL8300          GSE1009
#> 1759:    GPL120           GSE634
#> 1760:      <NA>           GSE121
```
