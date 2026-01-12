use extendr_api::extendr_module;

mod geo;
mod r;

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod geokit;
    use r;
}
