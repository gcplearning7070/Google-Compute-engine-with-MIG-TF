terraform {
  backend "gcs" {
    bucket = "gcp-tftbk"
    prefix = "Google-Compute-engine-with-MIG-TF"
  }
}
