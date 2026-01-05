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
#> ■■■■■■■■■■                       500/1759 [389/s] | ETA:  3s
#> ■■■■■■■■■■■■■■■■■■               1000/1759 [334/s] | ETA:  2s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1760/1759 [321/s] | ETA:  0s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  1760/1759 [321/s] | ETA:  0s
#> Get records from NCBI for 1759 queries in 6.1s
#> 
#>                                                                                                                                             Title
#>                                                                                                                                            <char>
#>    1:                  Epigenome-wide association study of differential DNA-methylation in background mucosa among adults with colorectal adenoma
#>    2:                                                       HUMAN ALVEOLAR MACROPHAGE FUNCTION IS IMPAIRED IN TUBERCULOSIS CONTACTS WITH DIABETES
#>    3:                                                             Defining the vascular niche of human adipose tissue across metabolic conditions
#>    4:                                 Transcriptomic profiling of senescent human stromal cells upon medicinal intervention with dihydromyricetin
#>    5: Transcriptomic profiling of senescent human blood vessel cells upon medicinal intervention with ginkgo boliba extract or rattan tea extract
#>   ---                                                                                                                                            
#> 1755:                                                   Gestational Diabetes Induces Placental Genes for Chronic Stress and Inflammatory Pathways
#> 1756:                                                                    laughter regulates postprandial blood glucose levels and gene expression
#> 1757:                                                                                                                        Diabetic nephropathy
#> 1758:                                                                                               Muscle - atypical diabetes protein expression
#> 1759:                                                                                                      Type 2 diabetes and insulin resistance
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   Summary
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <char>
#>    1:                                                                                                                                                                                                                                                Background: Colorectal adenoma is the primary precursor in colorectal cancer development, partially driven by epigenetic alteration occurring at a very early stage. While aberrant DNA-methylations have been observed in mucosa adjacent to primary tumors, this study aimed to investigate whether such alterations exist in distant background mucosa as global defect rather than local transition, and identify adenoma-related CpG sites which may serve as potential targets for early intervention. more...
#>    2:                                                                                                                                                                                                                                                          Patients with type 2 diabetes (T2D) are more susceptible to Mycobacterium tuberculosis (M.tb) infection and severe tuberculosis (TB). The underlying mechanisms contributing to this remain largely unknown. To fill this critical knowledge gap, we obtained human alveolar macrophages (HAMs) and monocyte-derived macrophages (MDMs) from TB-exposed individuals with and without T2D in South Africa. We infected HAMs and MDMs ex vivo with live M.tb then collected RNA for RNAseq after 2, 24, 72h.
#>    3:                                                                                                                                                                                                                                                White adipose tissue requires a well-maintained vascular network to function properly. Although advances in single-cell transcriptomics have allowed the development of comprehensive human white adipose tissue atlases, there has been a little focus on deciphering the heterogeneity and the functional states of adipose vascular cells, including blood adipose endothelial cells (AdECs), adipose lymphatic endothelial cells (AdLECs), and mural cells (pericytes and vascular smooth muscle cells). more...
#>    4:                                                                                                                                                                                                 Aging and age-related pathologies can be delayed by specifically targeting the senescence-associated secretory phenotype (SASP), a hallmark feature of senescent cells. Achieving the goal using natural or synthetic agents would have a tremendous impact on the quality of lifespan and burden of age-related chronic diseases. We report the potential of dihydromyricetin (DMY), a bioactive phytochemical constituent that can be found in natural plants such as Rattan tea extract (RTE), in targeting senescent cells via suppression of the SASP. more...
#>    5: Aging and age-related pathologies can be delayed by specifically targeting the senescence-associated secretory phenotype (SASP), a hallmark feature of senescent cells. Achieving the goal using natural or synthetic agents would have a tremendous impact on the quality of lifespan and burden of age-related chronic diseases. We report the potential of ginkgo boliba extract (GBE), a commonly used dietary supplement and traditional herbal medicine for hundreds of years in China as an antioxidant and free radical scavenger, or rattan tea extract (RTE), a medicinal agent used for many years for the treatment of inflammation, fatty liver, tumor, diabetes and hyperlipidemia, in targeting senescent cells via suppression of the SASP. more...
#>   ---                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
#> 1755:                                                                                                                                                                                                                                              A physiological state of insulin resistance is required to preferentially direct maternal nutrients toward the feto-placental unit, allowing adequate growth of the fetus. When women develop gestational diabetes mellitus (GDM), insulin resistance is more severe and disrupts the intrauterine milieu, resulting in accelerated fetal development with increased risk of macrosomia. As a natural interface between mother and fetus, the placenta is the obligatory target of such environmental changes. more...
#> 1756:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           Sample tissue: peripheral blood Disease: diabetes Samples for gene expression analysis were obtained before the meal and 1.5 hours after the event. Event: listening to a Japanese comic story or a monotonous academic lecture without humor. Keywords: equivalent probe
#> 1757:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Gene expression profiling in glomeruli from human kidneys with diabetic nephropathy Keywords = Diabetes Keywords = kidney Keywords = glomeruli Keywords: other
#> 1758:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Skeletal muscle biopsies from atypical diabetics at presentation and remission. Protein expression determined with antibody arrays Keywords: other
#> 1759:                                                                                                                                                                                                                                                                                                                                                                                              Global transcript profiling to identify differentially expressed skeletal muscle genes in insulin resistance, a major risk factor for Type II (non-insulin-dependent) diabetes mellitus.  Compared gene expression profiles of skeletal muscle tissues from 18 insulin-sensitive versus 17 insulin-resistant equally obese, non-diabetic Pima Indians. Keywords: other
#>           Organism                                               Type
#>             <char>                                             <char>
#>    1: Homo sapiens       Methylation profiling by genome tiling array
#>    2: Homo sapiens Expression profiling by high throughput sequencing
#>    3: Homo sapiens Expression profiling by high throughput sequencing
#>    4: Homo sapiens Expression profiling by high throughput sequencing
#>    5: Homo sapiens Expression profiling by high throughput sequencing
#>   ---                                                                
#> 1755: Homo sapiens                      Expression profiling by array
#> 1756: Homo sapiens                      Expression profiling by array
#> 1757: Homo sapiens                      Expression profiling by array
#> 1758: Homo sapiens                 Protein profiling by protein array
#> 1759: Homo sapiens                      Expression profiling by array
#>                                                                     FTP download
#>                                                                           <char>
#>    1: GEO (IDAT, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284238/
#>    2:      GEO (XLSX) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE283nnn/GSE283452/
#>    3:  GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE268nnn/GSE268904/
#>    4:      GEO (XLSX) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE190nnn/GSE190280/
#>    5:       GEO (XLS) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE173nnn/GSE173592/
#>   ---                                                                           
#> 1755:                 GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE2nnn/GSE2956/
#> 1756:                 GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE1nnn/GSE1322/
#> 1757:           GEO (CEL) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE1nnn/GSE1009/
#> 1758:                   GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE634/
#> 1759:                   GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE121/
#>              ID                                           SRA Run Selector
#>           <int>                                                     <char>
#>    1: 200284238                                                       <NA>
#>    2: 200283452                                                       <NA>
#>    3: 200268904                                                       <NA>
#>    4: 200190280 https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA786574
#>    5: 200173592 https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA726219
#>   ---                                                                     
#> 1755: 200002956                                                       <NA>
#> 1756: 200001322                                                       <NA>
#> 1757: 200001009                                                       <NA>
#> 1758: 200000634                                                       <NA>
#> 1759: 200000121                                                       <NA>
#>       Project                       Contains                           Datasets
#>        <char>                         <char>                             <char>
#>    1:    <NA>                     44 Samples                               <NA>
#>    2:    <NA>                     89 Samples                               <NA>
#>    3:    <NA>                     14 Samples                               <NA>
#>    4:    <NA>                      9 Samples                               <NA>
#>    5:    <NA>                     12 Samples                               <NA>
#>   ---                                                                          
#> 1755:    <NA>                       1 Sample                               <NA>
#> 1756:    <NA>                     21 Samples                               <NA>
#> 1757:    <NA>                      6 Samples                             GDS961
#> 1758:    <NA>                      4 Samples                               <NA>
#> 1759:    <NA> 5 related Platforms 50 Samples GDS157 GDS158 GDS160 GDS161 GDS162
#>       Platforms Series Accession
#>          <char>           <char>
#>    1:  GPL33022        GSE284238
#>    2:  GPL21290        GSE283452
#>    3:  GPL28038        GSE268904
#>    4:  GPL11154        GSE190280
#>    5:  GPL11154        GSE173592
#>   ---                           
#> 1755:    GPL310          GSE2956
#> 1756:    GPL887          GSE1322
#> 1757:   GPL8300          GSE1009
#> 1758:    GPL120           GSE634
#> 1759:      <NA>           GSE121
```
