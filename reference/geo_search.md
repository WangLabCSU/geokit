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
geo_search("diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]")
#> ■■■■■■■■■■■■■■■■■■               1000/1762 [476/s] | ETA:  2s
#> → Parsing GEO records
#> ■■■■■■■■■■■■■■■■■■               1000/1762 [476/s] | ETA:  2s
#> Get records from NCBI for 1762 queries in 4.5s
#> 
#>                                                                                                                            Title
#>                                                                                                                           <char>
#>    1:      Metabolic surgery mitigates early kidney injury in obese youth with diabetes by suppressing mTORC1/JAK–STAT signaling
#>    2:            A stem cell knockout village reveals lineage rewiring and a non-canonical islet cell fate in monogenic diabetes
#>    3:                          Natural daylight during office hours improves glucose control and whole-body substrate metabolism
#>    4: Epigenome-wide association study of differential DNA-methylation in background mucosa among adults with colorectal adenoma
#>    5:                                      HUMAN ALVEOLAR MACROPHAGE FUNCTION IS IMPAIRED IN TUBERCULOSIS CONTACTS WITH DIABETES
#>   ---                                                                                                                           
#> 1758:                                  Gestational Diabetes Induces Placental Genes for Chronic Stress and Inflammatory Pathways
#> 1759:                                                   laughter regulates postprandial blood glucose levels and gene expression
#> 1760:                                                                                                       Diabetic nephropathy
#> 1761:                                                                              Muscle - atypical diabetes protein expression
#> 1762:                                                                                     Type 2 diabetes and insulin resistance
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Summary
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   <char>
#>    1: Background Youth with type 2 diabetes (T2D) and severe obesity face high risk of diabetic kidney disease, which metabolic bariatric surgery (MBS) can mitigate. This study explores structural and molecular changes in kidneys after vertical sleeve gastrectomy (VSG), a form of MBS. Methods Paired analyses, including metabolic profiling, kidney volume assessment, histological evaluation, and single-cell RNA sequencing (scRNAseq) on kidney biopsies from five youth with T2D and obesity pre- and 12 months post-VSG in the IMPROVE-T2D (Impact of Metabolic surgery on Pancreatic, Renal and cardiOVascular hEalth in youth with T2D) cohort. more...
#>    2:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        This SuperSeries is composed of the SubSeries listed below.
#>    3:                                                                                               Chronic lack of daylight is increasingly considered as a risk factor for metabolic diseases, such as type 2 diabetes (T2D). In a randomized cross-over design (NCT05263232), 13 individuals with T2D were exposed to natural daylight facilitated through windows vs. constant artificial lighting during office hours for 4.5 consecutive days. Continuous glucose monitoring revealed that participants spent more time in the normal glucose range and whole-body substrate metabolism shifted towards a greater reliance on fat oxidation upon daylight. more...
#>    4:                                                                                                                                               Background: Colorectal adenoma is the primary precursor in colorectal cancer development, partially driven by epigenetic alteration occurring at a very early stage. While aberrant DNA-methylations have been observed in mucosa adjacent to primary tumors, this study aimed to investigate whether such alterations exist in distant background mucosa as global defect rather than local transition, and identify adenoma-related CpG sites which may serve as potential targets for early intervention. more...
#>    5:                                                                                                                                                         Patients with type 2 diabetes (T2D) are more susceptible to Mycobacterium tuberculosis (M.tb) infection and severe tuberculosis (TB). The underlying mechanisms contributing to this remain largely unknown. To fill this critical knowledge gap, we obtained human alveolar macrophages (HAMs) and monocyte-derived macrophages (MDMs) from TB-exposed individuals with and without T2D in South Africa. We infected HAMs and MDMs ex vivo with live M.tb then collected RNA for RNAseq after 2, 24, 72h.
#>   ---                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
#> 1758:                                                                                                                                             A physiological state of insulin resistance is required to preferentially direct maternal nutrients toward the feto-placental unit, allowing adequate growth of the fetus. When women develop gestational diabetes mellitus (GDM), insulin resistance is more severe and disrupts the intrauterine milieu, resulting in accelerated fetal development with increased risk of macrosomia. As a natural interface between mother and fetus, the placenta is the obligatory target of such environmental changes. more...
#> 1759:                                                                                                                                                                                                                                                                                                                                                                                          Sample tissue: peripheral blood Disease: diabetes Samples for gene expression analysis were obtained before the meal and 1.5 hours after the event. Event: listening to a Japanese comic story or a monotonous academic lecture without humor. Keywords: equivalent probe
#> 1760:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     Gene expression profiling in glomeruli from human kidneys with diabetic nephropathy Keywords = Diabetes Keywords = kidney Keywords = glomeruli Keywords: other
#> 1761:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 Skeletal muscle biopsies from atypical diabetics at presentation and remission. Protein expression determined with antibody arrays Keywords: other
#> 1762:                                                                                                                                                                                                                                                                                             Global transcript profiling to identify differentially expressed skeletal muscle genes in insulin resistance, a major risk factor for Type II (non-insulin-dependent) diabetes mellitus.  Compared gene expression profiles of skeletal muscle tissues from 18 insulin-sensitive versus 17 insulin-resistant equally obese, non-diabetic Pima Indians. Keywords: other
#>           Organism                                               Type
#>             <char>                                             <char>
#>    1: Homo sapiens Expression profiling by high throughput sequencing
#>    2: Homo sapiens Expression profiling by high throughput sequencing
#>    3: Homo sapiens Expression profiling by high throughput sequencing
#>    4: Homo sapiens       Methylation profiling by genome tiling array
#>    5: Homo sapiens Expression profiling by high throughput sequencing
#>   ---                                                                
#> 1758: Homo sapiens                      Expression profiling by array
#> 1759: Homo sapiens                      Expression profiling by array
#> 1760: Homo sapiens                      Expression profiling by array
#> 1761: Homo sapiens                 Protein profiling by protein array
#> 1762: Homo sapiens                      Expression profiling by array
#>                                                                     FTP download
#>                                                                           <char>
#>    1:  GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE315nnn/GSE315877/
#>    2:             GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE315nnn/GSE315753/
#>    3:       GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE309nnn/GSE309688/
#>    4: GEO (IDAT, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE284nnn/GSE284238/
#>    5:      GEO (XLSX) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE283nnn/GSE283452/
#>   ---                                                                           
#> 1758:                 GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE2nnn/GSE2956/
#> 1759:                 GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE1nnn/GSE1322/
#> 1760:           GEO (CEL) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE1nnn/GSE1009/
#> 1761:                   GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE634/
#> 1762:                   GEO ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSEnnn/GSE121/
#>              ID SRA Run Selector Project                       Contains
#>           <int>           <char>  <char>                         <char>
#>    1: 200315877             <NA>    <NA>                     16 Samples
#>    2: 200315753             <NA>    <NA>                     21 Samples
#>    3: 200309688             <NA>    <NA>                     48 Samples
#>    4: 200284238             <NA>    <NA>                     44 Samples
#>    5: 200283452             <NA>    <NA>                     89 Samples
#>   ---                                                                  
#> 1758: 200002956             <NA>    <NA>                       1 Sample
#> 1759: 200001322             <NA>    <NA>                     21 Samples
#> 1760: 200001009             <NA>    <NA>                      6 Samples
#> 1761: 200000634             <NA>    <NA>                      4 Samples
#> 1762: 200000121             <NA>    <NA> 5 related Platforms 50 Samples
#>                                 Datasets Platforms Series Accession
#>                                   <char>    <char>           <char>
#>    1:                               <NA>  GPL11154        GSE315877
#>    2:                               <NA>  GPL34281        GSE315753
#>    3:                               <NA>  GPL24676        GSE309688
#>    4:                               <NA>  GPL33022        GSE284238
#>    5:                               <NA>  GPL21290        GSE283452
#>   ---                                                              
#> 1758:                               <NA>    GPL310          GSE2956
#> 1759:                               <NA>    GPL887          GSE1322
#> 1760:                             GDS961   GPL8300          GSE1009
#> 1761:                               <NA>    GPL120           GSE634
#> 1762: GDS157 GDS158 GDS160 GDS161 GDS162      <NA>           GSE121
```
