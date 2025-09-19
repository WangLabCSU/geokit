
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geokit

<!-- badges: start -->

[![R-CMD-check](https://github.com/WangLabCSU/geokit/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/WangLabCSU/geokit/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/WangLabCSU/geokit/graph/badge.svg)](https://app.codecov.io/gh/WangLabCSU/geokit)
<!-- badges: end -->

The goal of `geokit` is to provide a unified interface for most
interactions between R and [GEO
database](https://www.ncbi.nlm.nih.gov/geo/).

## Features

- Low dependency and Consistent design, use
  [`curl`](https://github.com/jeroen/curl) to download all files, and
  utilize [`data.table`](https://github.com/Rdatatable/data.table) to
  implement all reading and preprocessing process. Reducing the
  dependencies is the initial purpose of this package since I have
  experienced several times of code running failure after updating
  packages when using
  [`GEOquery`](https://github.com/seandavi/GEOquery).
- Provide a searching interface of [GEO
  database](https://www.ncbi.nlm.nih.gov/geo/), in this way, we can
  filter the searching results using `R function`.
- Provide a downloading interface of [GEO
  database](https://www.ncbi.nlm.nih.gov/geo/), in this way, we can make
  full use of R to analyze GEO datasets.
- Enable mapping bettween GPL id and Bioconductor annotation package.
- Provide some useful utils function to work with GEO datasets like
  `parse_gsm_list`, `parse_pdata`, `log_trans` and `geo_show`.

## Installation

You can install the development version of `geokit` from
[GitHub](https://github.com/) with:

``` r
if (!requireNamespace("pak")) {
    install.packages("pak",
        repos = sprintf(
            "https://r-lib.github.io/p/pak/devel/%s/%s/%s",
            .Platform$pkgType, R.Version()$os, R.Version()$arch
        )
    )
}
pak::pkg_install("WangLabCSU/geokit")
```

## Vignettes

``` r
library(geokit)
```

### Search GEO database - `geo_search`

The NCBI uses a search term syntax which can be associated with a
specific search field enclosed by a pair of square brackets. So, for
instance `"Homo sapiens[ORGN]"` denotes a search for `Homo sapiens` in
the `“Organism”` field. Details see
<https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html>. We can use the
same term to query our desirable results in `geo_search`. `geo_search`
will parse the searching results and return a `data.frame` object
containing all the records based on the search term. The internal of
`geo_search` is based on
[`rentrez`](https://github.com/ropensci/rentrez) package, which provides
functions working with the [NCBI
Eutils](http://www.ncbi.nlm.nih.gov/books/NBK25500/) API, so we can
utilize `NCBI API key` to increase the downloading speed, details see
<https://docs.ropensci.org/rentrez/articles/rentrez_tutorial.html#rate-limiting-and-api-keys>.

Providing we want ***GSE*** GEO records related to ***human diabetes***,
we can get these records by following code, the returned object is a
`data.frame`:

``` r
diabetes_gse_records <- geo_search(
    "diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
)
#> ■■■■■■■■■■                       500/1690 [484/s] | ETA:  2s
#> ■■■■■■■■■■■■■■■■■■■              1000/1690 [387/s] | ETA:  2s
#> Get records from NCBI for 1690 queries in 4.8s
#> 
#> → Parsing GEO records
head(diabetes_gse_records[1:5])
#>                                                                                                                    Title
#>                                                                                                                   <char>
#> 1:             Coxsackievirus B infection invokes unique cell-type specific responses in primary human pancreatic islets
#> 2: Expression data from type 2 diabetes mellitus adipose-derived stem cells cultured with basic fibroblast growth factor
#> 3:                 Engineered vasculature induces functional maturation of pluripotent stem cell-derived islet organoids
#> 4:                               Recessive TMEM167A variants cause neonatal diabetes, microcephaly and epilepsy syndrome
#> 5:                   Recessive TMEM167A variants cause neonatal diabetes, microcephaly and epilepsy syndrome [scRNA-seq]
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Summary
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       <char>
#> 1:                                                                                                               Coxsackievirus B (CVB) infection has long been considered an environmental factor precipitating Type 1 diabetes (T1D), an autoimmune disease marked by loss of insulin-producing b cells within pancreatic islets. Previous studies have shown CVB infection negatively impacts islet function and viability but do not report on how virus infection individually affects the multiple cell types present in human primary islets. more...
#> 2:                  Diabetes affects ASCs characteristics such as: proliferation, differentiation and angiogenic capacity. MicroRNAs are able to target genes involved in vascular remodeling and promote or inhibit structural changes in the vessel wall. Adipose tissue-derived stem cells (ASCs) have the capacity to contribute to vascular remodeling. We used microarrays to detail the global miRNA expression profile underlying cell differentiation and identified distinct classes of up-regulated and down-regulated genes during this process.
#> 3: Blood vessels play a critical role in pancreatic islet function, yet current methods for deriving islet organoids from human pluripotent stem cells (SC-islets) lack vasculature. We engineered 3D vascularized SC-islet organoids by assembling SC-islet cells, human primary endothelial cells (ECs) and fibroblasts in a non-perfused model and a microfluidic device with perfused vessels. Vasculature improved stimulus-dependent Ca2+ influx into SC-β-cells, a hallmark of β-cell function that is blunted in non-vascularized SC-islets. more...
#> 4:                                  Understanding the genetic causes of diseases affecting pancreatic β cells and neurons can give insights into pathways essential for both cell types. Microcephaly, epilepsy and diabetes syndrome (MEDS) is a congenital disorder with two known aetiological genes, IER3IP1 and YIPF5. Both genes encode proteins involved in endoplasmic reticulum (ER) to Golgi trafficking.  We used genome sequencing to identify 6 individuals with MEDS caused by biallelic variants in the novel disease gene, TMEM167A. more...
#> 5:                                  Understanding the genetic causes of diseases affecting pancreatic β cells and neurons can give insights into pathways essential for both cell types. Microcephaly, epilepsy and diabetes syndrome (MEDS) is a congenital disorder with two known aetiological genes, IER3IP1 and YIPF5. Both genes encode proteins involved in endoplasmic reticulum (ER) to Golgi trafficking.  We used genome sequencing to identify 6 individuals with MEDS caused by biallelic variants in the novel disease gene, TMEM167A. more...
#>                             Organism
#>                               <char>
#> 1:                      Homo sapiens
#> 2: Homo sapiens; synthetic construct
#> 3:                      Homo sapiens
#> 4:                      Homo sapiens
#> 5:                      Homo sapiens
#>                                                  Type
#>                                                <char>
#> 1: Expression profiling by high throughput sequencing
#> 2:                  Non-coding RNA profiling by array
#> 3: Expression profiling by high throughput sequencing
#> 4: Expression profiling by high throughput sequencing
#> 5: Expression profiling by high throughput sequencing
#>                                                                 FTP download
#>                                                                       <char>
#> 1: GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE274nnn/GSE274264/
#> 2:      GEO (CEL) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE283nnn/GSE283040/
#> 3: GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE276nnn/GSE276815/
#> 4:      GEO (CSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE302nnn/GSE302570/
#> 5: GEO (MTX, TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE302nnn/GSE302421/
#>           ID SRA Run Selector Project   Contains Datasets Platforms
#>        <int>           <char>  <char>     <char>   <char>    <char>
#> 1: 200274264             <NA>    <NA> 10 Samples     <NA>  GPL24676
#> 2: 200283040             <NA>    <NA> 16 Samples     <NA>  GPL19117
#> 3: 200276815             <NA>    <NA>  2 Samples     <NA>  GPL24676
#> 4: 200302570             <NA>    <NA> 40 Samples     <NA>  GPL34284
#> 5: 200302421             <NA>    <NA>  3 Samples     <NA>  GPL24676
#>    Series Accession
#>              <char>
#> 1:        GSE274264
#> 2:        GSE283040
#> 3:        GSE276815
#> 4:        GSE302570
#> 5:        GSE302421
```

Then, we can use whatever we’re famaliar to filter the searching
results. Providing we want GSE datasets with at least 6 diabetic
nephropathy samples containing expression profiling. Here is the example
code:

``` r
diabetes_nephropathy_gse_records <- diabetes_gse_records |>
    dplyr::mutate(
        number_of_samples = stringr::str_match(
            Contains, "(\\d+) Samples?"
        )[, 2L, drop = TRUE],
        number_of_samples = as.integer(number_of_samples)
    ) |>
    dplyr::filter(
        dplyr::if_any(
            c(Title, Summary),
            ~ stringr::str_detect(.x, "(?i)diabetes|diabetic")
        ),
        dplyr::if_any(
            c(Title, Summary),
            ~ stringr::str_detect(.x, "(?i)nephropathy")
        ),
        stringr::str_detect(Type, "(?i)expression profiling"),
        number_of_samples >= 6L
    )
head(diabetes_nephropathy_gse_records[1:5])
#>                                                                                                                                Title
#>                                                                                                                               <char>
#> 1:   Endothelial Kallikrein-Related Peptidase 8 Promotes Diabetic Nephropathy via Reducing SDC4 Expression and Enhancing LIF Release
#> 2:         Upregulation of FGF13 promotes type 2 diabetic nephropathy by modulating glomerular endothelial mitochondrial homeostasis
#> 3:                   Sodium Butyrate Ameliorates Renal Tubular Lipid Accumulation Through the PP2A-TFEB axis in Diabetic Nephropathy
#> 4: Deciphering the Transcriptomic Landscape of Type 2 Diabetes: Insights from Bulk RNA Sequencing and Single-Cell Analysis [RNA-seq]
#> 5:                                                                  Effect of overexpssion Kallistatin(SERPINA4) in HGC-27 cell line
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      Summary
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       <char>
#> 1:                                                                                                                                                                                                                                                                                                                                                       The molecular mechanisms underlying diabetic nephropathy (DN) are poorly defined. We sought to investigate the roles of kallikrein-related peptidases (KLKs) in DN pathogenesis. Screening of renal tissue from diabetic mice revealed KLK8 as the most highly induced gene in KLK family. KLK8 expression was greater in glomerular endothelial cells (GECs) than other glomerular cells in DN patients and diabetic mice. more...
#> 2:                                                                                           Studies of diabetic glomerular injury raise the possibility of developing useful early biomarkers and therapeutic approaches for the treatment of type 2 diabetic nephropathy (T2DN). In this study, it is found that FGF13 expression is induced in glomerular endothelial cells (GECs) during T2DN progression, and endothelial-specific deletion of Fgf13 potentially alleviates T2DN damage. Fgf13 deficiency restores the expression of Parkin both in the cytosolic, mitochondrial, and nuclear fractions under diabetic conditions, resulting in improved mitochondrial homeostasis and endothelial barrier integrity due to promotion of mitophagy and inhibition of apoptosis. more...
#> 3:                                                                                                                                                                                                                                                                                                                         Background: Diabetic kidney disease (DKD) is the leading cause of end-stage renal disease worldwide with limited treatment options. The intricate pathogenesis of dysregulated lipid metabolism leading to the development of DKD remains obscure. Lipophagy, which refers to the autophagic degradation of intracellular lipid droplets, has been found to be impaired in DKD, resulting in renal tubule dysfunction and ectopic lipid deposition (ELD). more...
#> 4:                                                                                                                                                            Type 2 diabetes (T2D) is a chronic metabolic disorder characterized by insulin resistance and relative insulin deficiency. It is a significant public health concern worldwide, with an estimated prevalence of over 422 million individuals affected globally. This number is projected to rise, making diabetes one of the leading causes of morbidity and mortality. It is associated with numerous severe microvascular and macrovascular complications, including retinopathy, nephropathy, cardiovascular diseases, and neuropathy, which substantially impact patients' quality of life and healthcare systems. more...
#> 5: Kallistatin has been demonstrated to possess inhibitory effects across several malignancies, including hepatocellular carcinoma, gastric cancer and breast cancer. Subsequent evidence has increasingly suggested that KS has pleiotropic roles in modulating a broad spectrum of diseases, including in diabetic nephropathy, idiopathic pulmonary fibrosis and autoimmune uveitis. However, the precise function and molecular mechanisms underlying tumor-induced immune escape attributed to KS remain unclear, necessitating further investigation to determine its role in this context.For this propose, we establish SERPINA4 stably expressed cell line(and control) in HGC-27 cells, and RNA-seq was performed to reveal the trancriptome changes between there two cell lines.
#>        Organism                                               Type
#>          <char>                                             <char>
#> 1: Homo sapiens Expression profiling by high throughput sequencing
#> 2: Homo sapiens Expression profiling by high throughput sequencing
#> 3: Homo sapiens Expression profiling by high throughput sequencing
#> 4: Homo sapiens Expression profiling by high throughput sequencing
#> 5: Homo sapiens Expression profiling by high throughput sequencing
#>                                                            FTP download
#>                                                                  <char>
#> 1: GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE255nnn/GSE255028/
#> 2: GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE192nnn/GSE192889/
#> 3: GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE266nnn/GSE266108/
#> 4: GEO (TSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE280nnn/GSE280402/
#> 5: GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE262nnn/GSE262922/
#>           ID SRA Run Selector Project   Contains Datasets Platforms
#>        <int>           <char>  <char>     <char>   <char>    <char>
#> 1: 200255028             <NA>    <NA>  9 Samples     <NA>  GPL24676
#> 2: 200192889             <NA>    <NA>  9 Samples     <NA>  GPL24676
#> 3: 200266108             <NA>    <NA>  6 Samples     <NA>  GPL24676
#> 4: 200280402             <NA>    <NA> 16 Samples     <NA>  GPL16791
#> 5: 200262922             <NA>    <NA>  6 Samples     <NA>  GPL20301
#>    Series Accession number_of_samples
#>              <char>             <int>
#> 1:        GSE255028                 9
#> 2:        GSE192889                 9
#> 3:        GSE266108                 6
#> 4:        GSE280402                16
#> 5:        GSE262922                 6
```

After filtering, we got 36 candidate datasets. This can reduce a lot of
time of us comparing with refining datasets by reading the summary
records.

### Download data from GEO database - `geo`

GEO database mainly provides SOFT (Simple Omnibus Format in Text)
formatted files for GPL, GSM and GDS entity. SOFT is designed for rapid
batch submission and download of data. SOFT is a simple line-based,
plain text format, meaning that SOFT files may be readily generated from
common spreadsheet and database applications. A single SOFT file can
hold both data tables and accompanying descriptive information for
multiple, concatenated Platforms, Samples, and/or Series records.
`geokit` provide a `GEOSoft` class object to store SOFT file contents,
`GEOSoft` object contains four slots (“accession”, “meta”, “datatable”,
and “columns”). `accession` slot stores the GEO accession ID, `meta`
slot contains the metadata header in the SOFT formatted file, and
`datatable` slot contains the the data table in SOFT file which is the
main data for us to use, along with a `columns` slot providing
descriptive column header for the `datatable` data. We can use the
function with the same name of these slots to extract the data.

`geo` can download SOFT files and preprocess them well, here is some
example code to get soft file from `GPL`, `GSM` and `GDS` entity
respectively.

``` r
gpl <- geo("gpl98", odir = tempdir())
#> Downloading 1 GPL full amount file from GEO Accession Site
gpl
#> An object of GEOSoft
#> datatable: a 8934 * 16 data.frame
#> columns: a 16 * 1 data.frame
#>   columnsData: labelDescription
#> meta: Platform_contact_address Platform_contact_city
#>   Platform_contact_country ... Platform_title Platform_web_link (26
#>   total)
#> accession: GPL98
head(datatable(gpl))
#>                          ID   GB_ACC SPOT_ID Species Scientific Name
#> AA000993_at     AA000993_at AA000993                    Homo sapiens
#> AA001296_s_at AA001296_s_at AA001296                    Homo sapiens
#> AA002245_at     AA002245_at AA002245                    Homo sapiens
#> AA004231_at     AA004231_at AA004231                    Homo sapiens
#> AA004333_at     AA004333_at AA004333                    Homo sapiens
#> AA004987_at     AA004987_at AA004987                    Homo sapiens
#>               Annotation Date     Sequence Type Sequence Source
#> AA000993_at      Mar 11, 2009 Exemplar sequence         GenBank
#> AA001296_s_at    Mar 11, 2009 Exemplar sequence         GenBank
#> AA002245_at      Mar 11, 2009 Exemplar sequence         GenBank
#> AA004231_at      Mar 11, 2009 Exemplar sequence         GenBank
#> AA004333_at      Mar 11, 2009 Exemplar sequence         GenBank
#> AA004987_at      Mar 11, 2009 Exemplar sequence         GenBank
#>                                                                             Target Description
#> AA000993_at                 ze46h10.r1 Soares retina N2b4HR Homo sapiens cDNA clone 362083 5'.
#> AA001296_s_at zh82b09.r1 Soares fetal liver spleen 1NFLS S1 Homo sapiens cDNA clone 427769 5'.
#> AA002245_at   zh85f01.r1 Soares fetal liver spleen 1NFLS S1 Homo sapiens cDNA clone 428089 5'.
#> AA004231_at   zh92a03.r1 Soares fetal liver spleen 1NFLS S1 Homo sapiens cDNA clone 428716 5'.
#> AA004333_at   zh91a01.r1 Soares fetal liver spleen 1NFLS S1 Homo sapiens cDNA clone 428616 5'.
#> AA004987_at   zh94b01.r1 Soares fetal liver spleen 1NFLS S1 Homo sapiens cDNA clone 428905 5'.
#>               Representative Public ID
#> AA000993_at                   AA000993
#> AA001296_s_at                 AA001296
#> AA002245_at                   AA002245
#> AA004231_at                   AA004231
#> AA004333_at                   AA004333
#> AA004987_at                   AA004987
#>                                                                     Gene Title
#> AA000993_at                                             PR domain containing 8
#> AA001296_s_at                                            PHD finger protein 23
#> AA002245_at                               zinc finger CCCH-type containing 11A
#> AA004231_at                                                                   
#> AA004333_at                                                                   
#> AA004987_at   BMP2 inducible kinase, mRNA (cDNA clone MGC:33000 IMAGE:5272264)
#>               Gene Symbol ENTREZ_GENE_ID       RefSeq Transcript ID
#> AA000993_at         PRDM8          56978 NM_001099403 /// NM_020226
#> AA001296_s_at       PHF23          79142                  NM_024297
#> AA002245_at       ZC3H11A           9877                  NM_014827
#> AA004231_at                                                        
#> AA004333_at                                                        
#> AA004987_at         BMP2K          55589    NM_017593 /// NM_198892
#>                                                                                                                                               Gene Ontology Biological Process
#> AA000993_at   0006350 // transcription // inferred from electronic annotation /// 0006355 // regulation of transcription, DNA-dependent // inferred from electronic annotation
#> AA001296_s_at                                                                                                                                                                 
#> AA002245_at                                                                                                                                                                   
#> AA004231_at                                                                                                                                                                   
#> AA004333_at                                                                                                                                                                   
#> AA004987_at                                                                               0006468 // protein amino acid phosphorylation // inferred from electronic annotation
#>                                                                                                            Gene Ontology Cellular Component
#> AA000993_at   0005622 // intracellular // inferred from electronic annotation /// 0005634 // nucleus // inferred from electronic annotation
#> AA001296_s_at                                                                                                                              
#> AA002245_at                                                                                                                                
#> AA004231_at                                                                                                                                
#> AA004333_at                                                                                                                                
#> AA004987_at                                                                       0005634 // nucleus // inferred from electronic annotation
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                   Gene Ontology Molecular Function
#> AA000993_at                                                                                                                                                                                                                                                           0003677 // DNA binding // inferred from electronic annotation /// 0008270 // zinc ion binding // inferred from electronic annotation /// 0046872 // metal ion binding // inferred from electronic annotation
#> AA001296_s_at                                                                                                                                                                                                                                                     0005515 // protein binding // inferred from electronic annotation /// 0008270 // zinc ion binding // inferred from electronic annotation /// 0046872 // metal ion binding // inferred from electronic annotation
#> AA002245_at                                                                                                                                                                                                                                                  0003676 // nucleic acid binding // inferred from electronic annotation /// 0008270 // zinc ion binding // inferred from electronic annotation /// 0046872 // metal ion binding // inferred from electronic annotation
#> AA004231_at                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
#> AA004333_at                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
#> AA004987_at   0000166 // nucleotide binding // inferred from electronic annotation /// 0004672 // protein kinase activity // inferred from electronic annotation /// 0004674 // protein serine/threonine kinase activity // inferred from electronic annotation /// 0005524 // ATP binding // inferred from electronic annotation /// 0016301 // kinase activity // inferred from electronic annotation /// 0016740 // transferase activity // inferred from electronic annotation
head(columns(gpl))
#>                                                                                                                                                                                                                                                                                                                                                    labelDescription
#> ID                                                                                                                                                                                                                                                                   Affymetrix Probe Set ID LINK_PRE:"https://www.affymetrix.com/LinkServlet?array=U35K&probeset="
#> GB_ACC                                                                                                                                                                                                                                                                               GenBank Accession Number LINK_PRE:"http://www.ncbi.nlm.nih.gov/nuccore/?term="
#> SPOT_ID                                                                                                                                                                                                                                                                                                                                                        <NA>
#> Species Scientific Name                                                                                                                                                                                                                                                                         The genus and species of the organism represented by the probe set.
#> Annotation Date                                                                                                                                                                       The date that the annotations for this probe array were last updated. It will generally be earlier than the date when the annotations were posted on the Affymetrix web site.
#> Sequence Type           Indicates whether the sequence is an Exemplar, Consensus or Control sequence. An Exemplar is a single nucleotide sequence taken directly from a public database. This sequence could be an mRNA or EST. A Consensus sequence, is a nucleotide sequence assembled by Affymetrix, based on one or more sequence taken from a public database.
```

``` r
gsm <- geo("GSM1", odir = tempdir())
#> Downloading 1 GSM full amount file from GEO Accession Site
gsm
#> An object of GEOSoft
#> datatable: a 5494 * 3 data.frame
#> columns: a 3 * 1 data.frame
#>   columnsData: labelDescription
#> meta: Sample_anchor Sample_channel_count Sample_contact_address ...
#>   Sample_title Sample_type (29 total)
#> accession: GSM1
head(datatable(gsm))
#>                   TAG COUNT     TPM
#> AAAAAAAAAA AAAAAAAAAA    17 1741.98
#> AAAAAAATCA AAAAAAATCA     1  102.47
#> AAAAAAATTT AAAAAAATTT     1  102.47
#> AAAAAACAAA AAAAAACAAA     1  102.47
#> AAAAAACTCC AAAAAACTCC     1  102.47
#> AAAAAATAAA AAAAAATAAA     1  102.47
head(columns(gsm))
#>         labelDescription
#> TAG   Ten base SAGE tag,
#> COUNT         TAG NUMBER
#> TPM     tags per million
```

``` r
gds <- geo("GDS10", odir = tempdir())
#> Downloading 1 GDS soft file from FTP site
gds
#> An object of GEOSoft
#> datatable: a 39114 * 30 data.frame
#> columns: a 30 * 4 data.frame
#>   columnsData: labelDescription subset_dataset_id subset_description
#>     subset_type
#> meta: Database_email Database_institute Database_name ...
#>   dataset_update_date dataset_value_type (21 total)
#> accession: GDS10
head(datatable(gds))
#>   ID_REF    IDENTIFIER GSM582 GSM589 GSM583 GSM590 GSM584 GSM591 GSM585 GSM592
#> 1      1 1200011I18Rik    101     54    111     55     87     30     99     43
#> 2      2             2     26     23     30     27     19     22     32     19
#> 3      3       Ccdc28b     NA     NA     NA     NA     NA     NA     NA     NA
#> 4      4      AA014405    233    162    252    178    214    144    238    147
#> 5      5        Crebrf     NA     NA     NA     NA     NA     NA     NA     NA
#> 6      6             6    691    661    696    652    609    665    684    672
#>   GSM586 GSM593 GSM587 GSM594 GSM588 GSM595 GSM596 GSM603 GSM597 GSM604 GSM598
#> 1    105     56     43     14    112     43     97     36    117     40    125
#> 2     24     25     14     49     32     29     31     22     26     26     35
#> 3     NA     NA     NA      7     NA      4     10     22     NA     15     NA
#> 4    250    166     86     22    236    139    216    112    241    130    270
#> 5     NA     NA     NA     NA     NA      3     NA     NA     NA     NA     NA
#> 6    644    679    631    596    609    606    601    557    596    580    601
#>   GSM605 GSM599 GSM606 GSM600 GSM607 GSM601 GSM608 GSM602 GSM609
#> 1     45     99      1    109     38     87     18     72     16
#> 2     26     18     13     25     32     28     40     14     41
#> 3     23     NA     29      9     25     11     40     NA     22
#> 4    144    239    148    211    139    208     16    174     15
#> 5     NA     NA     NA     NA     NA     NA     NA     NA     NA
#> 6    554    562    561    580    568    519    562    497    564
head(columns(gds))
#>                                  labelDescription   subset_dataset_id
#> ID_REF              Platform reference identifier                <NA>
#> IDENTIFIER                             identifier                <NA>
#> GSM582      Value for GSM582: NOD_S1; src: Spleen GDS10; GDS10; GDS10
#> GSM589      Value for GSM589: NOD_S2; src: Spleen GDS10; GDS10; GDS10
#> GSM583     Value for GSM583: Idd3_S1; src: Spleen GDS10; GDS10; GDS10
#> GSM590     Value for GSM590: Idd3_S2; src: Spleen GDS10; GDS10; GDS10
#>                          subset_description                   subset_type
#> ID_REF                                 <NA>                          <NA>
#> IDENTIFIER                             <NA>                          <NA>
#> GSM582                spleen; NOD; diabetic tissue; strain; disease state
#> GSM589                spleen; NOD; diabetic tissue; strain; disease state
#> GSM583     spleen; Idd3; diabetic-resistant tissue; strain; disease state
#> GSM590     spleen; Idd3; diabetic-resistant tissue; strain; disease state
```

For GSE entity, there is also a soft file associated with it. But the
structure is different with `GPL`, `GSM` and `GDS` entity, `geokit`
provide `GEOSeries` class to keep contents in GSE soft file. Actually, a
GSE soft file contains almost all contents in its subsets soft file
including both `GPL` and `GSM`, so `GEOSeries` class provides both `gpl`
and `gsm` slots as a list of `GEOSoft`. To download GSE soft file, we
just set `gse_matrix` to `FALSE` in `geo` function.

``` r
gse <- geo("GSE10", odir = tempdir(), gse_matrix = FALSE)
#> Downloading 1 GSE soft file from FTP site
gse
#> An object of GEOSeries
#> gsm: GSM571 GSM572 GSM573 GSM574
#> gpl: GPL4
#> meta: Database_email Database_institute Database_name ... Series_title
#>   Series_type (31 total)
#> accession: GSE10
```

It’s more common to use a series matrix file in our usual analysis
workflow, we can also handle it easily in `geokit`, as what we need to
do is just set `gse_matrix` to `TRUE` in `geo` function, which is also
the default value. When `gse_matrix` is `TRUE`, `geo` will return a
`ExpressionSet` object which can interact with lots of Bioconductor
packages. There are two parameters controling the processing details
when parsing series matrix file. When parsing phenoData from series
matrix files directly, it’s common to fail to discern
`characteristics_ch*` columns, which contain the important traits
informations of corresponding samples, since many `characteristics_ch*`
columns in series matrix files often lacks separate strings.
`pdata_from_soft`, which indicates whether retrieve phenoData from GEO
Soft file, can help handle this problem well. When the soft file is
large and we don’t want to use it, we can set `pdata_from_soft` to
`FALSE` and use `parse_pdata` function to parse it manully. Another
important parameter is `add_gpl`, where `FALSE` indicates `geo` will try
to map the current GPL accession id into a Bioconductor annotation
package, then we can use the latest bioconductor annotation package to
get the up-to-date featureData, otherwise, `geo` will add featureData
from GPL soft file directly.

``` r
gse_matix <- geo("GSE10", odir = tempdir())
#> Downloading 1 GSE matrix file from FTP site
#> Finding 1 {.strong GSE} {.field soft} file already downloaded:
#> 'GSE10_family.soft.gz'
#> → Parsing series soft file 'GSE10_family.soft.gz'
#> 
#> ✔ Parsing 1 series soft file successfully!
#> 
#> → Parsing 1 series matrix file of GSE10
#> 
#> ✔ Parsing 1 GSE series matrix successfully!
#> 
#> → Constructing <ExpressionSet>
#> 
#> ✔ Found Bioconductor annotation package for "GPL4"
#> 
#> Downloading 1 GPL annot file from FTP site
#> ℹ annot file in FTP site for "GPL4" is not available, so will use data amount file from GEO Accession Site instead
#> 
#> Downloading 1 GPL data amount file from GEO Accession Site
gse_matix
#> ExpressionSet (storageMode: lockedEnvironment)
#> assayData: 96903 features, 4 samples 
#>   element names: exprs 
#> protocolData: none
#> phenoData
#>   sampleNames: GSM571 GSM572 GSM573 GSM574
#>   varLabels: anchor channel_count ... type (32 total)
#>   varMetadata: labelDescription
#> featureData
#>   featureNames: AAAAAAAAAA AAAAAAAAAC ... TTTTTTTTTT (96903 total)
#>   fvarLabels: TAG GI
#>   fvarMetadata: labelDescription
#> experimentData: use 'experimentData(object)'
#>   pubMedIds: 11756676 
#> Annotation: GPL4
```

``` r
gse_matrix_with_pdata <- geo(
    "gse53987",
    odir = tempdir(),
    pdata_from_soft = FALSE,
    add_gpl = FALSE
)
#> Downloading 1 GSE matrix file from FTP site
#> → Parsing 1 series matrix file of GSE53987
#> Warning: Cannot parse characteristic column correctly
#> ℹ Details see "characteristics_ch1" column in phenoData
#> ℹ Please use `parse_pdata()` or `parse_gsm_list()` function to convert it
#>   manually if necessary!
#> ✔ Parsing 1 GSE series matrix successfully!
#> → Constructing <ExpressionSet>
#> ✔ Found Bioconductor annotation package for "GPL570"
gse_matrix_smp_info <- Biobase::pData(gse_matrix_with_pdata)
gse_matrix_smp_info$characteristics_ch1 <- stringr::str_replace_all(
    gse_matrix_smp_info$characteristics_ch1,
    "gender|race|pmi|ph|rin|tissue|disease state",
    function(x) paste0("; ", x)
)
gse_matrix_smp_info <- parse_pdata(gse_matrix_smp_info)
gse_matrix_smp_info[grepl(
    "^ch1_|characteristics_ch1", names(gse_matrix_smp_info)
)]
#>            ch1_age ch1_gender ch1_race ch1_pmi ch1_ph ch1_rin
#> GSM1304852      52          M        W   23.50   6.70     6.3
#> GSM1304853      50          F        W   11.70   6.40     6.8
#> GSM1304854      28          F        W   22.30   6.30     7.7
#> GSM1304855      55          F        W   17.50   6.40     7.6
#> GSM1304856      58          M        W   27.70   6.80     7.0
#> GSM1304857      28          M        W   27.40   6.20     7.7
#> GSM1304858      49          F        W   21.50   6.70     8.2
#> GSM1304859      42          F        W   31.20   6.50     5.6
#> GSM1304860      43          F        W   31.90   6.70     6.3
#> GSM1304861      50          M        W   12.10   6.70     7.4
#> GSM1304862      40          M        W   18.50   6.40     6.5
#> GSM1304863      39          F        W   22.20   6.70     7.9
#> GSM1304864      45          M        W   27.20   7.10     8.1
#> GSM1304865      42          M        W   12.50   6.70     8.2
#> GSM1304866      65          M        W    8.90   6.70     6.6
#> GSM1304867      51          F        W   21.50   6.70     7.0
#> GSM1304868      39          M        W   24.20   6.60     7.8
#> GSM1304869      48          M        W   18.10   6.90     7.0
#> GSM1304870      51          M        W   24.20   6.60     7.8
#> GSM1304871      51          F        W    7.80   6.60     7.2
#> GSM1304872      36          F        W   14.50   6.40     8.0
#> GSM1304873      65          F        W   18.50   6.50     7.0
#> GSM1304874      55          M        W   28.00   6.10     6.8
#> GSM1304875      22          M        W   20.10   6.80     7.1
#> GSM1304876      52          F        W   22.60   7.10     7.0
#> GSM1304877      58          F        W   22.70   6.40     6.3
#> GSM1304878      40          F        B   16.60   6.80     7.9
#> GSM1304879      41          F        W   15.40   6.60     8.5
#> GSM1304880      49          M        W   21.20   6.50     7.8
#> GSM1304881      48          M        W   21.68   6.60     7.3
#> GSM1304882      39          F        W   24.50   6.80     8.2
#> GSM1304883      48          M        W   24.50   6.50     7.0
#> GSM1304884      43          M        W   13.80   6.60     7.6
#> GSM1304885      68          M        W   11.80   6.80     6.1
#> GSM1304886      58          F        W   18.80   6.60     7.2
#> GSM1304887      43          M        W   22.30   6.70     7.9
#> GSM1304888      51          M        W   24.60   6.50     7.7
#> GSM1304889      53          F        W   11.90   6.70     8.1
#> GSM1304890      26          F        W   13.40   6.40     7.5
#> GSM1304891      52          F        W   10.30   6.50     6.6
#> GSM1304892      62          M        W   26.00   6.50     6.8
#> GSM1304893      29          M        W   26.60   6.90     7.8
#> GSM1304894      49          F        W   23.40   6.40     6.2
#> GSM1304895      54          F        W   17.90   6.20     6.1
#> GSM1304896      28          F        B   24.80   6.60     8.2
#> GSM1304897      42          M        W   14.30   6.40     6.2
#> GSM1304898      44          M        W   19.30   6.50     6.3
#> GSM1304899      40          F        W   22.20   6.60     8.0
#> GSM1304900      47          M        W   24.00   6.60     5.5
#> GSM1304901      59          M        W   13.00   6.60     7.2
#> GSM1304902      47          F        W   22.30   6.60     6.5
#> GSM1304903      34          M        W   24.40   6.60     8.4
#> GSM1304904      51          M        W   28.30   7.30     7.0
#> GSM1304905      49          M        W   21.50   5.97     6.0
#> GSM1304906      47          F        W   14.37   6.35     6.3
#> GSM1304907      25          F        B   20.10   6.73     5.6
#> GSM1304908      62          M        W   22.70   7.14     6.3
#> GSM1304909      44          F        W   24.50   6.63     7.8
#> GSM1304910      46          F        W   23.80   6.61     6.9
#> GSM1304911      50          M        W   11.00   6.23     7.2
#> GSM1304912      46          M        W   15.80   6.19     6.2
#> GSM1304913      41          F        W   20.10   6.27     6.7
#> GSM1304914      47          M        W   28.90   6.58     6.7
#> GSM1304915      37          M        B    5.98   6.07     6.4
#> GSM1304916      58          M        W    7.70   6.22     6.7
#> GSM1304917      44          F        B   18.70   6.20     6.4
#> GSM1304918      38          M        W   28.80   6.56     6.6
#> GSM1304919      52          M        B   27.10   6.68     6.3
#> GSM1304920      52          M        W   23.50   6.70     7.2
#> GSM1304921      50          F        W   11.70   6.40     8.6
#> GSM1304922      28          F        W   22.30   6.30     8.6
#> GSM1304923      55          F        W   17.50   6.40     8.0
#> GSM1304924      58          M        W   27.70   6.80     7.5
#> GSM1304925      28          M        W   27.40   6.20     7.9
#> GSM1304926      49          F        W   21.50   6.70     8.1
#> GSM1304927      56          F        W   24.50   6.10     6.9
#> GSM1304928      50          M        W   12.10   6.70     7.6
#> GSM1304929      40          M        W   18.50   6.40     7.9
#> GSM1304930      39          F        W   22.20   6.70     7.8
#> GSM1304931      45          M        W   27.20   7.10     7.3
#> GSM1304932      42          M        W   12.50   6.70     7.6
#> GSM1304933      65          M        W    8.90   6.70     6.9
#> GSM1304934      51          F        W   21.50   6.70     7.7
#> GSM1304935      39          M        W   24.20   6.60     7.3
#> GSM1304936      48          M        W   18.10   6.90     8.2
#> GSM1304937      51          M        W   24.20   6.60     7.9
#> GSM1304938      51          F        W    7.80   6.60     8.6
#> GSM1304939      36          F        W   14.50   6.40     8.6
#> GSM1304940      65          F        W   18.50   6.50     8.3
#> GSM1304941      55          M        W   28.00   6.10     7.9
#> GSM1304942      22          M        W   20.10   6.80     8.1
#> GSM1304943      52          F        W   22.60   7.10     8.2
#> GSM1304944      58          F        W   22.70   6.40     8.0
#> GSM1304945      40          F        B   16.60   6.80     8.2
#> GSM1304946      41          F        W   15.40   6.60     8.2
#> GSM1304947      49          M        W   21.20   6.50     7.9
#> GSM1304948      48          M        W   21.68   6.60     7.5
#> GSM1304949      39          F        W   24.50   6.80     7.4
#> GSM1304950      48          M        W   24.50   6.50     6.8
#> GSM1304951      43          M        W   13.80   6.60     7.5
#> GSM1304952      68          M        W   11.80   6.80     6.7
#> GSM1304953      58          F        W   18.80   6.60     8.7
#> GSM1304954      43          M        W   22.30   6.70     8.0
#> GSM1304955      46          M        W   22.00   6.30     6.6
#> GSM1304956      51          M        W   24.60   6.50     7.8
#> GSM1304957      53          F        W   11.90   6.70     8.4
#> GSM1304958      26          F        W   13.40   6.40     8.4
#> GSM1304959      52          F        W   10.30   6.50     8.1
#> GSM1304960      62          M        W   26.00   6.50     7.8
#> GSM1304961      29          M        W   26.60   6.90     8.2
#> GSM1304962      49          F        W   23.40   6.40     7.6
#> GSM1304963      54          F        W   17.90   6.20     7.5
#> GSM1304964      28          F        B   24.80   6.60     7.9
#> GSM1304965      42          M        W   14.30   6.40     8.4
#> GSM1304966      40          F        W   22.20   6.60     7.7
#> GSM1304967      47          M        W   24.00   6.60     6.8
#> GSM1304968      44          M        W   11.00   6.50     7.2
#> GSM1304969      59          M        W   13.00   6.60     7.7
#> GSM1304970      47          F        W   22.30   6.60     6.7
#> GSM1304971      34          M        W   24.40   6.60     7.8
#> GSM1304972      51          M        W   28.30   7.30     7.7
#> GSM1304973      49          M        W   21.50   5.97     7.0
#> GSM1304974      47          F        W   14.37   6.35     9.0
#> GSM1304975      25          F        B   20.10   6.73     7.2
#> GSM1304976      41          F        W   17.10   6.90     8.3
#> GSM1304977      62          M        W   22.70   7.14     8.1
#> GSM1304978      47          F        B   20.10   7.30     8.1
#> GSM1304979      44          F        W   24.50   6.63     7.6
#> GSM1304980      46          F        W   23.80   6.61     8.0
#> GSM1304981      50          M        W   11.00   6.23     8.4
#> GSM1304982      41          F        W   20.10   6.27     7.4
#> GSM1304983      47          M        W   28.90   6.58     7.0
#> GSM1304984      37          M        B    5.98   6.07     6.3
#> GSM1304985      58          M        W    7.70   6.22     7.3
#> GSM1304986      44          F        B   18.70   6.20     7.6
#> GSM1304987      52          M        B   27.10   6.68     7.4
#> GSM1304988      50          M        W   12.10   6.70     8.6
#> GSM1304989      40          M        W   18.50   6.40     8.4
#> GSM1304990      39          F        W   22.20   6.70     9.1
#> GSM1304991      45          M        W   27.20   7.10     8.7
#> GSM1304992      42          M        W   12.50   6.70     8.7
#> GSM1304993      65          M        W    8.90   6.70     8.3
#> GSM1304994      51          F        W   21.50   6.70     8.4
#> GSM1304995      39          M        W   24.20   6.60     8.5
#> GSM1304996      48          M        W   18.10   6.90     8.8
#> GSM1304997      52          M        W   23.50   6.70     9.1
#> GSM1304998      50          F        W   11.70   6.40     8.4
#> GSM1304999      28          F        W   22.30   6.30     9.0
#> GSM1305000      55          F        W   17.50   6.40     6.0
#> GSM1305001      58          M        W   27.70   6.80     6.6
#> GSM1305002      49          F        W   21.50   6.70     8.7
#> GSM1305003      56          F        W   24.50   6.10     7.7
#> GSM1305004      42          F        W   31.20   6.50     6.8
#> GSM1305005      49          M        W   21.20   6.50     8.4
#> GSM1305006      48          M        W   21.68   6.60     7.5
#> GSM1305007      39          F        W   24.50   6.80     7.5
#> GSM1305008      48          M        W   24.50   6.50     7.6
#> GSM1305009      43          M        W   13.80   6.60     8.7
#> GSM1305010      68          M        W   11.80   6.80     8.5
#> GSM1305011      58          F        W   18.80   6.60     8.6
#> GSM1305012      43          M        W   22.30   6.70     8.5
#> GSM1305013      46          M        W   22.00   6.30     7.0
#> GSM1305014      51          M        W   24.20   6.60     8.3
#> GSM1305015      51          F        W    7.80   6.60     9.0
#> GSM1305016      36          F        W   14.50   6.40     9.3
#> GSM1305017      65          F        W   18.50   6.50     7.4
#> GSM1305018      55          M        W   28.00   6.10     7.6
#> GSM1305019      22          M        W   20.10   6.80     7.4
#> GSM1305020      52          F        W   22.60   7.10     8.8
#> GSM1305021      58          F        W   22.70   6.40     9.0
#> GSM1305022      40          F        B   16.60   6.80     8.7
#> GSM1305023      42          M        W   14.30   6.40     8.7
#> GSM1305024      44          M        W   19.30   6.50     8.5
#> GSM1305025      47          M        W   24.00   6.60     7.3
#> GSM1305026      44          M        W   11.00   6.50     7.7
#> GSM1305027      59          M        W   13.00   6.60     8.4
#> GSM1305028      47          F        W   22.30   6.60     8.2
#> GSM1305029      34          M        W   24.40   6.60     9.1
#> GSM1305030      51          M        W   28.30   7.30     8.6
#> GSM1305031      51          M        W   24.60   6.50     8.3
#> GSM1305032      53          F        W   11.90   6.70     8.8
#> GSM1305033      26          F        W   13.40   6.40     9.2
#> GSM1305034      52          F        W   10.30   6.50     6.7
#> GSM1305035      62          M        W   26.00   6.50     7.5
#> GSM1305036      29          M        W   26.60   6.90     9.2
#> GSM1305037      49          F        W   23.40   6.40     6.7
#> GSM1305038      54          F        W   17.90   6.20     9.0
#> GSM1305039      50          M        W   11.00   6.23     8.5
#> GSM1305040      46          M        W   15.80   6.19     7.8
#> GSM1305041      41          F        W   20.10   6.27     8.6
#> GSM1305042      47          M        W   28.90   6.58     8.4
#> GSM1305043      37          M        B    5.98   6.07     6.9
#> GSM1305044      58          M        W    7.70   6.22     6.7
#> GSM1305045      44          F        B   18.70   6.20     6.9
#> GSM1305046      38          M        W   28.80   6.56     6.8
#> GSM1305047      52          M        B   27.10   6.68     8.5
#> GSM1305048      49          M        W   21.50   5.97     8.4
#> GSM1305049      47          F        W   14.37   6.35     8.9
#> GSM1305050      25          F        B   20.10   6.73     7.3
#> GSM1305051      41          F        W   17.10   6.90     7.3
#> GSM1305052      62          M        W   22.70   7.14     7.8
#> GSM1305053      32          M        W   30.80   6.18     7.1
#> GSM1305054      47          F        B   20.10   7.30     8.8
#> GSM1305055      50          F        B   22.90   6.25     8.0
#> GSM1305056      44          F        W   24.50   6.63     9.0
#>                           ch1_tissue         ch1_disease state
#> GSM1304852               hippocampus          bipolar disorder
#> GSM1304853               hippocampus          bipolar disorder
#> GSM1304854               hippocampus          bipolar disorder
#> GSM1304855               hippocampus          bipolar disorder
#> GSM1304856               hippocampus          bipolar disorder
#> GSM1304857               hippocampus          bipolar disorder
#> GSM1304858               hippocampus          bipolar disorder
#> GSM1304859               hippocampus          bipolar disorder
#> GSM1304860               hippocampus          bipolar disorder
#> GSM1304861               hippocampus          bipolar disorder
#> GSM1304862               hippocampus          bipolar disorder
#> GSM1304863               hippocampus          bipolar disorder
#> GSM1304864               hippocampus          bipolar disorder
#> GSM1304865               hippocampus          bipolar disorder
#> GSM1304866               hippocampus          bipolar disorder
#> GSM1304867               hippocampus          bipolar disorder
#> GSM1304868               hippocampus          bipolar disorder
#> GSM1304869               hippocampus          bipolar disorder
#> GSM1304870               hippocampus                   control
#> GSM1304871               hippocampus                   control
#> GSM1304872               hippocampus                   control
#> GSM1304873               hippocampus                   control
#> GSM1304874               hippocampus                   control
#> GSM1304875               hippocampus                   control
#> GSM1304876               hippocampus                   control
#> GSM1304877               hippocampus                   control
#> GSM1304878               hippocampus                   control
#> GSM1304879               hippocampus                   control
#> GSM1304880               hippocampus                   control
#> GSM1304881               hippocampus                   control
#> GSM1304882               hippocampus                   control
#> GSM1304883               hippocampus                   control
#> GSM1304884               hippocampus                   control
#> GSM1304885               hippocampus                   control
#> GSM1304886               hippocampus                   control
#> GSM1304887               hippocampus                   control
#> GSM1304888               hippocampus major depressive disorder
#> GSM1304889               hippocampus major depressive disorder
#> GSM1304890               hippocampus major depressive disorder
#> GSM1304891               hippocampus major depressive disorder
#> GSM1304892               hippocampus major depressive disorder
#> GSM1304893               hippocampus major depressive disorder
#> GSM1304894               hippocampus major depressive disorder
#> GSM1304895               hippocampus major depressive disorder
#> GSM1304896               hippocampus major depressive disorder
#> GSM1304897               hippocampus major depressive disorder
#> GSM1304898               hippocampus major depressive disorder
#> GSM1304899               hippocampus major depressive disorder
#> GSM1304900               hippocampus major depressive disorder
#> GSM1304901               hippocampus major depressive disorder
#> GSM1304902               hippocampus major depressive disorder
#> GSM1304903               hippocampus major depressive disorder
#> GSM1304904               hippocampus major depressive disorder
#> GSM1304905               hippocampus                    schizo
#> GSM1304906               hippocampus                    schizo
#> GSM1304907               hippocampus                    schizo
#> GSM1304908               hippocampus                    schizo
#> GSM1304909               hippocampus                    schizo
#> GSM1304910               hippocampus                    schizo
#> GSM1304911               hippocampus                    schizo
#> GSM1304912               hippocampus                    schizo
#> GSM1304913               hippocampus                    schizo
#> GSM1304914               hippocampus                    schizo
#> GSM1304915               hippocampus                    schizo
#> GSM1304916               hippocampus                    schizo
#> GSM1304917               hippocampus                    schizo
#> GSM1304918               hippocampus                    schizo
#> GSM1304919               hippocampus                    schizo
#> GSM1304920 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304921 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304922 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304923 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304924 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304925 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304926 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304927 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304928 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304929 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304930 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304931 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304932 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304933 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304934 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304935 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304936 Pre-frontal cortex (BA46)          bipolar disorder
#> GSM1304937 Pre-frontal cortex (BA46)                   control
#> GSM1304938 Pre-frontal cortex (BA46)                   control
#> GSM1304939 Pre-frontal cortex (BA46)                   control
#> GSM1304940 Pre-frontal cortex (BA46)                   control
#> GSM1304941 Pre-frontal cortex (BA46)                   control
#> GSM1304942 Pre-frontal cortex (BA46)                   control
#> GSM1304943 Pre-frontal cortex (BA46)                   control
#> GSM1304944 Pre-frontal cortex (BA46)                   control
#> GSM1304945 Pre-frontal cortex (BA46)                   control
#> GSM1304946 Pre-frontal cortex (BA46)                   control
#> GSM1304947 Pre-frontal cortex (BA46)                   control
#> GSM1304948 Pre-frontal cortex (BA46)                   control
#> GSM1304949 Pre-frontal cortex (BA46)                   control
#> GSM1304950 Pre-frontal cortex (BA46)                   control
#> GSM1304951 Pre-frontal cortex (BA46)                   control
#> GSM1304952 Pre-frontal cortex (BA46)                   control
#> GSM1304953 Pre-frontal cortex (BA46)                   control
#> GSM1304954 Pre-frontal cortex (BA46)                   control
#> GSM1304955 Pre-frontal cortex (BA46)                   control
#> GSM1304956 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304957 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304958 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304959 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304960 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304961 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304962 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304963 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304964 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304965 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304966 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304967 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304968 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304969 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304970 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304971 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304972 Pre-frontal cortex (BA46) major depressive disorder
#> GSM1304973 Pre-frontal cortex (BA46)                    schizo
#> GSM1304974 Pre-frontal cortex (BA46)                    schizo
#> GSM1304975 Pre-frontal cortex (BA46)                    schizo
#> GSM1304976 Pre-frontal cortex (BA46)                    schizo
#> GSM1304977 Pre-frontal cortex (BA46)                    schizo
#> GSM1304978 Pre-frontal cortex (BA46)                    schizo
#> GSM1304979 Pre-frontal cortex (BA46)                    schizo
#> GSM1304980 Pre-frontal cortex (BA46)                    schizo
#> GSM1304981 Pre-frontal cortex (BA46)                    schizo
#> GSM1304982 Pre-frontal cortex (BA46)                    schizo
#> GSM1304983 Pre-frontal cortex (BA46)                    schizo
#> GSM1304984 Pre-frontal cortex (BA46)                    schizo
#> GSM1304985 Pre-frontal cortex (BA46)                    schizo
#> GSM1304986 Pre-frontal cortex (BA46)                    schizo
#> GSM1304987 Pre-frontal cortex (BA46)                    schizo
#> GSM1304988      Associative striatum          bipolar disorder
#> GSM1304989      Associative striatum          bipolar disorder
#> GSM1304990      Associative striatum          bipolar disorder
#> GSM1304991      Associative striatum          bipolar disorder
#> GSM1304992      Associative striatum          bipolar disorder
#> GSM1304993      Associative striatum          bipolar disorder
#> GSM1304994      Associative striatum          bipolar disorder
#> GSM1304995      Associative striatum          bipolar disorder
#> GSM1304996      Associative striatum          bipolar disorder
#> GSM1304997      Associative striatum          bipolar disorder
#> GSM1304998      Associative striatum          bipolar disorder
#> GSM1304999      Associative striatum          bipolar disorder
#> GSM1305000      Associative striatum          bipolar disorder
#> GSM1305001      Associative striatum          bipolar disorder
#> GSM1305002      Associative striatum          bipolar disorder
#> GSM1305003      Associative striatum          bipolar disorder
#> GSM1305004      Associative striatum          bipolar disorder
#> GSM1305005      Associative striatum                   control
#> GSM1305006      Associative striatum                   control
#> GSM1305007      Associative striatum                   control
#> GSM1305008      Associative striatum                   control
#> GSM1305009      Associative striatum                   control
#> GSM1305010      Associative striatum                   control
#> GSM1305011      Associative striatum                   control
#> GSM1305012      Associative striatum                   control
#> GSM1305013      Associative striatum                   control
#> GSM1305014      Associative striatum                   control
#> GSM1305015      Associative striatum                   control
#> GSM1305016      Associative striatum                   control
#> GSM1305017      Associative striatum                   control
#> GSM1305018      Associative striatum                   control
#> GSM1305019      Associative striatum                   control
#> GSM1305020      Associative striatum                   control
#> GSM1305021      Associative striatum                   control
#> GSM1305022      Associative striatum                   control
#> GSM1305023      Associative striatum major depressive disorder
#> GSM1305024      Associative striatum major depressive disorder
#> GSM1305025      Associative striatum major depressive disorder
#> GSM1305026      Associative striatum major depressive disorder
#> GSM1305027      Associative striatum major depressive disorder
#> GSM1305028      Associative striatum major depressive disorder
#> GSM1305029      Associative striatum major depressive disorder
#> GSM1305030      Associative striatum major depressive disorder
#> GSM1305031      Associative striatum major depressive disorder
#> GSM1305032      Associative striatum major depressive disorder
#> GSM1305033      Associative striatum major depressive disorder
#> GSM1305034      Associative striatum major depressive disorder
#> GSM1305035      Associative striatum major depressive disorder
#> GSM1305036      Associative striatum major depressive disorder
#> GSM1305037      Associative striatum major depressive disorder
#> GSM1305038      Associative striatum major depressive disorder
#> GSM1305039      Associative striatum                    schizo
#> GSM1305040      Associative striatum                    schizo
#> GSM1305041      Associative striatum                    schizo
#> GSM1305042      Associative striatum                    schizo
#> GSM1305043      Associative striatum                    schizo
#> GSM1305044      Associative striatum                    schizo
#> GSM1305045      Associative striatum                    schizo
#> GSM1305046      Associative striatum                    schizo
#> GSM1305047      Associative striatum                    schizo
#> GSM1305048      Associative striatum                    schizo
#> GSM1305049      Associative striatum                    schizo
#> GSM1305050      Associative striatum                    schizo
#> GSM1305051      Associative striatum                    schizo
#> GSM1305052      Associative striatum                    schizo
#> GSM1305053      Associative striatum                    schizo
#> GSM1305054      Associative striatum                    schizo
#> GSM1305055      Associative striatum                    schizo
#> GSM1305056      Associative striatum                    schizo
#>                                                                                                                               characteristics_ch1
#> GSM1304852                        age: 52; gender: M; race: W; pmi: 23.5; ph: 6.7; rin: 6.3; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304853                        age: 50; gender: F; race: W; pmi: 11.7; ph: 6.4; rin: 6.8; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304854                        age: 28; gender: F; race: W; pmi: 22.3; ph: 6.3; rin: 7.7; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304855                        age: 55; gender: F; race: W; pmi: 17.5; ph: 6.4; rin: 7.6; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304856                          age: 58; gender: M; race: W; pmi: 27.7; ph: 6.8; rin: 7; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304857                        age: 28; gender: M; race: W; pmi: 27.4; ph: 6.2; rin: 7.7; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304858                        age: 49; gender: F; race: W; pmi: 21.5; ph: 6.7; rin: 8.2; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304859                        age: 42; gender: F; race: W; pmi: 31.2; ph: 6.5; rin: 5.6; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304860                        age: 43; gender: F; race: W; pmi: 31.9; ph: 6.7; rin: 6.3; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304861                        age: 50; gender: M; race: W; pmi: 12.1; ph: 6.7; rin: 7.4; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304862                        age: 40; gender: M; race: W; pmi: 18.5; ph: 6.4; rin: 6.5; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304863                        age: 39; gender: F; race: W; pmi: 22.2; ph: 6.7; rin: 7.9; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304864                        age: 45; gender: M; race: W; pmi: 27.2; ph: 7.1; rin: 8.1; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304865                        age: 42; gender: M; race: W; pmi: 12.5; ph: 6.7; rin: 8.2; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304866                         age: 65; gender: M; race: W; pmi: 8.9; ph: 6.7; rin: 6.6; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304867                          age: 51; gender: F; race: W; pmi: 21.5; ph: 6.7; rin: 7; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304868                        age: 39; gender: M; race: W; pmi: 24.2; ph: 6.6; rin: 7.8; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304869                          age: 48; gender: M; race: W; pmi: 18.1; ph: 6.9; rin: 7; tissue: hippocampus; disease state: bipolar disorder
#> GSM1304870                                 age: 51; gender: M; race: W; pmi: 24.2; ph: 6.6; rin: 7.8; tissue: hippocampus; disease state: control
#> GSM1304871                                  age: 51; gender: F; race: W; pmi: 7.8; ph: 6.6; rin: 7.2; tissue: hippocampus; disease state: control
#> GSM1304872                                   age: 36; gender: F; race: W; pmi: 14.5; ph: 6.4; rin: 8; tissue: hippocampus; disease state: control
#> GSM1304873                                   age: 65; gender: F; race: W; pmi: 18.5; ph: 6.5; rin: 7; tissue: hippocampus; disease state: control
#> GSM1304874                                   age: 55; gender: M; race: W; pmi: 28; ph: 6.1; rin: 6.8; tissue: hippocampus; disease state: control
#> GSM1304875                                 age: 22; gender: M; race: W; pmi: 20.1; ph: 6.8; rin: 7.1; tissue: hippocampus; disease state: control
#> GSM1304876                                   age: 52; gender: F; race: W; pmi: 22.6; ph: 7.1; rin: 7; tissue: hippocampus; disease state: control
#> GSM1304877                                 age: 58; gender: F; race: W; pmi: 22.7; ph: 6.4; rin: 6.3; tissue: hippocampus; disease state: control
#> GSM1304878                                 age: 40; gender: F; race: B; pmi: 16.6; ph: 6.8; rin: 7.9; tissue: hippocampus; disease state: control
#> GSM1304879                                 age: 41; gender: F; race: W; pmi: 15.4; ph: 6.6; rin: 8.5; tissue: hippocampus; disease state: control
#> GSM1304880                                 age: 49; gender: M; race: W; pmi: 21.2; ph: 6.5; rin: 7.8; tissue: hippocampus; disease state: control
#> GSM1304881                                age: 48; gender: M; race: W; pmi: 21.68; ph: 6.6; rin: 7.3; tissue: hippocampus; disease state: control
#> GSM1304882                                 age: 39; gender: F; race: W; pmi: 24.5; ph: 6.8; rin: 8.2; tissue: hippocampus; disease state: control
#> GSM1304883                                   age: 48; gender: M; race: W; pmi: 24.5; ph: 6.5; rin: 7; tissue: hippocampus; disease state: control
#> GSM1304884                                 age: 43; gender: M; race: W; pmi: 13.8; ph: 6.6; rin: 7.6; tissue: hippocampus; disease state: control
#> GSM1304885                                 age: 68; gender: M; race: W; pmi: 11.8; ph: 6.8; rin: 6.1; tissue: hippocampus; disease state: control
#> GSM1304886                                 age: 58; gender: F; race: W; pmi: 18.8; ph: 6.6; rin: 7.2; tissue: hippocampus; disease state: control
#> GSM1304887                                 age: 43; gender: M; race: W; pmi: 22.3; ph: 6.7; rin: 7.9; tissue: hippocampus; disease state: control
#> GSM1304888               age: 51; gender: M; race: W; pmi: 24.6; ph: 6.5; rin: 7.7; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304889               age: 53; gender: F; race: W; pmi: 11.9; ph: 6.7; rin: 8.1; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304890               age: 26; gender: F; race: W; pmi: 13.4; ph: 6.4; rin: 7.5; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304891               age: 52; gender: F; race: W; pmi: 10.3; ph: 6.5; rin: 6.6; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304892                 age: 62; gender: M; race: W; pmi: 26; ph: 6.5; rin: 6.8; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304893               age: 29; gender: M; race: W; pmi: 26.6; ph: 6.9; rin: 7.8; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304894               age: 49; gender: F; race: W; pmi: 23.4; ph: 6.4; rin: 6.2; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304895               age: 54; gender: F; race: W; pmi: 17.9; ph: 6.2; rin: 6.1; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304896               age: 28; gender: F; race: B; pmi: 24.8; ph: 6.6; rin: 8.2; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304897               age: 42; gender: M; race: W; pmi: 14.3; ph: 6.4; rin: 6.2; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304898               age: 44; gender: M; race: W; pmi: 19.3; ph: 6.5; rin: 6.3; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304899                 age: 40; gender: F; race: W; pmi: 22.2; ph: 6.6; rin: 8; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304900                 age: 47; gender: M; race: W; pmi: 24; ph: 6.6; rin: 5.5; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304901                 age: 59; gender: M; race: W; pmi: 13; ph: 6.6; rin: 7.2; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304902               age: 47; gender: F; race: W; pmi: 22.3; ph: 6.6; rin: 6.5; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304903               age: 34; gender: M; race: W; pmi: 24.4; ph: 6.6; rin: 8.4; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304904                 age: 51; gender: M; race: W; pmi: 28.3; ph: 7.3; rin: 7; tissue: hippocampus; disease state: major depressive disorder
#> GSM1304905                          age: 49; gender: M; race: W; pmi: 21.5; ph: 5.97; rin: 6; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304906                       age: 47; gender: F; race: W; pmi: 14.37; ph: 6.35; rin: 6.3; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304907                        age: 25; gender: F; race: B; pmi: 20.1; ph: 6.73; rin: 5.6; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304908                        age: 62; gender: M; race: W; pmi: 22.7; ph: 7.14; rin: 6.3; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304909                        age: 44; gender: F; race: W; pmi: 24.5; ph: 6.63; rin: 7.8; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304910                        age: 46; gender: F; race: W; pmi: 23.8; ph: 6.61; rin: 6.9; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304911                          age: 50; gender: M; race: W; pmi: 11; ph: 6.23; rin: 7.2; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304912                        age: 46; gender: M; race: W; pmi: 15.8; ph: 6.19; rin: 6.2; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304913                        age: 41; gender: F; race: W; pmi: 20.1; ph: 6.27; rin: 6.7; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304914                        age: 47; gender: M; race: W; pmi: 28.9; ph: 6.58; rin: 6.7; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304915                        age: 37; gender: M; race: B; pmi: 5.98; ph: 6.07; rin: 6.4; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304916                         age: 58; gender: M; race: W; pmi: 7.7; ph: 6.22; rin: 6.7; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304917                         age: 44; gender: F; race: B; pmi: 18.7; ph: 6.2; rin: 6.4; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304918                        age: 38; gender: M; race: W; pmi: 28.8; ph: 6.56; rin: 6.6; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304919                        age: 52; gender: M; race: B; pmi: 27.1; ph: 6.68; rin: 6.3; tissue: hippocampus; disease state: schizo; phrenia
#> GSM1304920          age: 52; gender: M; race: W; pmi: 23.5; ph: 6.7; rin: 7.2; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304921          age: 50; gender: F; race: W; pmi: 11.7; ph: 6.4; rin: 8.6; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304922          age: 28; gender: F; race: W; pmi: 22.3; ph: 6.3; rin: 8.6; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304923            age: 55; gender: F; race: W; pmi: 17.5; ph: 6.4; rin: 8; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304924          age: 58; gender: M; race: W; pmi: 27.7; ph: 6.8; rin: 7.5; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304925          age: 28; gender: M; race: W; pmi: 27.4; ph: 6.2; rin: 7.9; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304926          age: 49; gender: F; race: W; pmi: 21.5; ph: 6.7; rin: 8.1; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304927          age: 56; gender: F; race: W; pmi: 24.5; ph: 6.1; rin: 6.9; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304928          age: 50; gender: M; race: W; pmi: 12.1; ph: 6.7; rin: 7.6; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304929          age: 40; gender: M; race: W; pmi: 18.5; ph: 6.4; rin: 7.9; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304930          age: 39; gender: F; race: W; pmi: 22.2; ph: 6.7; rin: 7.8; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304931          age: 45; gender: M; race: W; pmi: 27.2; ph: 7.1; rin: 7.3; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304932          age: 42; gender: M; race: W; pmi: 12.5; ph: 6.7; rin: 7.6; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304933           age: 65; gender: M; race: W; pmi: 8.9; ph: 6.7; rin: 6.9; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304934          age: 51; gender: F; race: W; pmi: 21.5; ph: 6.7; rin: 7.7; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304935          age: 39; gender: M; race: W; pmi: 24.2; ph: 6.6; rin: 7.3; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304936          age: 48; gender: M; race: W; pmi: 18.1; ph: 6.9; rin: 8.2; tissue: Pre-frontal cortex (BA46); disease state: bipolar disorder
#> GSM1304937                   age: 51; gender: M; race: W; pmi: 24.2; ph: 6.6; rin: 7.9; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304938                    age: 51; gender: F; race: W; pmi: 7.8; ph: 6.6; rin: 8.6; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304939                   age: 36; gender: F; race: W; pmi: 14.5; ph: 6.4; rin: 8.6; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304940                   age: 65; gender: F; race: W; pmi: 18.5; ph: 6.5; rin: 8.3; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304941                     age: 55; gender: M; race: W; pmi: 28; ph: 6.1; rin: 7.9; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304942                   age: 22; gender: M; race: W; pmi: 20.1; ph: 6.8; rin: 8.1; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304943                   age: 52; gender: F; race: W; pmi: 22.6; ph: 7.1; rin: 8.2; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304944                     age: 58; gender: F; race: W; pmi: 22.7; ph: 6.4; rin: 8; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304945                   age: 40; gender: F; race: B; pmi: 16.6; ph: 6.8; rin: 8.2; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304946                   age: 41; gender: F; race: W; pmi: 15.4; ph: 6.6; rin: 8.2; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304947                   age: 49; gender: M; race: W; pmi: 21.2; ph: 6.5; rin: 7.9; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304948                  age: 48; gender: M; race: W; pmi: 21.68; ph: 6.6; rin: 7.5; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304949                   age: 39; gender: F; race: W; pmi: 24.5; ph: 6.8; rin: 7.4; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304950                   age: 48; gender: M; race: W; pmi: 24.5; ph: 6.5; rin: 6.8; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304951                   age: 43; gender: M; race: W; pmi: 13.8; ph: 6.6; rin: 7.5; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304952                   age: 68; gender: M; race: W; pmi: 11.8; ph: 6.8; rin: 6.7; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304953                   age: 58; gender: F; race: W; pmi: 18.8; ph: 6.6; rin: 8.7; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304954                     age: 43; gender: M; race: W; pmi: 22.3; ph: 6.7; rin: 8; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304955                     age: 46; gender: M; race: W; pmi: 22; ph: 6.3; rin: 6.6; tissue: Pre-frontal cortex (BA46); disease state: control
#> GSM1304956 age: 51; gender: M; race: W; pmi: 24.6; ph: 6.5; rin: 7.8; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304957 age: 53; gender: F; race: W; pmi: 11.9; ph: 6.7; rin: 8.4; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304958 age: 26; gender: F; race: W; pmi: 13.4; ph: 6.4; rin: 8.4; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304959 age: 52; gender: F; race: W; pmi: 10.3; ph: 6.5; rin: 8.1; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304960   age: 62; gender: M; race: W; pmi: 26; ph: 6.5; rin: 7.8; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304961 age: 29; gender: M; race: W; pmi: 26.6; ph: 6.9; rin: 8.2; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304962 age: 49; gender: F; race: W; pmi: 23.4; ph: 6.4; rin: 7.6; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304963 age: 54; gender: F; race: W; pmi: 17.9; ph: 6.2; rin: 7.5; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304964 age: 28; gender: F; race: B; pmi: 24.8; ph: 6.6; rin: 7.9; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304965 age: 42; gender: M; race: W; pmi: 14.3; ph: 6.4; rin: 8.4; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304966 age: 40; gender: F; race: W; pmi: 22.2; ph: 6.6; rin: 7.7; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304967   age: 47; gender: M; race: W; pmi: 24; ph: 6.6; rin: 6.8; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304968   age: 44; gender: M; race: W; pmi: 11; ph: 6.5; rin: 7.2; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304969   age: 59; gender: M; race: W; pmi: 13; ph: 6.6; rin: 7.7; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304970 age: 47; gender: F; race: W; pmi: 22.3; ph: 6.6; rin: 6.7; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304971 age: 34; gender: M; race: W; pmi: 24.4; ph: 6.6; rin: 7.8; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304972 age: 51; gender: M; race: W; pmi: 28.3; ph: 7.3; rin: 7.7; tissue: Pre-frontal cortex (BA46); disease state: major depressive disorder
#> GSM1304973            age: 49; gender: M; race: W; pmi: 21.5; ph: 5.97; rin: 7; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304974           age: 47; gender: F; race: W; pmi: 14.37; ph: 6.35; rin: 9; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304975          age: 25; gender: F; race: B; pmi: 20.1; ph: 6.73; rin: 7.2; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304976           age: 41; gender: F; race: W; pmi: 17.1; ph: 6.9; rin: 8.3; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304977          age: 62; gender: M; race: W; pmi: 22.7; ph: 7.14; rin: 8.1; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304978           age: 47; gender: F; race: B; pmi: 20.1; ph: 7.3; rin: 8.1; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304979          age: 44; gender: F; race: W; pmi: 24.5; ph: 6.63; rin: 7.6; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304980            age: 46; gender: F; race: W; pmi: 23.8; ph: 6.61; rin: 8; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304981            age: 50; gender: M; race: W; pmi: 11; ph: 6.23; rin: 8.4; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304982          age: 41; gender: F; race: W; pmi: 20.1; ph: 6.27; rin: 7.4; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304983            age: 47; gender: M; race: W; pmi: 28.9; ph: 6.58; rin: 7; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304984          age: 37; gender: M; race: B; pmi: 5.98; ph: 6.07; rin: 6.3; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304985           age: 58; gender: M; race: W; pmi: 7.7; ph: 6.22; rin: 7.3; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304986           age: 44; gender: F; race: B; pmi: 18.7; ph: 6.2; rin: 7.6; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304987          age: 52; gender: M; race: B; pmi: 27.1; ph: 6.68; rin: 7.4; tissue: Pre-frontal cortex (BA46); disease state: schizo; phrenia
#> GSM1304988               age: 50; gender: M; race: W; pmi: 12.1; ph: 6.7; rin: 8.6; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1304989               age: 40; gender: M; race: W; pmi: 18.5; ph: 6.4; rin: 8.4; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1304990               age: 39; gender: F; race: W; pmi: 22.2; ph: 6.7; rin: 9.1; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1304991               age: 45; gender: M; race: W; pmi: 27.2; ph: 7.1; rin: 8.7; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1304992               age: 42; gender: M; race: W; pmi: 12.5; ph: 6.7; rin: 8.7; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1304993                age: 65; gender: M; race: W; pmi: 8.9; ph: 6.7; rin: 8.3; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1304994               age: 51; gender: F; race: W; pmi: 21.5; ph: 6.7; rin: 8.4; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1304995               age: 39; gender: M; race: W; pmi: 24.2; ph: 6.6; rin: 8.5; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1304996               age: 48; gender: M; race: W; pmi: 18.1; ph: 6.9; rin: 8.8; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1304997               age: 52; gender: M; race: W; pmi: 23.5; ph: 6.7; rin: 9.1; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1304998               age: 50; gender: F; race: W; pmi: 11.7; ph: 6.4; rin: 8.4; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1304999                 age: 28; gender: F; race: W; pmi: 22.3; ph: 6.3; rin: 9; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1305000                 age: 55; gender: F; race: W; pmi: 17.5; ph: 6.4; rin: 6; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1305001               age: 58; gender: M; race: W; pmi: 27.7; ph: 6.8; rin: 6.6; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1305002               age: 49; gender: F; race: W; pmi: 21.5; ph: 6.7; rin: 8.7; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1305003               age: 56; gender: F; race: W; pmi: 24.5; ph: 6.1; rin: 7.7; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1305004               age: 42; gender: F; race: W; pmi: 31.2; ph: 6.5; rin: 6.8; tissue: Associative striatum; disease state: bipolar disorder
#> GSM1305005                        age: 49; gender: M; race: W; pmi: 21.2; ph: 6.5; rin: 8.4; tissue: Associative striatum; disease state: control
#> GSM1305006                       age: 48; gender: M; race: W; pmi: 21.68; ph: 6.6; rin: 7.5; tissue: Associative striatum; disease state: control
#> GSM1305007                        age: 39; gender: F; race: W; pmi: 24.5; ph: 6.8; rin: 7.5; tissue: Associative striatum; disease state: control
#> GSM1305008                        age: 48; gender: M; race: W; pmi: 24.5; ph: 6.5; rin: 7.6; tissue: Associative striatum; disease state: control
#> GSM1305009                        age: 43; gender: M; race: W; pmi: 13.8; ph: 6.6; rin: 8.7; tissue: Associative striatum; disease state: control
#> GSM1305010                        age: 68; gender: M; race: W; pmi: 11.8; ph: 6.8; rin: 8.5; tissue: Associative striatum; disease state: control
#> GSM1305011                        age: 58; gender: F; race: W; pmi: 18.8; ph: 6.6; rin: 8.6; tissue: Associative striatum; disease state: control
#> GSM1305012                        age: 43; gender: M; race: W; pmi: 22.3; ph: 6.7; rin: 8.5; tissue: Associative striatum; disease state: control
#> GSM1305013                            age: 46; gender: M; race: W; pmi: 22; ph: 6.3; rin: 7; tissue: Associative striatum; disease state: control
#> GSM1305014                        age: 51; gender: M; race: W; pmi: 24.2; ph: 6.6; rin: 8.3; tissue: Associative striatum; disease state: control
#> GSM1305015                           age: 51; gender: F; race: W; pmi: 7.8; ph: 6.6; rin: 9; tissue: Associative striatum; disease state: control
#> GSM1305016                        age: 36; gender: F; race: W; pmi: 14.5; ph: 6.4; rin: 9.3; tissue: Associative striatum; disease state: control
#> GSM1305017                        age: 65; gender: F; race: W; pmi: 18.5; ph: 6.5; rin: 7.4; tissue: Associative striatum; disease state: control
#> GSM1305018                          age: 55; gender: M; race: W; pmi: 28; ph: 6.1; rin: 7.6; tissue: Associative striatum; disease state: control
#> GSM1305019                        age: 22; gender: M; race: W; pmi: 20.1; ph: 6.8; rin: 7.4; tissue: Associative striatum; disease state: control
#> GSM1305020                        age: 52; gender: F; race: W; pmi: 22.6; ph: 7.1; rin: 8.8; tissue: Associative striatum; disease state: control
#> GSM1305021                          age: 58; gender: F; race: W; pmi: 22.7; ph: 6.4; rin: 9; tissue: Associative striatum; disease state: control
#> GSM1305022                        age: 40; gender: F; race: B; pmi: 16.6; ph: 6.8; rin: 8.7; tissue: Associative striatum; disease state: control
#> GSM1305023      age: 42; gender: M; race: W; pmi: 14.3; ph: 6.4; rin: 8.7; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305024      age: 44; gender: M; race: W; pmi: 19.3; ph: 6.5; rin: 8.5; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305025        age: 47; gender: M; race: W; pmi: 24; ph: 6.6; rin: 7.3; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305026        age: 44; gender: M; race: W; pmi: 11; ph: 6.5; rin: 7.7; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305027        age: 59; gender: M; race: W; pmi: 13; ph: 6.6; rin: 8.4; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305028      age: 47; gender: F; race: W; pmi: 22.3; ph: 6.6; rin: 8.2; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305029      age: 34; gender: M; race: W; pmi: 24.4; ph: 6.6; rin: 9.1; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305030      age: 51; gender: M; race: W; pmi: 28.3; ph: 7.3; rin: 8.6; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305031      age: 51; gender: M; race: W; pmi: 24.6; ph: 6.5; rin: 8.3; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305032      age: 53; gender: F; race: W; pmi: 11.9; ph: 6.7; rin: 8.8; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305033      age: 26; gender: F; race: W; pmi: 13.4; ph: 6.4; rin: 9.2; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305034      age: 52; gender: F; race: W; pmi: 10.3; ph: 6.5; rin: 6.7; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305035        age: 62; gender: M; race: W; pmi: 26; ph: 6.5; rin: 7.5; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305036      age: 29; gender: M; race: W; pmi: 26.6; ph: 6.9; rin: 9.2; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305037      age: 49; gender: F; race: W; pmi: 23.4; ph: 6.4; rin: 6.7; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305038        age: 54; gender: F; race: W; pmi: 17.9; ph: 6.2; rin: 9; tissue: Associative striatum; disease state: major depressive disorder
#> GSM1305039                 age: 50; gender: M; race: W; pmi: 11; ph: 6.23; rin: 8.5; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305040               age: 46; gender: M; race: W; pmi: 15.8; ph: 6.19; rin: 7.8; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305041               age: 41; gender: F; race: W; pmi: 20.1; ph: 6.27; rin: 8.6; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305042               age: 47; gender: M; race: W; pmi: 28.9; ph: 6.58; rin: 8.4; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305043               age: 37; gender: M; race: B; pmi: 5.98; ph: 6.07; rin: 6.9; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305044                age: 58; gender: M; race: W; pmi: 7.7; ph: 6.22; rin: 6.7; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305045                age: 44; gender: F; race: B; pmi: 18.7; ph: 6.2; rin: 6.9; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305046               age: 38; gender: M; race: W; pmi: 28.8; ph: 6.56; rin: 6.8; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305047               age: 52; gender: M; race: B; pmi: 27.1; ph: 6.68; rin: 8.5; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305048               age: 49; gender: M; race: W; pmi: 21.5; ph: 5.97; rin: 8.4; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305049              age: 47; gender: F; race: W; pmi: 14.37; ph: 6.35; rin: 8.9; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305050               age: 25; gender: F; race: B; pmi: 20.1; ph: 6.73; rin: 7.3; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305051                age: 41; gender: F; race: W; pmi: 17.1; ph: 6.9; rin: 7.3; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305052               age: 62; gender: M; race: W; pmi: 22.7; ph: 7.14; rin: 7.8; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305053               age: 32; gender: M; race: W; pmi: 30.8; ph: 6.18; rin: 7.1; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305054                age: 47; gender: F; race: B; pmi: 20.1; ph: 7.3; rin: 8.8; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305055                 age: 50; gender: F; race: B; pmi: 22.9; ph: 6.25; rin: 8; tissue: Associative striatum; disease state: schizo; phrenia
#> GSM1305056                 age: 44; gender: F; race: W; pmi: 24.5; ph: 6.63; rin: 9; tissue: Associative striatum; disease state: schizo; phrenia
```

### Download supplementary data from GEO database - `geo_suppl`

GEO stores raw data and processed sequence data files as the external
supplementary data files. Sometimes, we may want to preprocess and
normalize the rawdata by ourselves, in addition, it’s not uncommon that
a GSE entity series matrix won’t contain the expression matrix, which is
almost the case of high-throughout sequencing data. `geo_suppl` is
designed for these conditions. Usually, the expression matrix will be
provided in the GSE supplementary files or in the GSM supplementary
files.

If the expression matrix is given in the GSE supplementary files, we can
download it directly use `geo_suppl`, which will return a character
vector containing the path of downloaded files.

``` r
gse160724 <- geo_suppl(
    ids = "GSE160724", odir = tempdir(),
    pattern = "counts_anno"
)
#> Downloading 1 GSE suppl file from FTP site
gse160724_dt <- data.table::fread(gse160724)
head(gse160724_dt[1:5])
#>    gene_id  NC_1  NC_2 shSRSF1_1 shSRSF1_2
#>     <char> <int> <int>     <int>     <int>
#> 1:    A1BG   189   179       299       310
#> 2:    A1CF     0     0         0         0
#> 3:     A2M     0     0         0         0
#> 4:   A2ML1     0     0         0         0
#> 5: A3GALT2     0     1         0         0
#>                                                          Dbxref
#>                                                          <char>
#> 1:          GeneID:1,Genbank:NM_130786.3,HGNC:HGNC:5,MIM:138670
#> 2:             GeneID:29974,Genbank:NM_138933.2,HGNC:HGNC:24086
#> 3:       GeneID:2,Genbank:NM_001347423.1,HGNC:HGNC:7,MIM:103950
#> 4: GeneID:144568,Genbank:NM_144670.5,HGNC:HGNC:23336,MIM:610627
#> 5:         GeneID:127550,Genbank:NM_001080438.1,HGNC:HGNC:30005
#>                              product
#>                               <char>
#> 1:            alpha-1-B glycoprotein
#> 2:    APOBEC1 complementation factor
#> 3:             alpha-2-macroglobulin
#> 4:      alpha-2-macroglobulin like 1
#> 5: alpha 1,3-galactosyltransferase 2
#>                                                                                                                       GO_id
#>                                                                                                                      <char>
#> 1:                                                                                                                         
#> 2:            GO:0003723,GO:0003727,GO:0005654,GO:0005737,GO:0005783,GO:0006397,GO:0016554,GO:0016556,GO:0030895,GO:0050821
#> 3:                                                                                                                         
#> 4:                                                                   GO:0004867,GO:0005615,GO:0030414,GO:0052548,GO:0070062
#> 5: GO:0005794,GO:0005975,GO:0006688,GO:0009247,GO:0016021,GO:0016757,GO:0030259,GO:0031982,GO:0032580,GO:0046872,GO:0047276
#>                                                                                                                                                                                                                                                                                                                                       GO_term
#>                                                                                                                                                                                                                                                                                                                                        <char>
#> 1:                                                                                                                                                                                                                                                                                                                                           
#> 2:                                                                                                                       RNA binding|single-stranded RNA binding|nucleoplasm|cytoplasm|endoplasmic reticulum|mRNA processing|cytidine to uridine editing|mRNA modification|apolipoprotein B mRNA editing enzyme complex|protein stabilization
#> 3:                                                                                                                                                                                                                                                                                                                                           
#> 4:                                                                                                                                                                                   serine-type endopeptidase inhibitor activity|extracellular space|peptidase inhibitor activity|regulation of endopeptidase activity|extracellular exosome
#> 5: Golgi apparatus|carbohydrate metabolic process|glycosphingolipid biosynthetic process|glycolipid biosynthetic process|integral component of membrane|transferase activity, transferring glycosyl groups|lipid glycosylation|vesicle|Golgi cisterna membrane|metal ion binding|N-acetyllactosaminide 3-alpha-galactosyltransferase activity
#>     pathway                                        pathway_description
#>      <char>                                                     <char>
#> 1:                                                                    
#> 2:                                                                    
#> 3: hsa04610                        Complement and coagulation cascades
#> 4:                                                                    
#> 5: hsa00603 Glycosphingolipid biosynthesis - globo and isoglobo series
```

If the expression matrix is given in the GSM supplementary files, in
this way, we start from derive all GSM accession ids and then download
all GSM supplementary files and combine them into a expression matrix.
Although no expression matrix in the series matrix file, it still
contains the samples informations.

``` r
gse180383_smat <- geo(
    "GSE180383",
    odir = tempdir(),
    gse_matrix = TRUE, add_gpl = FALSE,
    pdata_from_soft = FALSE
)
#> Downloading 1 GSE matrix file from FTP site
#> → Parsing 1 series matrix file of GSE180383
#> Warning: Cannot parse characteristic column correctly
#> ℹ Details see "characteristics_ch1" column in phenoData
#> ℹ Please use `parse_pdata()` or `parse_gsm_list()` function to convert it
#>   manually if necessary!
#> ✔ Parsing 1 GSE series matrix successfully!
#> → Constructing <ExpressionSet>
#> ✔ Found Bioconductor annotation package for "GPL21359"
gse180383_smat_cli <- Biobase::pData(gse180383_smat)
head(gse180383_smat_cli[1:5])
#>                                  title geo_accession                status
#> GSM5461787 Monoecious WT RNA-seq  rep1    GSM5461787 Public on Feb 15 2022
#> GSM5461788 Monoecious WT RNA-seq  rep2    GSM5461788 Public on Feb 15 2022
#> GSM5461789 Monoecious WT RNA-seq  rep3    GSM5461789 Public on Feb 15 2022
#> GSM5461790        Cmlhp1abRNA-seq rep1    GSM5461790 Public on Feb 15 2022
#> GSM5461791        Cmlhp1abRNA-seq rep2    GSM5461791 Public on Feb 15 2022
#> GSM5461792        Cmlhp1abRNA-seq rep3    GSM5461792 Public on Feb 15 2022
#>            submission_date last_update_date
#> GSM5461787     Jul 19 2021      Feb 15 2022
#> GSM5461788     Jul 19 2021      Feb 15 2022
#> GSM5461789     Jul 19 2021      Feb 15 2022
#> GSM5461790     Jul 19 2021      Feb 15 2022
#> GSM5461791     Jul 19 2021      Feb 15 2022
#> GSM5461792     Jul 19 2021      Feb 15 2022
gse180383_smat_gsmids <- gse180383_smat_cli[["geo_accession"]]
gse180383_smat_gsm_suppl <- geo_suppl(gse180383_smat_gsmids, odir = tempdir())
#> Downloading 6 GSM suppl files from FTP site
```

Another way, we can also derive sample accession ids from GSE soft
files, which is what our laboratory prefers to since we can easily get
exact sample traits information as described in the above by utilizing
`parse_gsm_list` function.

``` r
gse180383_soft <- geo(
    "GSE180383",
    odir = tempdir(),
    gse_matrix = FALSE
)
#> Downloading 1 GSE soft file from FTP site
gse180383_soft_cli <- parse_gsm_list(gsm(gse180383_soft))
#> Warning: More than one characters ":" found in meta characteristics data
#> ℹ Details see: "characteristics_ch1" column in returned data.
#> ℹ Please use `parse_pdata()` or combine `strsplit()` and `parse_gsm_list()`
#>   function to convert it manually if necessary!
head(gse180383_soft_cli[1:5])
#>            channel_count
#> GSM5461787             1
#> GSM5461788             1
#> GSM5461789             1
#> GSM5461790             1
#> GSM5461791             1
#> GSM5461792             1
#>                                                              ch1_cultivar
#> GSM5461787 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#> GSM5461788 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#> GSM5461789 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#> GSM5461790 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#> GSM5461791 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#> GSM5461792 Charantais type: Cucumis melo L. subsp. melo var cantalupensis
#>                                                                                                                                                      ch1_genotypes
#> GSM5461787                                                                                                                                   CharMONO inbreed line
#> GSM5461788                                                                                                                                   CharMONO inbreed line
#> GSM5461789                                                                                                                                   CharMONO inbreed line
#> GSM5461790 CharMONO cmlhp1ab double mutant carrying EMS mutations for Cmlhp1a (G1970A, genomic position from ATG ) and cmlhp1b (C1930T genomic position from ATG )
#> GSM5461791 CharMONO cmlhp1ab double mutant carrying EMS mutations for Cmlhp1a (G1970A, genomic position from ATG ) and cmlhp1b (C1930T genomic position from ATG )
#> GSM5461792 CharMONO cmlhp1ab double mutant carrying EMS mutations for Cmlhp1a (G1970A, genomic position from ATG ) and cmlhp1b (C1930T genomic position from ATG )
#>                                                                                                                                                                                                                                     characteristics_ch1
#> GSM5461787                                                                                                                                   cultivar: Charantais type: Cucumis melo L. subsp. melo var cantalupensis; genotypes: CharMONO inbreed line
#> GSM5461788                                                                                                                                   cultivar: Charantais type: Cucumis melo L. subsp. melo var cantalupensis; genotypes: CharMONO inbreed line
#> GSM5461789                                                                                                                                   cultivar: Charantais type: Cucumis melo L. subsp. melo var cantalupensis; genotypes: CharMONO inbreed line
#> GSM5461790 cultivar: Charantais type: Cucumis melo L. subsp. melo var cantalupensis; genotypes: CharMONO cmlhp1ab double mutant carrying EMS mutations for Cmlhp1a (G1970A, genomic position from ATG ) and cmlhp1b (C1930T genomic position from ATG )
#> GSM5461791 cultivar: Charantais type: Cucumis melo L. subsp. melo var cantalupensis; genotypes: CharMONO cmlhp1ab double mutant carrying EMS mutations for Cmlhp1a (G1970A, genomic position from ATG ) and cmlhp1b (C1930T genomic position from ATG )
#> GSM5461792 cultivar: Charantais type: Cucumis melo L. subsp. melo var cantalupensis; genotypes: CharMONO cmlhp1ab double mutant carrying EMS mutations for Cmlhp1a (G1970A, genomic position from ATG ) and cmlhp1b (C1930T genomic position from ATG )
#>             contact_address
#> GSM5461787 630 Rue Noetzlin
#> GSM5461788 630 Rue Noetzlin
#> GSM5461789 630 Rue Noetzlin
#> GSM5461790 630 Rue Noetzlin
#> GSM5461791 630 Rue Noetzlin
#> GSM5461792 630 Rue Noetzlin
gse180383_soft_gsmids <- names(gsm(gse180383_soft))
gse180383_soft_gsm_suppl <- geo_suppl(gse180383_soft_gsmids, odir = tempdir())
#> Finding 6 {.strong GSM} {.field suppl} file already downloaded:
#> 'GSM5461787_trim_RNA_Mono_1_S13_R1_001_countsMatrix.txt.gz',
#> 'GSM5461788_trim_RNA_Mono_2_S14_R1_001_countsMatrix.txt.gz',
#> 'GSM5461789_trim_RNA_Mono_3_S15_R1_001_countsMatrix.txt.gz',
#> 'GSM5461790_trim_RNA_ab_1_S16_R1_001_countsMatrix.txt.gz',
#> 'GSM5461791_trim_RNA_ab_2_S17_R1_001_countsMatrix.txt.gz', and
#> 'GSM5461792_trim_RNA_ab_3_S18_R1_001_countsMatrix.txt.gz'
```

### Other utilities

`geokit` also provide some useful function to help better interact with
GEO.

- `geo_show` function: Require a geo entity id and open GEO Accession
  site in the default browser.
- `log_trans` function: Require a expression matrix and this function
  will check whether this expression matrix has experienced logarithmic
  transformation, if it hasn’t, `log_trans` will do it. This is a helper
  function used in `GEO2R`.

### sessionInfo

``` r
sessionInfo()
#> R version 4.4.2 (2024-10-31)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.1 LTS
#> 
#> Matrix products: default
#> BLAS/LAPACK: /usr/lib/x86_64-linux-gnu/libmkl_rt.so;  LAPACK version 3.8.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: Asia/Shanghai
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] geokit_0.0.1.9000
#> 
#> loaded via a namespace (and not attached):
#>  [1] vctrs_0.6.5        cli_3.6.5          knitr_1.50         rlang_1.1.6       
#>  [5] xfun_0.52          stringi_1.8.4      generics_0.1.3     textshaping_0.4.0 
#>  [9] data.table_1.16.99 glue_1.8.0         htmltools_0.5.8.1  ragg_1.3.3        
#> [13] fansi_1.0.6        rmarkdown_2.29     evaluate_1.0.3     tibble_3.2.1      
#> [17] fastmap_1.2.0      yaml_2.3.10        lifecycle_1.0.4    stringr_1.5.1     
#> [21] compiler_4.4.2     dplyr_1.1.4        pkgconfig_2.0.3    systemfonts_1.1.0 
#> [25] digest_0.6.37      R6_2.6.1           tidyselect_1.2.1   utf8_1.2.5        
#> [29] pillar_1.9.0       magrittr_2.0.3     withr_3.0.2        tools_4.4.2
```
