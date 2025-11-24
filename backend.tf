terraform {
  backend "gcs" {
    bucket = "gcp-tftbk2"
    prefix = "Google-Compute-engine-with-MIG-TF"
  }
}
