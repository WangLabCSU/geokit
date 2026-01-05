# Parse key-value pairs in GEO series matrix file

Lots of GSEs now use `"characteristics_ch*"` for key-value pairs of
annotation. If that is the case, this simply cleans those up and
transforms the keys to column names and the values to column values.

## Usage

``` r
parse_pdata(data, columns = NULL, sep = ":", split = ";")
```

## Arguments

- data:

  A data.frame like object, tibble and data.table are also okay.

- columns:

  A character vector, should be ended with "(ch\d\*)(\\\d\*)?". these
  columns in `data` will be parsed. If `NULL`, all columns started with
  `"characteristics_ch"` will be used.

- sep:

  A string separating paired key-value, usually `":"`.

- split:

  Passed to [strsplit](https://rdrr.io/r/base/strsplit.html) function.
  Default is ";"\`.

## Value

A modified data.frame.

## Details

A characteristics annotation column usually contains multiple key-value
items, so we should first split these columns by `split` and then
extract `key-value` pairs. A new column will be added whose name is the
first group in the "(ch\d\*)(\\\d\*)?\$" regex pattern of the orginal
column name connected with `key` element in `key-value` pair by string
"\_" and the new column value is the character vector of `value` element
in all `key-value` pair.

## Examples

``` r
if (require(Biobase)) {
    gse53987 <- geo(
        "gse53987",
        gse_matrix = TRUE, add_gpl = FALSE,
        pdata_from_soft = FALSE,
        odir = tempdir()
    )
    gse53987_smp_info <- Biobase::pData(gse53987)
    gse53987_smp_info$characteristics_ch1 <- stringr::str_replace_all(
        gse53987_smp_info$characteristics_ch1,
        "gender|race|pmi|ph|rin|tissue|disease state",
        function(x) paste0("; ", x)
    )
    gse53987_smp_info <- parse_pdata(gse53987_smp_info)
    gse53987_smp_info[grepl(
        "^ch1_|characteristics_ch1", names(gse53987_smp_info)
    )]
}
#> Downloading 1 GSE matrix file from FTP site
#> → Parsing 1 series matrix file of GSE53987
#> Warning: Cannot parse characteristic column correctly
#> ℹ Details see "characteristics_ch1" column in phenoData
#> ℹ Please use `parse_pdata()` or `parse_gsm_list()` function to convert it
#>   manually if necessary!
#> ✔ Parsing 1 GSE series matrix successfully!
#> → Constructing <ExpressionSet>
#> ✔ Found Bioconductor annotation package for "GPL570"
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
