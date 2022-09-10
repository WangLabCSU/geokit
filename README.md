
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rgeo

<!-- badges: start -->

[![R-CMD-check](https://github.com/Yunuuuu/rgeo/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Yunuuuu/rgeo/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of `rgeo` is to provide a unified interface for most
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
  `parse_pdata`, `set_pdata`, `log_trans` and `show_geo`.

## Installation

You can install the development version of rgeo from
[GitHub](https://github.com/) with:

``` r
if (!require(pak)) {
    install.packages("pak",
        repos = sprintf(
            "https://r-lib.github.io/p/pak/devel/%s/%s/%s",
            .Platform$pkgType, R.Version()$os, R.Version()$arch
        )
    )
}
pak::pkg_install("Yunuuuu/rgeo")
```

## Vignettes

``` r
library(rgeo)
library(magrittr)
```

### Search GEO database - `search_geo`

The NCBI uses a search term syntax which can be associated with a
specific search field enclosed by a pair of square brackets. So, for
instance `"Homo sapiens[ORGN]"` denotes a search for `Homo sapiens` in
the `“Organism”` field. Details see
<https://www.ncbi.nlm.nih.gov/geo/info/qqtutorial.html>. We can use the
same term to query our desirable results in `search_geo`. `search_geo`
will parse the searching results and return a `data.frame` object
containing all the records based on the search term. The internal of
`search_geo` is based on
[`rentrez`](https://github.com/ropensci/rentrez) package, which provides
functions working with the [NCBI
Eutils](http://www.ncbi.nlm.nih.gov/books/NBK25500/) API, so we can
utilize `NCBI API key` to increase the downloading speed, details see
<https://docs.ropensci.org/rentrez/articles/rentrez_tutorial.html#rate-limiting-and-api-keys>.

Providing we want ***GSE*** GEO records related to ***human diabetes***,
we can get these records by following code, the returned object is a
`data.frame`:

``` r
diabetes_gse_records <- search_geo(
    "diabetes[ALL] AND Homo sapiens[ORGN] AND GSE[ETYP]"
)
head(diabetes_gse_records[1:5])
#>                                                                                                                                                                                                          Title
#> 1                                                                                      Neutrophil extracellular traps induce glomerular endothelial cell dysfunction and pyroptosis in diabetic kidney disease
#> 2 The expression of mRNA and lncRNA in peripheral blood mononuclear cells (PBMCs) of diabetes mellitus, diabetic retinopathy (DR), diabetic peripheral neuropathy (DPN) and diabetic nephropathy (DN) patients
#> 3                                                                                                                                           Mitochondrial DNA atlas reveals physiopathology of type 2 diabetes
#> 4                                                                                                           DNA methylation profiling in cord blood neonatal monocytes from women with pre-gestational obesity
#> 5                                                                            Transcriptomic signatures responding to PKM2 activator TEPP-46 in the hyperglycemic human renal proximal epithelial tubular cells
#> 6                                                                                                                                               Global microRNA and protein expression in human term placenta.
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Summary
#> 1                                                                                                                                                                          Diabetic kidney disease (DKD) is the leading cause of end-stage renal disease. Neutrophil extracellular traps (NETs) are a network structure composed of loose chromatin and embedded with multiple proteins. Here, we observed increased NETs deposition in the glomeruli of DKD patients and diabetic mice (streptozotocin-induced or db/db mice). After degrading NETs with DNase I, diabetic mice exhibited attenuated glomerulopathy and glomerular endothelial cell (GEC) injury. more...
#> 2                                     DR, DPN and DN are common complications in diabetes, and the differentially expressed mRNAs and lncRNAs in these diabetic complications may help to identify the molecular markers for the onset and progression of diseases. In our study, high-throughput sequencing technique was used to analyze the expression profile of mRNA and lncRNA in the peripheral blood of health control, T2DM, DR, DPN and DN patients, in order to determine the differentially expressed  transcriptomic profiles changes in diabetic complications and identify the shared and specific biological signaling pathways related to DR, DPN and DN.
#> 3                                                                                                             Type 2 diabetes (T2D), one of the most common metabolic diseases, is the result of insulin resistance or impaired insulin secretion by mitochondrial dysfunctions. Mitochondrial DNA (mtDNA) polymorphisms play an important role in physiological and pathological characteristics of T2D, however, their mechanism is poorly understood. To directly identify candidate mtDNA variants associated with T2D at the genome-wide level, we constructed forty libraries from ten patients with T2D and thirty control individuals for deep sequencing. more...
#> 4                                                                                                                                  Obesity represents a global burden with an increasing worldwide prevalence, especially in women of reproductive age. Obesity in women, defined as a body mass index (BMI) > 30 kg/m2, has a worldwide prevalence ~21%, however, it exceeds 30% in countries such as Chile, Mexico, United States, and the United Kingdom. Growing evidence support the notion that pre-gestational obesity confers an increased risk for the development of diabetes, obesity and chronic inflammatory diseases in the offspring later in life. more...
#> 5 Pyruvate kinase M2 (PKM2), as the terminal and last rate-limiting enzyme of the glycolytic pathway, is an ideal enzyme for regulating metabolic phenotype. PKM2 tetramer activation has shown a protective role against diabetic kidney disease (DKD). However, the molecular mechanisms involved in diabetic tubular has not been investigated so far. In this study, we performed transcriptome gene expression profiling in human renal proximal tubular epithelial cell line (HK-2 cells) treated with high D-glucose (HG) for 7 days before the addition of 10-μM TEPP-46, an activator of PKM2 tetramerization, for a further 1 day in the presence of HG. more...
#> 6                                                                                                                                                                                          Description of the global expression of microRNAs (miRNAs) and proteins in healthy human term placentas may increase our knowledge of molecular biological pathways that are important for normal fetal growth and development in term pregnancy. The aim of this study was to explore the global expression of miRNAs and proteins, and to point out functions of importance in healthy term placentas. Placental samples (n = 19) were identified in a local biobank. more...
#>       Organism                                                     Type
#> 1 Homo sapiens       Expression profiling by high throughput sequencing
#> 2 Homo sapiens       Expression profiling by high throughput sequencing
#> 3 Homo sapiens Genome variation profiling by high throughput sequencing
#> 4 Homo sapiens             Methylation profiling by genome tiling array
#> 5 Homo sapiens       Expression profiling by high throughput sequencing
#> 6 Homo sapiens   Non-coding RNA profiling by high throughput sequencing
#>                                                                FTP download
#> 1      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE189nnn/GSE189875/
#> 2 GEO (GTF, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE185nnn/GSE185011/
#> 3      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE136nnn/GSE136892/
#> 4      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE212nnn/GSE212174/
#> 5      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE205nnn/GSE205674/
#> 6      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE211nnn/GSE211791/
```

Then, we can use whatever we’re famaliar to filter the searching
results. Providing we want GSE datasets with at least 6 diabetic
nephropathy samples containing expression profiling. Here is the example
code:

``` r
diabetes_nephropathy_gse_records <- diabetes_gse_records %>%
    dplyr::mutate(
        number_of_samples = stringr::str_match(
            Contains, "(\\d+) Samples?"
        )[, 2L, drop = TRUE],
        number_of_samples = as.integer(number_of_samples)
    ) %>%
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
#>                                                                                                                                                                                                          Title
#> 1 The expression of mRNA and lncRNA in peripheral blood mononuclear cells (PBMCs) of diabetes mellitus, diabetic retinopathy (DR), diabetic peripheral neuropathy (DPN) and diabetic nephropathy (DN) patients
#> 2                                                     Secretory Leukocyte Peptidase Inhibitor (SLPI) is a Novel Predictor of Tubulointerstitial Injury and Renal Outcome in Patients with Diabetic Nephropathy
#> 3                                                                                                                    Bulk RNA-seq on mouse model of diabetic nephropathy and in vitro model of SRSF7 knockdown
#> 4                                                                            RNA-seq profiling of tubulointerstitial tissue reveals a potential therapeutic role of dual anti-phosphatase 1 in kidney diseases
#> 5                                                                                                  Human Tubular Epithelial Cells Activate a Coordinated Stress Response after Serum Exposure [RNAseq-pid2019]
#> 6                                                                                                  Human Tubular Epithelial Cells Activate a Coordinated Stress Response after Serum Exposure [RNAseq-pid1830]
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                Summary
#> 1 DR, DPN and DN are common complications in diabetes, and the differentially expressed mRNAs and lncRNAs in these diabetic complications may help to identify the molecular markers for the onset and progression of diseases. In our study, high-throughput sequencing technique was used to analyze the expression profile of mRNA and lncRNA in the peripheral blood of health control, T2DM, DR, DPN and DN patients, in order to determine the differentially expressed  transcriptomic profiles changes in diabetic complications and identify the shared and specific biological signaling pathways related to DR, DPN and DN.
#> 2                                                                                                                                                                                                          Tubulointerstitial injury plays an important role in diabetic nephropathy (DN) progression; however, no reliable urinary molecule has been used to predict tubulointerstitial injury and renal outcome of DN clinically. In this study, based on tubulointerstitial transcriptome, we identified secretory leukocyte peptidase inhibitor (SLPI) as the molecule associated with renal fibrosis and prognosis of DN. more...
#> 3                                                                                                                                                                                                                  In this dataset, we utilized the db/db, uninephrectomy and renin-hypertension mouse model. We performed bulk RNA-seq and compared vehicle to ACE inhibitor, Rosiglitizone, SGLT2 inhibitor, ACEi + Rosiglitizone and ACEi + SGLT2i at two time points (2 days and 2 weeks). To study the mechanism, we also performed bulk RNA-seq on human primary tubular epithelial cells with or without SRSF7 siRNA knockdown.
#> 4                                                                                                                                                                                                                                 We profiled manually microdissected tubulointerstitial tissue from 43 IgA nephropathy, 3 diabetes mellitus nephropathy, 3 focal segmental glomerulosclerosis, 3 lupus nephritis, 4 membranous nephropathy, and 9 minimal change disease biopsy cores and 22 nephrectomy controls by RNA sequencing. The 3 outliers which were not included in our main analysis were also uploaded in this database.
#> 5                                                                                                                                                                                                   Proteinuria, the spillage of serum proteins into the urine, is a feature of glomerulonephritides, podocyte disorders and diabetic nephropathy. However, the response of tubular epithelial cells to serum protein exposure has not been systematically characterized. Using transcriptomic profiling we studied serum-induced changes in primary human tubular epithelial cells cultured in 3D microphysiological devices. more...
#> 6                                                                                                                                                                                                   Proteinuria, the spillage of serum proteins into the urine, is a feature of glomerulonephritides, podocyte disorders and diabetic nephropathy. However, the response of tubular epithelial cells to serum protein exposure has not been systematically characterized. Using transcriptomic profiling we studied serum-induced changes in primary human tubular epithelial cells cultured in 3D microphysiological devices. more...
#>                     Organism                                               Type
#> 1               Homo sapiens Expression profiling by high throughput sequencing
#> 2               Homo sapiens Expression profiling by high throughput sequencing
#> 3 Mus musculus; Homo sapiens Expression profiling by high throughput sequencing
#> 4               Homo sapiens Expression profiling by high throughput sequencing
#> 5               Homo sapiens Expression profiling by high throughput sequencing
#> 6               Homo sapiens Expression profiling by high throughput sequencing
#>                                                                FTP download
#> 1 GEO (GTF, TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE185nnn/GSE185011/
#> 2      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE158nnn/GSE158230/
#> 3      GEO (CSV) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE199nnn/GSE199437/
#> 4      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE175nnn/GSE175759/
#> 5      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE159nnn/GSE159586/
#> 6      GEO (TXT) ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE159nnn/GSE159554/
```

After filtering, we got 19 candidate datasets. This can reduce a lot of
time of us comparing with refining datasets by reading the summary
records.

### Download data from GEO database - `get_geo`

GEO database mainly provides SOFT (Simple Omnibus Format in Text)
formatted files for GPL, GSM and GDS entity. SOFT is designed for rapid
batch submission and download of data. SOFT is a simple line-based,
plain text format, meaning that SOFT files may be readily generated from
common spreadsheet and database applications. A single SOFT file can
hold both data tables and accompanying descriptive information for
multiple, concatenated Platforms, Samples, and/or Series records. `rgeo`
provide a `GEOSoft` class object to store SOFT file contents, `GEOSoft`
object contains four slots (“accession”, “meta”, “datatable”, and
“columns”). `accession` slot stores the GEO accession ID, `meta` slot
contains the metadata header in the SOFT formatted file, and `datatable`
slot contains the the data table in SOFT file which is the main data for
us to use, along with a `columns` slot providing descriptive column
header for the `datatable` data. We can use the function with the same
name of these slots to extract the data.

`get_geo` can download SOFT files and preprocess them well, here is some
example code to get soft file from `GPL`, `GSM` and `GDS` entity
respectively.

``` r
gpl <- get_geo("gpl98", tempdir())
#> Downloading GPL98.txt from GEO Accession Site:
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
gsm <- get_geo("GSM1", tempdir())
#> Downloading GSM1.txt from GEO Accession Site:
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
gds <- get_geo("GDS10", tempdir())
#> Downloading GDS10.soft.gz from FTP site:
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
structure is different with `GPL`, `GSM` and `GDS` entity, `rgeo`
provide `GEOSeries` class to keep contents in GSE soft file. Actually, a
GSE soft file contains almost all contents in its subsets soft file
including both `GPL` and `GSM`, so `GEOSeries` class provides both `gpl`
and `gsm` slots as a list of `GEOSoft`. To download GSE soft file, we
just set `gse_matrix` to `FALSE` in `get_geo` function.

``` r
gse <- get_geo("GSE10", tempdir(), gse_matrix = FALSE)
#> Downloading GSE10_family.soft.gz from FTP site:
#> Found 5 entities...
#> GPL4 (1 of 5 entities)
#> GSM571 (2 of 5 entities)
#> GSM572 (3 of 5 entities)
#> GSM573 (4 of 5 entities)
#> GSM574 (5 of 5 entities)
gse
#> An object of GEOSeries
#> gsm: GSM571 GSM572 GSM573 GSM574
#> gpl: GPL4
#> meta: Database_email Database_institute Database_name ... Series_title
#>   Series_type (31 total)
#> accession: GSE10
```

It’s more common to use a series matrix file in our usual analysis
workflow, we can also handle it easily in `rgeo`, as what we need to do
is just set `gse_matrix` to `TRUE` in `get_geo` function, which is also
the default value. When `gse_matrix` is `TRUE`, `get_geo` will return a
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
`FALSE` and use `set_pdata` function to parse it manully. Another
important parameter is `add_gpl`, where `FALSE` indicates `get_geo` will
try to map the current GPL accession id into a Bioconductor annotation
package, then we can use the latest bioconductor annotation package to
get the up-to-date featureData, otherwise, `get_geo` will add
featureData from GPL soft file directly.

``` r
gse_matix <- get_geo("GSE10", tempdir())
#> Downloading GSE10_series_matrix.txt.gz from FTP site:
#> Downloading GSE10_family.soft.gz from FTP site:
#> Cannot map GPL4 to a Bioconductor annotation package
#> • Setting `add_gpl` to `TRUE`
#> Downloading GPL4.annot.gz from FTP site:
#> 
#> annot file in FTP site for GPL4 is not available, so will use data amount of SOFT file from GEO Accession Site instead.
#> Downloading GPL4.txt from GEO Accession Site:
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
gse_matrix_with_pdata <- get_geo(
    "gse53987", tempdir(),
    pdata_from_soft = FALSE,
    add_gpl = FALSE
)
#> Downloading GSE53987_series_matrix.txt.gz from FTP site:
#> Warning: Cannot parse characteristic column correctly
#> • Details see `characteristics_ch1` column in `phenoData`
#> Warning: Please use `set_pdata` or `parse_pdata` function to convert it manually
#> if necessary!
gse_matrix_smp_info <- Biobase::pData(gse_matrix_with_pdata)
data.table::setDT(gse_matrix_smp_info)
gse_matrix_smp_info[, characteristics_ch1 := stringr::str_replace_all(
    characteristics_ch1,
    "gender|race|pmi|ph|rin|tissue|disease state",
    function(x) paste0("; ", x)
)]
set_pdata(gse_matrix_smp_info)
gse_matrix_smp_info[
    , .SD,
    .SDcols = patterns("^ch1_|characteristics_ch1")
]
#>      ch1_age ch1_gender ch1_race ch1_pmi ch1_ph ch1_rin           ch1_tissue
#>        <int>     <char>   <char>   <num>  <num>   <num>               <char>
#>   1:      52          M        W    23.5   6.70     6.3          hippocampus
#>   2:      50          F        W    11.7   6.40     6.8          hippocampus
#>   3:      28          F        W    22.3   6.30     7.7          hippocampus
#>   4:      55          F        W    17.5   6.40     7.6          hippocampus
#>   5:      58          M        W    27.7   6.80     7.0          hippocampus
#>  ---                                                                        
#> 201:      62          M        W    22.7   7.14     7.8 Associative striatum
#> 202:      32          M        W    30.8   6.18     7.1 Associative striatum
#> 203:      47          F        B    20.1   7.30     8.8 Associative striatum
#> 204:      50          F        B    22.9   6.25     8.0 Associative striatum
#> 205:      44          F        W    24.5   6.63     9.0 Associative striatum
#>      ch1_disease state
#>                 <char>
#>   1:  bipolar disorder
#>   2:  bipolar disorder
#>   3:  bipolar disorder
#>   4:  bipolar disorder
#>   5:  bipolar disorder
#>  ---                  
#> 201:            schizo
#> 202:            schizo
#> 203:            schizo
#> 204:            schizo
#> 205:            schizo
#>                                                                                                           characteristics_ch1
#>                                                                                                                        <char>
#>   1:          age: 52; gender: M; race: W; pmi: 23.5; ph: 6.7; rin: 6.3; tissue: hippocampus; disease state: bipolar disorder
#>   2:          age: 50; gender: F; race: W; pmi: 11.7; ph: 6.4; rin: 6.8; tissue: hippocampus; disease state: bipolar disorder
#>   3:          age: 28; gender: F; race: W; pmi: 22.3; ph: 6.3; rin: 7.7; tissue: hippocampus; disease state: bipolar disorder
#>   4:          age: 55; gender: F; race: W; pmi: 17.5; ph: 6.4; rin: 7.6; tissue: hippocampus; disease state: bipolar disorder
#>   5:            age: 58; gender: M; race: W; pmi: 27.7; ph: 6.8; rin: 7; tissue: hippocampus; disease state: bipolar disorder
#>  ---                                                                                                                         
#> 201: age: 62; gender: M; race: W; pmi: 22.7; ph: 7.14; rin: 7.8; tissue: Associative striatum; disease state: schizo; phrenia
#> 202: age: 32; gender: M; race: W; pmi: 30.8; ph: 6.18; rin: 7.1; tissue: Associative striatum; disease state: schizo; phrenia
#> 203:  age: 47; gender: F; race: B; pmi: 20.1; ph: 7.3; rin: 8.8; tissue: Associative striatum; disease state: schizo; phrenia
#> 204:   age: 50; gender: F; race: B; pmi: 22.9; ph: 6.25; rin: 8; tissue: Associative striatum; disease state: schizo; phrenia
#> 205:   age: 44; gender: F; race: W; pmi: 24.5; ph: 6.63; rin: 9; tissue: Associative striatum; disease state: schizo; phrenia
```

### Download supplementary data from GEO database - `get_geo_suppl`

GEO stores raw data and processed sequence data files as the external
supplementary data files. Sometimes, we may want to preprocess and
normalize the rawdata by ourselves, in addition, it’s not uncommon that
a GSE entity series matrix won’t contain the expression matrix, which is
almost the case of high-throughout sequencing data. `get_geo_suppl` is
designed for these conditions. Usually, the expression matrix will be
provided in the GSE supplementary files or in the GSM supplementary
files.

If the expression matrix is given in the GSE supplementary files, we can
download it directly use `get_geo_suppl`, which will return a character
vector containing the path of downloaded files.

``` r
gse160724 <- get_geo_suppl(
    ids = "GSE160724", tempdir(), 
    pattern = "counts_anno"
)
#> Downloading GSE160724_counts_anno.txt.gz from FTP site:
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
gse180383_smat <- get_geo(
    "GSE180383", tempdir(),
    gse_matrix = TRUE, add_gpl = FALSE,
    pdata_from_soft = FALSE
)
#> Downloading GSE180383_series_matrix.txt.gz from FTP site:
#> Warning: Cannot parse characteristic column correctly
#> • Details see `characteristics_ch1` column in `phenoData`
#> Warning: Please use `set_pdata` or `parse_pdata` function to convert it manually
#> if necessary!
#> Cannot map GPL21359 to a Bioconductor annotation package
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
gse180383_smat_gsm_suppl <- get_geo_suppl(gse180383_smat_gsmids, tempdir())
#> Downloading GSM5461787_trim_RNA_Mono_1_S13_R1_001_countsMatrix.txt.gz from FTP
#> site:
#> Downloading GSM5461788_trim_RNA_Mono_2_S14_R1_001_countsMatrix.txt.gz from FTP
#> site:
#> Downloading GSM5461789_trim_RNA_Mono_3_S15_R1_001_countsMatrix.txt.gz from FTP
#> site:
#> Downloading GSM5461790_trim_RNA_ab_1_S16_R1_001_countsMatrix.txt.gz from FTP
#> site:
#> Downloading GSM5461791_trim_RNA_ab_2_S17_R1_001_countsMatrix.txt.gz from FTP
#> site:
#> Downloading GSM5461792_trim_RNA_ab_3_S18_R1_001_countsMatrix.txt.gz from FTP
#> site:
```

Another way, we can also derive sample accession ids from GSE soft
files, which is what our laboratory prefers to since we can easily get
exact sample traits information as described in the above by utilizing
`parse_pdata` function.

``` r
gse180383_soft <- get_geo(
    "GSE180383", tempdir(),
    gse_matrix = FALSE
)
#> Downloading GSE180383_family.soft.gz from FTP site:
#> Found 7 entities...
#> GPL21359 (1 of 7 entities)
#> GSM5461787 (2 of 7 entities)
#> GSM5461788 (3 of 7 entities)
#> GSM5461789 (4 of 7 entities)
#> GSM5461790 (5 of 7 entities)
#> GSM5461791 (6 of 7 entities)
#> GSM5461792 (7 of 7 entities)
gse180383_soft_cli <- parse_pdata(gsm(gse180383_soft))
#> Warning: More than one characters ":" found in meta characteristics data`: 
#> • Details see: characteristics_ch1 column in returned data.
#> • Please use `set_pdata` or combine `strsplit` and `parse_pdata` function to convert it manually if necessary!
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
gse180383_soft_gsm_suppl <- get_geo_suppl(gse180383_soft_gsmids, tempdir())
#> Using locally cached version of GSM5461787_trim_RNA_Mono_1_S13_R1_001_countsMatrix.txt.gz found here: C:\Users\yunyu\AppData\Local\Temp\RtmpkxJgG3/GSM5461787_trim_RNA_Mono_1_S13_R1_001_countsMatrix.txt.gz
#> Using locally cached version of GSM5461788_trim_RNA_Mono_2_S14_R1_001_countsMatrix.txt.gz found here: C:\Users\yunyu\AppData\Local\Temp\RtmpkxJgG3/GSM5461788_trim_RNA_Mono_2_S14_R1_001_countsMatrix.txt.gz
#> Using locally cached version of GSM5461789_trim_RNA_Mono_3_S15_R1_001_countsMatrix.txt.gz found here: C:\Users\yunyu\AppData\Local\Temp\RtmpkxJgG3/GSM5461789_trim_RNA_Mono_3_S15_R1_001_countsMatrix.txt.gz
#> Using locally cached version of GSM5461790_trim_RNA_ab_1_S16_R1_001_countsMatrix.txt.gz found here: C:\Users\yunyu\AppData\Local\Temp\RtmpkxJgG3/GSM5461790_trim_RNA_ab_1_S16_R1_001_countsMatrix.txt.gz
#> Using locally cached version of GSM5461791_trim_RNA_ab_2_S17_R1_001_countsMatrix.txt.gz found here: C:\Users\yunyu\AppData\Local\Temp\RtmpkxJgG3/GSM5461791_trim_RNA_ab_2_S17_R1_001_countsMatrix.txt.gz
#> Using locally cached version of GSM5461792_trim_RNA_ab_3_S18_R1_001_countsMatrix.txt.gz found here: C:\Users\yunyu\AppData\Local\Temp\RtmpkxJgG3/GSM5461792_trim_RNA_ab_3_S18_R1_001_countsMatrix.txt.gz
```

### Other utilities

`rgeo` also provide some useful function to help better interact with
GEO.

- `show_geo` function: Require a geo entity id and open GEO Accession
  site in the default browser.
- `log_trans` function: Require a expression matrix and this function
  will check whether this expression matrix has experienced logarithmic
  transformation, if it hasn’t, `log_trans` will do it. This is a helper
  function used in `GEO2R`.

### sessionInfo

``` r
sessionInfo()
#> R version 4.2.1 (2022-06-23 ucrt)
#> Platform: x86_64-w64-mingw32/x64 (64-bit)
#> Running under: Windows 10 x64 (build 22000)
#> 
#> Matrix products: default
#> 
#> locale:
#> [1] LC_COLLATE=Chinese (Simplified)_China.utf8 
#> [2] LC_CTYPE=Chinese (Simplified)_China.utf8   
#> [3] LC_MONETARY=Chinese (Simplified)_China.utf8
#> [4] LC_NUMERIC=C                               
#> [5] LC_TIME=Chinese (Simplified)_China.utf8    
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] magrittr_2.0.3  rgeo_0.0.1.9000
#> 
#> loaded via a namespace (and not attached):
#>  [1] knitr_1.39           tidyselect_1.1.2     R6_2.5.1            
#>  [4] ragg_1.2.2.9000      rlang_1.0.4          fastmap_1.1.0       
#>  [7] fansi_1.0.3          stringr_1.4.0        dplyr_1.0.9         
#> [10] tools_4.2.1          data.table_1.14.3    xfun_0.31           
#> [13] utf8_1.2.2           DBI_1.1.3            cli_3.3.0           
#> [16] ellipsis_0.3.2       htmltools_0.5.3      systemfonts_1.0.4   
#> [19] assertthat_0.2.1     yaml_2.3.5           digest_0.6.29       
#> [22] tibble_3.1.8         lifecycle_1.0.1.9001 crayon_1.5.1        
#> [25] textshaping_0.3.6    purrr_0.3.4          vctrs_0.4.1         
#> [28] glue_1.6.2           evaluate_0.15        rmarkdown_2.14      
#> [31] stringi_1.7.8        compiler_4.2.1       pillar_1.8.0        
#> [34] generics_0.1.3       pkgconfig_2.0.3
```
