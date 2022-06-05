if (getRversion() >= "2.15.1") {
    utils::globalVariables(
        c( # data.table
            "V1", "subset_sample_id"
        )
    )
}
