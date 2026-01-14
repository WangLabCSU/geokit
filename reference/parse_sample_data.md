# Parse key-value pairs in the metadata of GEO Sample SOFT file

Lots of GSEs now use `"characteristics_ch*"` meta header data for
key-value pairs of annotation. If that is the case, this simply cleans
the **GEOSoft** `@metadata` slot up and transforms the keys to column
names and the values to column values.

## Usage

``` r
parse_sample_data(x, ...)

# S3 method for class 'GEOSeries'
parse_sample_data(x, ...)

# S3 method for class 'data.frame'
parse_sample_data(x, ..., fields = NULL, sep = ":")

# S3 method for class 'list'
parse_sample_data(x, ...)
```

## Arguments

- x:

  A
  [GEOSeries](https://WangLabCSU.github.io/geokit/reference/GEOSoft-class.md)
  object, a list of
  [GEOSoft](https://WangLabCSU.github.io/geokit/reference/GEOSoft-class.md)
  from the `@gsm` slot of a `GEOSeries` object, or a data frame from
  Series matrix file data table.

- ...:

  Additional arguments passed on to methods.

- fields:

  A character vector which fields should be parsed.

- sep:

  A single byte string defined the pairing separator.

## Value

A data.frame whose rows are samples and columns are the sample infos

## Examples

``` r
# \donttest{
gse201530_soft <- geo_soft("GSE201530", odir = tempdir())
#> Downloading 1 file
head(parse_sample_data(gse201530_soft))
#>                    title geo_accession                status submission_date
#> GSM6066090 Naive_17_Day0    GSM6066090 Public on Jun 11 2022     Apr 26 2022
#> GSM6066091 Naive_18_Day0    GSM6066091 Public on Jun 11 2022     Apr 26 2022
#> GSM6066092 Naive_24_Day0    GSM6066092 Public on Jun 11 2022     Apr 26 2022
#> GSM6066093 Naive_26_Day0    GSM6066093 Public on Jun 11 2022     Apr 26 2022
#> GSM6066094 Naive_27_Day0    GSM6066094 Public on Jun 11 2022     Apr 26 2022
#> GSM6066095 Naive_28_Day0    GSM6066095 Public on Jun 11 2022     Apr 26 2022
#>            last_update_date type channel_count source_name_ch1 organism_ch1
#> GSM6066090      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066091      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066092      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066093      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066094      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066095      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#>            taxid_ch1 characteristics_ch1 ch1_gender ch1_age
#> GSM6066090      9606        gender: ....       Male      58
#> GSM6066091      9606        gender: ....     Female      56
#> GSM6066092      9606        gender: ....     Female      37
#> GSM6066093      9606        gender: ....     Female      19
#> GSM6066094      9606        gender: ....     Female      31
#> GSM6066095      9606        gender: ....       Male      36
#>            ch1_group (by covid-19 vaccination, prior infection)
#> GSM6066090                                      Healthy control
#> GSM6066091                                      Healthy control
#> GSM6066092                                      Healthy control
#> GSM6066093                                      Healthy control
#> GSM6066094                                      Healthy control
#> GSM6066095                                      Healthy control
#>            ch1_omicron sublineage ch1_days after positive pcr results
#> GSM6066090                     --                                  --
#> GSM6066091                     --                                  --
#> GSM6066092                     --                                  --
#> GSM6066093                     --                                  --
#> GSM6066094                     --                                  --
#> GSM6066095                     --                                  --
#>            ch1_disease state ch1_geographical location ch1_cell type
#> GSM6066090   Healthy control                   Austria          PBMC
#> GSM6066091   Healthy control                   Austria          PBMC
#> GSM6066092   Healthy control                   Austria          PBMC
#> GSM6066093   Healthy control                   Austria          PBMC
#> GSM6066094   Healthy control                   Austria          PBMC
#> GSM6066095   Healthy control                   Austria          PBMC
#>                                                                             growth_protocol_ch1
#> GSM6066090 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066091 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066092 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066093 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066094 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066095 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#>            molecule_ch1 extract_protocol_ch1 data_processing platform_id
#> GSM6066090    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066091    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066092    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066093    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066094    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066095    polyA RNA         The buff....    RNA-seq ....    GPL24676
#>              contact_name        contact_email contact_phone
#> GSM6066090 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066091 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066092 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066093 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066094 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066095 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#>                               contact_laboratory
#> GSM6066090 Laboratory of Genetics and Physiology
#> GSM6066091 Laboratory of Genetics and Physiology
#> GSM6066092 Laboratory of Genetics and Physiology
#> GSM6066093 Laboratory of Genetics and Physiology
#> GSM6066094 Laboratory of Genetics and Physiology
#> GSM6066095 Laboratory of Genetics and Physiology
#>                                                         contact_department
#> GSM6066090 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066091 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066092 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066093 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066094 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066095 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#>                              contact_institute    contact_address contact_city
#> GSM6066090 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066091 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066092 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066093 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066094 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066095 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#>            contact_state contact_zip/postal_code contact_country
#> GSM6066090            MD                   20892             USA
#> GSM6066091            MD                   20892             USA
#> GSM6066092            MD                   20892             USA
#> GSM6066093            MD                   20892             USA
#> GSM6066094            MD                   20892             USA
#> GSM6066095            MD                   20892             USA
#>                 instrument_model library_selection library_source
#> GSM6066090 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066091 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066092 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066093 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066094 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066095 Illumina NovaSeq 6000              cDNA transcriptomic
#>            library_strategy     relation
#> GSM6066090          RNA-Seq BioSampl....
#> GSM6066091          RNA-Seq BioSampl....
#> GSM6066092          RNA-Seq BioSampl....
#> GSM6066093          RNA-Seq BioSampl....
#> GSM6066094          RNA-Seq BioSampl....
#> GSM6066095          RNA-Seq BioSampl....
#>                                                                                          supplementary_file_1
#> GSM6066090 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066090/suppl/GSM6066090_Naive_17_Day0.txt.gz
#> GSM6066091 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066091/suppl/GSM6066091_Naive_18_Day0.txt.gz
#> GSM6066092 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066092/suppl/GSM6066092_Naive_24_Day0.txt.gz
#> GSM6066093 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066093/suppl/GSM6066093_Naive_26_Day0.txt.gz
#> GSM6066094 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066094/suppl/GSM6066094_Naive_27_Day0.txt.gz
#> GSM6066095 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066095/suppl/GSM6066095_Naive_28_Day0.txt.gz
#>            series_id data_row_count
#> GSM6066090 GSE201530              0
#> GSM6066091 GSE201530              0
#> GSM6066092 GSE201530              0
#> GSM6066093 GSE201530              0
#> GSM6066094 GSE201530              0
#> GSM6066095 GSE201530              0
# }
```
