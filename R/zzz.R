if (getRversion() >= "2.15.1") {
    utils::globalVariables(
        c( # run_absolute
            "V1", ".SD", ":="
        )
    )
}
