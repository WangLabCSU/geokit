if (getRversion() >= "2.15.1") {
    utils::globalVariables(
        c( # data.table
            "V1", 
            # Variable used in function `parse_gds_subset`
            "subset_sample_id",
            # variable used in function `gpl2bioc`
            "Platform_geo_accession", "bioc_pkg"
        )
    )
}
