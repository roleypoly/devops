provider "google" {
    project = "${var.google-cloud-project}"
    region = "${var.google-cloud-region}"
    credentials = "${var.google-cloud-svcacct}"
}

provider "google-beta" {
    project = "${var.google-cloud-project}"
    region = "${var.google-cloud-region}"
    credentials = "${var.google-cloud-svcacct}"
}
