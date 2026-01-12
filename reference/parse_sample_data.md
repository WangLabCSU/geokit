# Parse key-value pairs in the metadata of GEO Sample SOFT file

Lots of GSEs now use `"characteristics_ch*"` meta header data for
key-value pairs of annotation. If that is the case, this simply cleans
the **GEODatatable** `@metadata` slot up and transforms the keys to
column names and the values to column values.

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
  [GEOSeries](https://WangLabCSU.github.io/geokit/reference/GEO-class.md)
  object or a list of GEODatatable from the `@gsm` slot of a `GEOSeries`
  object.

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
gse201530_soft <- geo_soft("GSE201530", odir = tempdir())
#> Downloading 1 file
parse_sample_data(gse201530_soft)
#>                     title geo_accession                status submission_date
#> GSM6066090  Naive_17_Day0    GSM6066090 Public on Jun 11 2022     Apr 26 2022
#> GSM6066091  Naive_18_Day0    GSM6066091 Public on Jun 11 2022     Apr 26 2022
#> GSM6066092  Naive_24_Day0    GSM6066092 Public on Jun 11 2022     Apr 26 2022
#> GSM6066093  Naive_26_Day0    GSM6066093 Public on Jun 11 2022     Apr 26 2022
#> GSM6066094  Naive_27_Day0    GSM6066094 Public on Jun 11 2022     Apr 26 2022
#> GSM6066095  Naive_28_Day0    GSM6066095 Public on Jun 11 2022     Apr 26 2022
#> GSM6066096  Naive_29_Day0    GSM6066096 Public on Jun 11 2022     Apr 26 2022
#> GSM6066097  Naive_30_Day0    GSM6066097 Public on Jun 11 2022     Apr 26 2022
#> GSM6066098  Omicron_1_1st    GSM6066098 Public on Jun 11 2022     Apr 26 2022
#> GSM6066099  Omicron_2_1st    GSM6066099 Public on Jun 11 2022     Apr 26 2022
#> GSM6066100  Omicron_3_1st    GSM6066100 Public on Jun 11 2022     Apr 26 2022
#> GSM6066101  Omicron_4_1st    GSM6066101 Public on Jun 11 2022     Apr 26 2022
#> GSM6066102  Omicron_5_1st    GSM6066102 Public on Jun 11 2022     Apr 26 2022
#> GSM6066103  Omicron_6_1st    GSM6066103 Public on Jun 11 2022     Apr 26 2022
#> GSM6066104  Omicron_7_1st    GSM6066104 Public on Jun 11 2022     Apr 26 2022
#> GSM6066105  Omicron_8_1st    GSM6066105 Public on Jun 11 2022     Apr 26 2022
#> GSM6066106  Omicron_9_1st    GSM6066106 Public on Jun 11 2022     Apr 26 2022
#> GSM6066107 Omicron_10_1st    GSM6066107 Public on Jun 11 2022     Apr 26 2022
#> GSM6066108 Omicron_11_1st    GSM6066108 Public on Jun 11 2022     Apr 26 2022
#> GSM6066109 Omicron_12_1st    GSM6066109 Public on Jun 11 2022     Apr 26 2022
#> GSM6066110 Omicron_13_1st    GSM6066110 Public on Jun 11 2022     Apr 26 2022
#> GSM6066111 Omicron_14_1st    GSM6066111 Public on Jun 11 2022     Apr 26 2022
#> GSM6066112 Omicron_15_1st    GSM6066112 Public on Jun 11 2022     Apr 26 2022
#> GSM6066113 Omicron_16_1st    GSM6066113 Public on Jun 11 2022     Apr 26 2022
#> GSM6066114 Omicron_17_1st    GSM6066114 Public on Jun 11 2022     Apr 26 2022
#> GSM6066115 Omicron_18_1st    GSM6066115 Public on Jun 11 2022     Apr 26 2022
#> GSM6066116 Omicron_19_1st    GSM6066116 Public on Jun 11 2022     Apr 26 2022
#> GSM6066117 Omicron_20_1st    GSM6066117 Public on Jun 11 2022     Apr 26 2022
#> GSM6066118 Omicron_24_1st    GSM6066118 Public on Jun 11 2022     Apr 26 2022
#> GSM6066119 Omicron_25_1st    GSM6066119 Public on Jun 11 2022     Apr 26 2022
#> GSM6066120 Omicron_26_1st    GSM6066120 Public on Jun 11 2022     Apr 26 2022
#> GSM6066121 Omicron_27_1st    GSM6066121 Public on Jun 11 2022     Apr 26 2022
#> GSM6066122 Omicron_28_1st    GSM6066122 Public on Jun 11 2022     Apr 26 2022
#> GSM6066123 Omicron_29_1st    GSM6066123 Public on Jun 11 2022     Apr 26 2022
#> GSM6066124 Omicron_30_1st    GSM6066124 Public on Jun 11 2022     Apr 26 2022
#> GSM6066125 Omicron_31_1st    GSM6066125 Public on Jun 11 2022     Apr 26 2022
#> GSM6066126 Omicron_33_1st    GSM6066126 Public on Jun 11 2022     Apr 26 2022
#> GSM6066127 Omicron_34_1st    GSM6066127 Public on Jun 11 2022     Apr 26 2022
#> GSM6066128 Omicron_35_1st    GSM6066128 Public on Jun 11 2022     Apr 26 2022
#> GSM6066129 Omicron_37_1st    GSM6066129 Public on Jun 11 2022     Apr 26 2022
#> GSM6066130 Omicron_38_1st    GSM6066130 Public on Jun 11 2022     Apr 26 2022
#> GSM6066131 Omicron_42_1st    GSM6066131 Public on Jun 11 2022     Apr 26 2022
#> GSM6066132 Omicron_43_1st    GSM6066132 Public on Jun 11 2022     Apr 26 2022
#> GSM6066133 Omicron_48_1st    GSM6066133 Public on Jun 11 2022     Apr 26 2022
#> GSM6066134 Omicron_49_1st    GSM6066134 Public on Jun 11 2022     Apr 26 2022
#> GSM6066135 Omicron_50_1st    GSM6066135 Public on Jun 11 2022     Apr 26 2022
#> GSM6066136 Omicron_51_1st    GSM6066136 Public on Jun 11 2022     Apr 26 2022
#> GSM6066137 Omicron_52_1st    GSM6066137 Public on Jun 11 2022     Apr 26 2022
#> GSM6066138 Omicron_53_1st    GSM6066138 Public on Jun 11 2022     Apr 26 2022
#> GSM6066139 Omicron_55_1st    GSM6066139 Public on Jun 11 2022     Apr 26 2022
#> GSM6066140 Omicron_65_1st    GSM6066140 Public on Jun 11 2022     Apr 26 2022
#> GSM6066141 Omicron_66_1st    GSM6066141 Public on Jun 11 2022     Apr 26 2022
#> GSM6066142 Omicron_67_1st    GSM6066142 Public on Jun 11 2022     Apr 26 2022
#> GSM6066143 Omicron_68_1st    GSM6066143 Public on Jun 11 2022     Apr 26 2022
#> GSM6066144 Omicron_70_1st    GSM6066144 Public on Jun 11 2022     Apr 26 2022
#>            last_update_date type channel_count source_name_ch1 organism_ch1
#> GSM6066090      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066091      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066092      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066093      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066094      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066095      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066096      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066097      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066098      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066099      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066100      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066101      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066102      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066103      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066104      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066105      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066106      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066107      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066108      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066109      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066110      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066111      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066112      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066113      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066114      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066115      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066116      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066117      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066118      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066119      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066120      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066121      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066122      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066123      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066124      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066125      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066126      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066127      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066128      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066129      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066130      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066131      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066132      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066133      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066134      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066135      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066136      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066137      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066138      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066139      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066140      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066141      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066142      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066143      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#> GSM6066144      Jun 11 2022  SRA             1           PBMCs Homo sapiens
#>            taxid_ch1 characteristics_ch1 ch1_gender ch1_age
#> GSM6066090      9606        gender: ....       Male      58
#> GSM6066091      9606        gender: ....     Female      56
#> GSM6066092      9606        gender: ....     Female      37
#> GSM6066093      9606        gender: ....     Female      19
#> GSM6066094      9606        gender: ....     Female      31
#> GSM6066095      9606        gender: ....       Male      36
#> GSM6066096      9606        gender: ....     Female      21
#> GSM6066097      9606        gender: ....     Female      23
#> GSM6066098      9606        gender: ....       Male      50
#> GSM6066099      9606        gender: ....       Male      36
#> GSM6066100      9606        gender: ....     Female      30
#> GSM6066101      9606        gender: ....     Female      17
#> GSM6066102      9606        gender: ....       Male      20
#> GSM6066103      9606        gender: ....       Male      57
#> GSM6066104      9606        gender: ....       Male      30
#> GSM6066105      9606        gender: ....     Female      21
#> GSM6066106      9606        gender: ....       Male      23
#> GSM6066107      9606        gender: ....     Female      27
#> GSM6066108      9606        gender: ....     Female      80
#> GSM6066109      9606        gender: ....     Female      38
#> GSM6066110      9606        gender: ....       Male      39
#> GSM6066111      9606        gender: ....     Female      29
#> GSM6066112      9606        gender: ....     Female      55
#> GSM6066113      9606        gender: ....       Male      26
#> GSM6066114      9606        gender: ....       Male      83
#> GSM6066115      9606        gender: ....     Female      23
#> GSM6066116      9606        gender: ....     Female      20
#> GSM6066117      9606        gender: ....       Male      82
#> GSM6066118      9606        gender: ....     Female      51
#> GSM6066119      9606        gender: ....       Male      54
#> GSM6066120      9606        gender: ....     Female      83
#> GSM6066121      9606        gender: ....     Female      32
#> GSM6066122      9606        gender: ....       Male      36
#> GSM6066123      9606        gender: ....     Female      30
#> GSM6066124      9606        gender: ....     Female      28
#> GSM6066125      9606        gender: ....       Male      29
#> GSM6066126      9606        gender: ....       Male      61
#> GSM6066127      9606        gender: ....     Female      59
#> GSM6066128      9606        gender: ....     Female      54
#> GSM6066129      9606        gender: ....       Male      63
#> GSM6066130      9606        gender: ....     Female      62
#> GSM6066131      9606        gender: ....       Male      26
#> GSM6066132      9606        gender: ....     Female      24
#> GSM6066133      9606        gender: ....     Female      32
#> GSM6066134      9606        gender: ....     Female      35
#> GSM6066135      9606        gender: ....     Female      38
#> GSM6066136      9606        gender: ....     Female      37
#> GSM6066137      9606        gender: ....     Female      24
#> GSM6066138      9606        gender: ....     Female      40
#> GSM6066139      9606        gender: ....     Female      61
#> GSM6066140      9606        gender: ....     Female      42
#> GSM6066141      9606        gender: ....     Female      39
#> GSM6066142      9606        gender: ....     Female      39
#> GSM6066143      9606        gender: ....     Female      40
#> GSM6066144      9606        gender: ....       Male      28
#>            ch1_group (by covid-19 vaccination, prior infection)
#> GSM6066090                                      Healthy control
#> GSM6066091                                      Healthy control
#> GSM6066092                                      Healthy control
#> GSM6066093                                      Healthy control
#> GSM6066094                                      Healthy control
#> GSM6066095                                      Healthy control
#> GSM6066096                                      Healthy control
#> GSM6066097                                      Healthy control
#> GSM6066098                      Vaccination, No prior infection
#> GSM6066099                      Vaccination, No prior infection
#> GSM6066100                      Vaccination, No prior infection
#> GSM6066101                      Vaccination, No prior infection
#> GSM6066102                      Vaccination, No prior infection
#> GSM6066103                      Vaccination, No prior infection
#> GSM6066104                      Vaccination, No prior infection
#> GSM6066105                      Vaccination, No prior infection
#> GSM6066106                      Vaccination, No prior infection
#> GSM6066107                      Vaccination, No prior infection
#> GSM6066108                      Vaccination, No prior infection
#> GSM6066109                      Vaccination, No prior infection
#> GSM6066110                      No vaccination, Prior infection
#> GSM6066111                      Vaccination, No prior infection
#> GSM6066112                      Vaccination, No prior infection
#> GSM6066113                      Vaccination, No prior infection
#> GSM6066114                   No vaccination, No prior infection
#> GSM6066115                      Vaccination, No prior infection
#> GSM6066116                      Vaccination, No prior infection
#> GSM6066117                      Vaccination, No prior infection
#> GSM6066118                   No vaccination, No prior infection
#> GSM6066119                   No vaccination, No prior infection
#> GSM6066120                   No vaccination, No prior infection
#> GSM6066121                   No vaccination, No prior infection
#> GSM6066122                   No vaccination, No prior infection
#> GSM6066123                   No vaccination, No prior infection
#> GSM6066124                   No vaccination, No prior infection
#> GSM6066125                   No vaccination, No prior infection
#> GSM6066126                   No vaccination, No prior infection
#> GSM6066127                   No vaccination, No prior infection
#> GSM6066128                      No vaccination, Prior infection
#> GSM6066129                      No vaccination, Prior infection
#> GSM6066130                   No vaccination, No prior infection
#> GSM6066131                      No vaccination, Prior infection
#> GSM6066132                      No vaccination, Prior infection
#> GSM6066133                   No vaccination, No prior infection
#> GSM6066134                   No vaccination, No prior infection
#> GSM6066135                   No vaccination, No prior infection
#> GSM6066136                      No vaccination, Prior infection
#> GSM6066137                         Vaccination, Prior infection
#> GSM6066138                   No vaccination, No prior infection
#> GSM6066139                   No vaccination, No prior infection
#> GSM6066140                      Vaccination, No prior infection
#> GSM6066141                   No vaccination, No prior infection
#> GSM6066142                   No vaccination, No prior infection
#> GSM6066143                   No vaccination, No prior infection
#> GSM6066144                      No vaccination, Prior infection
#>            ch1_omicron sublineage ch1_days after positive pcr results
#> GSM6066090                     --                                  --
#> GSM6066091                     --                                  --
#> GSM6066092                     --                                  --
#> GSM6066093                     --                                  --
#> GSM6066094                     --                                  --
#> GSM6066095                     --                                  --
#> GSM6066096                     --                                  --
#> GSM6066097                     --                                  --
#> GSM6066098                   BA.1                               day 0
#> GSM6066099                   BA.1                               day 0
#> GSM6066100                   BA.1                               day 0
#> GSM6066101                   BA.1                               day 0
#> GSM6066102                   BA.1                               day 0
#> GSM6066103                   BA.1                               day 0
#> GSM6066104                   BA.1                               day 0
#> GSM6066105                   BA.1                               day 2
#> GSM6066106                   BA.1                               day 3
#> GSM6066107                   BA.1                               day 0
#> GSM6066108                   BA.1                               day 0
#> GSM6066109                   BA.1                               day 3
#> GSM6066110                   BA.1                               day 2
#> GSM6066111                   BA.1                               day 2
#> GSM6066112                   BA.1                               day 3
#> GSM6066113                   BA.1                               day 2
#> GSM6066114                   BA.1                               day 1
#> GSM6066115                   BA.1                               day 2
#> GSM6066116                   BA.1                               day 2
#> GSM6066117                   BA.1                               day 1
#> GSM6066118                   BA.1                               day 2
#> GSM6066119                   BA.1                               day 2
#> GSM6066120                   BA.1                               day 0
#> GSM6066121                   BA.1                               day 2
#> GSM6066122                   BA.1                               day 3
#> GSM6066123                   BA.1                               day 4
#> GSM6066124                   BA.1                               day 1
#> GSM6066125                   BA.1                               day 1
#> GSM6066126                   BA.1                               day 2
#> GSM6066127                   BA.1                               day 0
#> GSM6066128                   BA.1                               day 5
#> GSM6066129                   BA.1                               day 5
#> GSM6066130                   BA.1                               day 4
#> GSM6066131                   BA.1                               day 3
#> GSM6066132                   BA.1                               day 0
#> GSM6066133                   BA.1                               day 1
#> GSM6066134                   BA.1                               day 0
#> GSM6066135                   BA.1                               day 2
#> GSM6066136                   BA.1                               day 1
#> GSM6066137                   BA.1                               day 5
#> GSM6066138                   BA.1                               day 2
#> GSM6066139                   BA.1                               day 2
#> GSM6066140                   BA.1                               day 1
#> GSM6066141                   BA.1                               day 0
#> GSM6066142                   BA.1                               day 3
#> GSM6066143                   BA.1                               day 3
#> GSM6066144                   BA.1                               day 2
#>            ch1_disease state ch1_geographical location ch1_cell type
#> GSM6066090   Healthy control                   Austria          PBMC
#> GSM6066091   Healthy control                   Austria          PBMC
#> GSM6066092   Healthy control                   Austria          PBMC
#> GSM6066093   Healthy control                   Austria          PBMC
#> GSM6066094   Healthy control                   Austria          PBMC
#> GSM6066095   Healthy control                   Austria          PBMC
#> GSM6066096   Healthy control                   Austria          PBMC
#> GSM6066097   Healthy control                   Austria          PBMC
#> GSM6066098  COVID-19_Omicron                   Austria          PBMC
#> GSM6066099  COVID-19_Omicron                   Austria          PBMC
#> GSM6066100  COVID-19_Omicron                   Austria          PBMC
#> GSM6066101  COVID-19_Omicron                   Austria          PBMC
#> GSM6066102  COVID-19_Omicron                   Austria          PBMC
#> GSM6066103  COVID-19_Omicron                   Austria          PBMC
#> GSM6066104  COVID-19_Omicron                   Austria          PBMC
#> GSM6066105  COVID-19_Omicron                   Austria          PBMC
#> GSM6066106  COVID-19_Omicron                   Austria          PBMC
#> GSM6066107  COVID-19_Omicron                   Austria          PBMC
#> GSM6066108  COVID-19_Omicron                   Austria          PBMC
#> GSM6066109  COVID-19_Omicron                   Austria          PBMC
#> GSM6066110  COVID-19_Omicron                   Austria          PBMC
#> GSM6066111  COVID-19_Omicron                   Austria          PBMC
#> GSM6066112  COVID-19_Omicron                   Austria          PBMC
#> GSM6066113  COVID-19_Omicron                   Austria          PBMC
#> GSM6066114  COVID-19_Omicron                   Austria          PBMC
#> GSM6066115  COVID-19_Omicron                   Austria          PBMC
#> GSM6066116  COVID-19_Omicron                   Austria          PBMC
#> GSM6066117  COVID-19_Omicron                   Austria          PBMC
#> GSM6066118  COVID-19_Omicron                   Austria          PBMC
#> GSM6066119  COVID-19_Omicron                   Austria          PBMC
#> GSM6066120  COVID-19_Omicron                   Austria          PBMC
#> GSM6066121  COVID-19_Omicron                   Austria          PBMC
#> GSM6066122  COVID-19_Omicron                   Austria          PBMC
#> GSM6066123  COVID-19_Omicron                   Austria          PBMC
#> GSM6066124  COVID-19_Omicron                   Austria          PBMC
#> GSM6066125  COVID-19_Omicron                   Austria          PBMC
#> GSM6066126  COVID-19_Omicron                   Austria          PBMC
#> GSM6066127  COVID-19_Omicron                   Austria          PBMC
#> GSM6066128  COVID-19_Omicron                   Austria          PBMC
#> GSM6066129  COVID-19_Omicron                   Austria          PBMC
#> GSM6066130  COVID-19_Omicron                   Austria          PBMC
#> GSM6066131  COVID-19_Omicron                   Austria          PBMC
#> GSM6066132  COVID-19_Omicron                   Austria          PBMC
#> GSM6066133  COVID-19_Omicron                   Austria          PBMC
#> GSM6066134  COVID-19_Omicron                   Austria          PBMC
#> GSM6066135  COVID-19_Omicron                   Austria          PBMC
#> GSM6066136  COVID-19_Omicron                   Austria          PBMC
#> GSM6066137  COVID-19_Omicron                   Austria          PBMC
#> GSM6066138  COVID-19_Omicron                   Austria          PBMC
#> GSM6066139  COVID-19_Omicron                   Austria          PBMC
#> GSM6066140  COVID-19_Omicron                   Austria          PBMC
#> GSM6066141  COVID-19_Omicron                   Austria          PBMC
#> GSM6066142  COVID-19_Omicron                   Austria          PBMC
#> GSM6066143  COVID-19_Omicron                   Austria          PBMC
#> GSM6066144  COVID-19_Omicron                   Austria          PBMC
#>                                                                             growth_protocol_ch1
#> GSM6066090 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066091 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066092 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066093 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066094 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066095 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066096 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066097 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066098 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066099 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066100 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066101 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066102 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066103 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066104 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066105 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066106 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066107 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066108 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066109 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066110 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066111 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066112 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066113 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066114 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066115 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066116 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066117 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066118 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066119 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066120 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066121 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066122 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066123 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066124 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066125 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066126 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066127 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066128 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066129 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066130 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066131 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066132 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066133 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066134 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066135 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066136 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066137 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066138 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066139 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066140 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066141 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066142 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066143 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#> GSM6066144 Blood samples were collected from the COVID-19 patients infected by Omicron varient.
#>            molecule_ch1 extract_protocol_ch1 data_processing platform_id
#> GSM6066090    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066091    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066092    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066093    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066094    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066095    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066096    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066097    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066098    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066099    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066100    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066101    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066102    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066103    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066104    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066105    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066106    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066107    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066108    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066109    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066110    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066111    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066112    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066113    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066114    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066115    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066116    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066117    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066118    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066119    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066120    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066121    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066122    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066123    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066124    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066125    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066126    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066127    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066128    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066129    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066130    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066131    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066132    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066133    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066134    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066135    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066136    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066137    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066138    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066139    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066140    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066141    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066142    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066143    polyA RNA         The buff....    RNA-seq ....    GPL24676
#> GSM6066144    polyA RNA         The buff....    RNA-seq ....    GPL24676
#>              contact_name        contact_email contact_phone
#> GSM6066090 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066091 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066092 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066093 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066094 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066095 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066096 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066097 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066098 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066099 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066100 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066101 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066102 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066103 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066104 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066105 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066106 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066107 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066108 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066109 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066110 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066111 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066112 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066113 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066114 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066115 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066116 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066117 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066118 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066119 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066120 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066121 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066122 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066123 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066124 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066125 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066126 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066127 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066128 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066129 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066130 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066131 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066132 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066133 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066134 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066135 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066136 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066137 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066138 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066139 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066140 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066141 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066142 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066143 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#> GSM6066144 Hye Kyung,,Lee hyekyung.lee@nih.gov  301-435-6635
#>                               contact_laboratory
#> GSM6066090 Laboratory of Genetics and Physiology
#> GSM6066091 Laboratory of Genetics and Physiology
#> GSM6066092 Laboratory of Genetics and Physiology
#> GSM6066093 Laboratory of Genetics and Physiology
#> GSM6066094 Laboratory of Genetics and Physiology
#> GSM6066095 Laboratory of Genetics and Physiology
#> GSM6066096 Laboratory of Genetics and Physiology
#> GSM6066097 Laboratory of Genetics and Physiology
#> GSM6066098 Laboratory of Genetics and Physiology
#> GSM6066099 Laboratory of Genetics and Physiology
#> GSM6066100 Laboratory of Genetics and Physiology
#> GSM6066101 Laboratory of Genetics and Physiology
#> GSM6066102 Laboratory of Genetics and Physiology
#> GSM6066103 Laboratory of Genetics and Physiology
#> GSM6066104 Laboratory of Genetics and Physiology
#> GSM6066105 Laboratory of Genetics and Physiology
#> GSM6066106 Laboratory of Genetics and Physiology
#> GSM6066107 Laboratory of Genetics and Physiology
#> GSM6066108 Laboratory of Genetics and Physiology
#> GSM6066109 Laboratory of Genetics and Physiology
#> GSM6066110 Laboratory of Genetics and Physiology
#> GSM6066111 Laboratory of Genetics and Physiology
#> GSM6066112 Laboratory of Genetics and Physiology
#> GSM6066113 Laboratory of Genetics and Physiology
#> GSM6066114 Laboratory of Genetics and Physiology
#> GSM6066115 Laboratory of Genetics and Physiology
#> GSM6066116 Laboratory of Genetics and Physiology
#> GSM6066117 Laboratory of Genetics and Physiology
#> GSM6066118 Laboratory of Genetics and Physiology
#> GSM6066119 Laboratory of Genetics and Physiology
#> GSM6066120 Laboratory of Genetics and Physiology
#> GSM6066121 Laboratory of Genetics and Physiology
#> GSM6066122 Laboratory of Genetics and Physiology
#> GSM6066123 Laboratory of Genetics and Physiology
#> GSM6066124 Laboratory of Genetics and Physiology
#> GSM6066125 Laboratory of Genetics and Physiology
#> GSM6066126 Laboratory of Genetics and Physiology
#> GSM6066127 Laboratory of Genetics and Physiology
#> GSM6066128 Laboratory of Genetics and Physiology
#> GSM6066129 Laboratory of Genetics and Physiology
#> GSM6066130 Laboratory of Genetics and Physiology
#> GSM6066131 Laboratory of Genetics and Physiology
#> GSM6066132 Laboratory of Genetics and Physiology
#> GSM6066133 Laboratory of Genetics and Physiology
#> GSM6066134 Laboratory of Genetics and Physiology
#> GSM6066135 Laboratory of Genetics and Physiology
#> GSM6066136 Laboratory of Genetics and Physiology
#> GSM6066137 Laboratory of Genetics and Physiology
#> GSM6066138 Laboratory of Genetics and Physiology
#> GSM6066139 Laboratory of Genetics and Physiology
#> GSM6066140 Laboratory of Genetics and Physiology
#> GSM6066141 Laboratory of Genetics and Physiology
#> GSM6066142 Laboratory of Genetics and Physiology
#> GSM6066143 Laboratory of Genetics and Physiology
#> GSM6066144 Laboratory of Genetics and Physiology
#>                                                         contact_department
#> GSM6066090 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066091 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066092 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066093 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066094 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066095 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066096 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066097 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066098 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066099 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066100 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066101 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066102 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066103 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066104 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066105 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066106 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066107 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066108 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066109 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066110 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066111 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066112 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066113 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066114 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066115 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066116 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066117 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066118 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066119 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066120 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066121 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066122 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066123 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066124 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066125 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066126 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066127 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066128 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066129 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066130 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066131 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066132 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066133 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066134 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066135 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066136 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066137 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066138 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066139 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066140 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066141 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066142 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066143 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#> GSM6066144 National Institute of Diabetes and Digestive and Kidney (NIDDK)
#>                              contact_institute    contact_address contact_city
#> GSM6066090 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066091 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066092 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066093 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066094 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066095 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066096 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066097 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066098 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066099 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066100 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066101 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066102 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066103 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066104 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066105 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066106 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066107 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066108 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066109 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066110 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066111 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066112 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066113 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066114 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066115 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066116 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066117 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066118 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066119 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066120 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066121 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066122 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066123 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066124 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066125 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066126 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066127 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066128 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066129 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066130 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066131 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066132 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066133 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066134 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066135 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066136 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066137 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066138 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066139 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066140 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066141 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066142 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066143 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#> GSM6066144 National Institutes of Health (NIH) 8 CENTER DR RM 107     Bethesda
#>            contact_state contact_zip/postal_code contact_country
#> GSM6066090            MD                   20892             USA
#> GSM6066091            MD                   20892             USA
#> GSM6066092            MD                   20892             USA
#> GSM6066093            MD                   20892             USA
#> GSM6066094            MD                   20892             USA
#> GSM6066095            MD                   20892             USA
#> GSM6066096            MD                   20892             USA
#> GSM6066097            MD                   20892             USA
#> GSM6066098            MD                   20892             USA
#> GSM6066099            MD                   20892             USA
#> GSM6066100            MD                   20892             USA
#> GSM6066101            MD                   20892             USA
#> GSM6066102            MD                   20892             USA
#> GSM6066103            MD                   20892             USA
#> GSM6066104            MD                   20892             USA
#> GSM6066105            MD                   20892             USA
#> GSM6066106            MD                   20892             USA
#> GSM6066107            MD                   20892             USA
#> GSM6066108            MD                   20892             USA
#> GSM6066109            MD                   20892             USA
#> GSM6066110            MD                   20892             USA
#> GSM6066111            MD                   20892             USA
#> GSM6066112            MD                   20892             USA
#> GSM6066113            MD                   20892             USA
#> GSM6066114            MD                   20892             USA
#> GSM6066115            MD                   20892             USA
#> GSM6066116            MD                   20892             USA
#> GSM6066117            MD                   20892             USA
#> GSM6066118            MD                   20892             USA
#> GSM6066119            MD                   20892             USA
#> GSM6066120            MD                   20892             USA
#> GSM6066121            MD                   20892             USA
#> GSM6066122            MD                   20892             USA
#> GSM6066123            MD                   20892             USA
#> GSM6066124            MD                   20892             USA
#> GSM6066125            MD                   20892             USA
#> GSM6066126            MD                   20892             USA
#> GSM6066127            MD                   20892             USA
#> GSM6066128            MD                   20892             USA
#> GSM6066129            MD                   20892             USA
#> GSM6066130            MD                   20892             USA
#> GSM6066131            MD                   20892             USA
#> GSM6066132            MD                   20892             USA
#> GSM6066133            MD                   20892             USA
#> GSM6066134            MD                   20892             USA
#> GSM6066135            MD                   20892             USA
#> GSM6066136            MD                   20892             USA
#> GSM6066137            MD                   20892             USA
#> GSM6066138            MD                   20892             USA
#> GSM6066139            MD                   20892             USA
#> GSM6066140            MD                   20892             USA
#> GSM6066141            MD                   20892             USA
#> GSM6066142            MD                   20892             USA
#> GSM6066143            MD                   20892             USA
#> GSM6066144            MD                   20892             USA
#>                 instrument_model library_selection library_source
#> GSM6066090 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066091 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066092 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066093 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066094 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066095 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066096 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066097 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066098 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066099 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066100 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066101 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066102 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066103 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066104 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066105 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066106 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066107 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066108 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066109 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066110 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066111 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066112 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066113 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066114 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066115 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066116 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066117 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066118 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066119 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066120 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066121 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066122 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066123 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066124 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066125 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066126 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066127 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066128 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066129 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066130 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066131 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066132 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066133 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066134 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066135 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066136 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066137 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066138 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066139 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066140 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066141 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066142 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066143 Illumina NovaSeq 6000              cDNA transcriptomic
#> GSM6066144 Illumina NovaSeq 6000              cDNA transcriptomic
#>            library_strategy     relation
#> GSM6066090          RNA-Seq BioSampl....
#> GSM6066091          RNA-Seq BioSampl....
#> GSM6066092          RNA-Seq BioSampl....
#> GSM6066093          RNA-Seq BioSampl....
#> GSM6066094          RNA-Seq BioSampl....
#> GSM6066095          RNA-Seq BioSampl....
#> GSM6066096          RNA-Seq BioSampl....
#> GSM6066097          RNA-Seq BioSampl....
#> GSM6066098          RNA-Seq BioSampl....
#> GSM6066099          RNA-Seq BioSampl....
#> GSM6066100          RNA-Seq BioSampl....
#> GSM6066101          RNA-Seq BioSampl....
#> GSM6066102          RNA-Seq BioSampl....
#> GSM6066103          RNA-Seq BioSampl....
#> GSM6066104          RNA-Seq BioSampl....
#> GSM6066105          RNA-Seq BioSampl....
#> GSM6066106          RNA-Seq BioSampl....
#> GSM6066107          RNA-Seq BioSampl....
#> GSM6066108          RNA-Seq BioSampl....
#> GSM6066109          RNA-Seq BioSampl....
#> GSM6066110          RNA-Seq BioSampl....
#> GSM6066111          RNA-Seq BioSampl....
#> GSM6066112          RNA-Seq BioSampl....
#> GSM6066113          RNA-Seq BioSampl....
#> GSM6066114          RNA-Seq BioSampl....
#> GSM6066115          RNA-Seq BioSampl....
#> GSM6066116          RNA-Seq BioSampl....
#> GSM6066117          RNA-Seq BioSampl....
#> GSM6066118          RNA-Seq BioSampl....
#> GSM6066119          RNA-Seq BioSampl....
#> GSM6066120          RNA-Seq BioSampl....
#> GSM6066121          RNA-Seq BioSampl....
#> GSM6066122          RNA-Seq BioSampl....
#> GSM6066123          RNA-Seq BioSampl....
#> GSM6066124          RNA-Seq BioSampl....
#> GSM6066125          RNA-Seq BioSampl....
#> GSM6066126          RNA-Seq BioSampl....
#> GSM6066127          RNA-Seq BioSampl....
#> GSM6066128          RNA-Seq BioSampl....
#> GSM6066129          RNA-Seq BioSampl....
#> GSM6066130          RNA-Seq BioSampl....
#> GSM6066131          RNA-Seq BioSampl....
#> GSM6066132          RNA-Seq BioSampl....
#> GSM6066133          RNA-Seq BioSampl....
#> GSM6066134          RNA-Seq BioSampl....
#> GSM6066135          RNA-Seq BioSampl....
#> GSM6066136          RNA-Seq BioSampl....
#> GSM6066137          RNA-Seq BioSampl....
#> GSM6066138          RNA-Seq BioSampl....
#> GSM6066139          RNA-Seq BioSampl....
#> GSM6066140          RNA-Seq BioSampl....
#> GSM6066141          RNA-Seq BioSampl....
#> GSM6066142          RNA-Seq BioSampl....
#> GSM6066143          RNA-Seq BioSampl....
#> GSM6066144          RNA-Seq BioSampl....
#>                                                                                           supplementary_file_1
#> GSM6066090  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066090/suppl/GSM6066090_Naive_17_Day0.txt.gz
#> GSM6066091  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066091/suppl/GSM6066091_Naive_18_Day0.txt.gz
#> GSM6066092  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066092/suppl/GSM6066092_Naive_24_Day0.txt.gz
#> GSM6066093  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066093/suppl/GSM6066093_Naive_26_Day0.txt.gz
#> GSM6066094  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066094/suppl/GSM6066094_Naive_27_Day0.txt.gz
#> GSM6066095  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066095/suppl/GSM6066095_Naive_28_Day0.txt.gz
#> GSM6066096  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066096/suppl/GSM6066096_Naive_29_Day0.txt.gz
#> GSM6066097  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066097/suppl/GSM6066097_Naive_30_Day0.txt.gz
#> GSM6066098  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066098/suppl/GSM6066098_Omicron_1_1st.txt.gz
#> GSM6066099  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066099/suppl/GSM6066099_Omicron_2_1st.txt.gz
#> GSM6066100  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066100/suppl/GSM6066100_Omicron_3_1st.txt.gz
#> GSM6066101  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066101/suppl/GSM6066101_Omicron_4_1st.txt.gz
#> GSM6066102  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066102/suppl/GSM6066102_Omicron_5_1st.txt.gz
#> GSM6066103  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066103/suppl/GSM6066103_Omicron_6_1st.txt.gz
#> GSM6066104  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066104/suppl/GSM6066104_Omicron_7_1st.txt.gz
#> GSM6066105  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066105/suppl/GSM6066105_Omicron_8_1st.txt.gz
#> GSM6066106  ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066106/suppl/GSM6066106_Omicron_9_1st.txt.gz
#> GSM6066107 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066107/suppl/GSM6066107_Omicron_10_1st.txt.gz
#> GSM6066108 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066108/suppl/GSM6066108_Omicron_11_1st.txt.gz
#> GSM6066109 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066109/suppl/GSM6066109_Omicron_12_1st.txt.gz
#> GSM6066110 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066110/suppl/GSM6066110_Omicron_13_1st.txt.gz
#> GSM6066111 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066111/suppl/GSM6066111_Omicron_14_1st.txt.gz
#> GSM6066112 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066112/suppl/GSM6066112_Omicron_15_1st.txt.gz
#> GSM6066113 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066113/suppl/GSM6066113_Omicron_16_1st.txt.gz
#> GSM6066114 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066114/suppl/GSM6066114_Omicron_17_1st.txt.gz
#> GSM6066115 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066115/suppl/GSM6066115_Omicron_18_1st.txt.gz
#> GSM6066116 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066116/suppl/GSM6066116_Omicron_19_1st.txt.gz
#> GSM6066117 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066117/suppl/GSM6066117_Omicron_20_1st.txt.gz
#> GSM6066118 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066118/suppl/GSM6066118_Omicron_24_1st.txt.gz
#> GSM6066119 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066119/suppl/GSM6066119_Omicron_25_1st.txt.gz
#> GSM6066120 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066120/suppl/GSM6066120_Omicron_26_1st.txt.gz
#> GSM6066121 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066121/suppl/GSM6066121_Omicron_27_1st.txt.gz
#> GSM6066122 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066122/suppl/GSM6066122_Omicron_28_1st.txt.gz
#> GSM6066123 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066123/suppl/GSM6066123_Omicron_29_1st.txt.gz
#> GSM6066124 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066124/suppl/GSM6066124_Omicron_30_1st.txt.gz
#> GSM6066125 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066125/suppl/GSM6066125_Omicron_31_1st.txt.gz
#> GSM6066126 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066126/suppl/GSM6066126_Omicron_33_1st.txt.gz
#> GSM6066127 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066127/suppl/GSM6066127_Omicron_34_1st.txt.gz
#> GSM6066128 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066128/suppl/GSM6066128_Omicron_35_1st.txt.gz
#> GSM6066129 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066129/suppl/GSM6066129_Omicron_37_1st.txt.gz
#> GSM6066130 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066130/suppl/GSM6066130_Omicron_38_1st.txt.gz
#> GSM6066131 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066131/suppl/GSM6066131_Omicron_42_1st.txt.gz
#> GSM6066132 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066132/suppl/GSM6066132_Omicron_43_1st.txt.gz
#> GSM6066133 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066133/suppl/GSM6066133_Omicron_48_1st.txt.gz
#> GSM6066134 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066134/suppl/GSM6066134_Omicron_49_1st.txt.gz
#> GSM6066135 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066135/suppl/GSM6066135_Omicron_50_1st.txt.gz
#> GSM6066136 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066136/suppl/GSM6066136_Omicron_51_1st.txt.gz
#> GSM6066137 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066137/suppl/GSM6066137_Omicron_52_1st.txt.gz
#> GSM6066138 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066138/suppl/GSM6066138_Omicron_53_1st.txt.gz
#> GSM6066139 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066139/suppl/GSM6066139_Omicron_55_1st.txt.gz
#> GSM6066140 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066140/suppl/GSM6066140_Omicron_65_1st.txt.gz
#> GSM6066141 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066141/suppl/GSM6066141_Omicron_66_1st.txt.gz
#> GSM6066142 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066142/suppl/GSM6066142_Omicron_67_1st.txt.gz
#> GSM6066143 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066143/suppl/GSM6066143_Omicron_68_1st.txt.gz
#> GSM6066144 ftp://ftp.ncbi.nlm.nih.gov/geo/samples/GSM6066nnn/GSM6066144/suppl/GSM6066144_Omicron_70_1st.txt.gz
#>            series_id data_row_count
#> GSM6066090 GSE201530              0
#> GSM6066091 GSE201530              0
#> GSM6066092 GSE201530              0
#> GSM6066093 GSE201530              0
#> GSM6066094 GSE201530              0
#> GSM6066095 GSE201530              0
#> GSM6066096 GSE201530              0
#> GSM6066097 GSE201530              0
#> GSM6066098 GSE201530              0
#> GSM6066099 GSE201530              0
#> GSM6066100 GSE201530              0
#> GSM6066101 GSE201530              0
#> GSM6066102 GSE201530              0
#> GSM6066103 GSE201530              0
#> GSM6066104 GSE201530              0
#> GSM6066105 GSE201530              0
#> GSM6066106 GSE201530              0
#> GSM6066107 GSE201530              0
#> GSM6066108 GSE201530              0
#> GSM6066109 GSE201530              0
#> GSM6066110 GSE201530              0
#> GSM6066111 GSE201530              0
#> GSM6066112 GSE201530              0
#> GSM6066113 GSE201530              0
#> GSM6066114 GSE201530              0
#> GSM6066115 GSE201530              0
#> GSM6066116 GSE201530              0
#> GSM6066117 GSE201530              0
#> GSM6066118 GSE201530              0
#> GSM6066119 GSE201530              0
#> GSM6066120 GSE201530              0
#> GSM6066121 GSE201530              0
#> GSM6066122 GSE201530              0
#> GSM6066123 GSE201530              0
#> GSM6066124 GSE201530              0
#> GSM6066125 GSE201530              0
#> GSM6066126 GSE201530              0
#> GSM6066127 GSE201530              0
#> GSM6066128 GSE201530              0
#> GSM6066129 GSE201530              0
#> GSM6066130 GSE201530              0
#> GSM6066131 GSE201530              0
#> GSM6066132 GSE201530              0
#> GSM6066133 GSE201530              0
#> GSM6066134 GSE201530              0
#> GSM6066135 GSE201530              0
#> GSM6066136 GSE201530              0
#> GSM6066137 GSE201530              0
#> GSM6066138 GSE201530              0
#> GSM6066139 GSE201530              0
#> GSM6066140 GSE201530              0
#> GSM6066141 GSE201530              0
#> GSM6066142 GSE201530              0
#> GSM6066143 GSE201530              0
#> GSM6066144 GSE201530              0
```
