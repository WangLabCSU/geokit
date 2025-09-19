use std::path::Path;

use anyhow::{anyhow, Context, Result};
use reqwest::Client;
use tokio::fs::File;
use tokio::io::AsyncWriteExt;
use tokio_stream::StreamExt;

use crate::resolver::{GEOEntry, GEOResolver};

struct GEODownloader {
    urls: Vec<String>,
    fnames: Vec<String>,
}

impl GEODownloader {
    fn new() -> Self {
        Self {
            urls: Vec::new(),
            fnames: Vec::new(),
        }
    }

    fn collect(&mut self, resolver: GEOResolver) -> Result<()> {
        let entry = resolver.entry().ok_or_else(|| anyhow!("No entry found"))?;
        if let GEOEntry::File(fname) = entry {
            self.urls.push(resolver.url());
            self.fnames.push(fname);
        }
        Ok(())
    }
}

#[allow(dead_code)]
async fn http_download(
    client: &Client,
    url: &str,
    fname: &str,
    odir: &Path,
) -> Result<String, String> {
    // `HTTP_PROXY` or `http_proxy` provide HTTP proxies for HTTP connections
    // while `HTTPS_PROXY` or `https_proxy` provide HTTPS proxies for HTTPS
    // connections. `ALL_PROXY` or `all_proxy` provide proxies for both HTTP and
    // HTTPS connections

    // fetch and stream the data
    let mut stream = client
        .get(url)
        .send()
        .await
        .with_context(|| "request error".to_string())
        .map_err(|e| format!("{:?}", e))?
        .error_for_status()
        .with_context(|| format!("Failed to download from {}", url))
        .map_err(|e| e.to_string())?
        .bytes_stream();

    // create output file
    let ofile = odir.join(fname);
    let mut file = File::create(&ofile)
        .await
        .with_context(|| format!("Failed to create {:?}", ofile))
        .map_err(|e| format!("{:?}", e))?;

    // write to file
    while let Some(chunk) = stream
        .try_next()
        .await
        .with_context(|| format!("Failed to download from {}", url))
        .map_err(|e| format!("{:?}", e))?
    {
        file.write_all(&chunk)
            .await
            .with_context(|| format!("Failed to write to {:?}", ofile))
            .map_err(|e| e.to_string())?;
    }

    Ok(ofile.to_string_lossy().into_owned())
}
