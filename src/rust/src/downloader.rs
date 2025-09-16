use std::path::Path;
use std::result::Result;

use anyhow::Context;
use tokio::fs::File;
use tokio::io::AsyncWriteExt;
use tokio_stream::StreamExt;

pub(crate) async fn http_download(
    client: &reqwest::Client,
    url: &str,
    fname: &str,
    odir: &Path,
) -> Result<String, String> {
    // fetch and stream the data
    let mut stream = client
        .get(url)
        .send()
        .await
        .map_err(|e| format!("request error: {}", e))?
        .error_for_status()
        .with_context(|| format!("Failed to download from {}", url))
        .map_err(|e| e.to_string())?
        .bytes_stream();

    // create output file
    let ofile = odir.join(fname);
    let mut file = File::create(&ofile)
        .await
        .with_context(|| format!("Failed to create {:?}", ofile))
        .map_err(|e| e.to_string())?;

    // write to file
    while let Some(chunk) = stream
        .try_next()
        .await
        .with_context(|| format!("Failed to download from {}", url))
        .map_err(|e| e.to_string())?
    {
        file.write_all(&chunk)
            .await
            .with_context(|| format!("Failed to write to {:?}", ofile))
            .map_err(|e| e.to_string())?;
    }

    Ok(ofile.to_string_lossy().into_owned())
}
