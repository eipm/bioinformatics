# Bioinformatics

This application provides some of the basic bioinformatics tools for development, debugging, and troubleshooting applications.

It includes:

* R 4.0.2
* bedtools (installed from distro with apt install: current version 2.27.1)
* samtools & htslib 1.8
* bcftools (installed from distro with apt install: current 1.10.2-3 using htslib 1.10.2-3)
* vcftools (installed from distro with apt install: current 0.1.16)
* bwa (installed from distro with apt install: current 0.7.17-r1188)
* pindel (latest:0.2.5b9, 20160729)

The installed tools are the latest available as of Aug 18, 2020.

**Note**: *pindel* includes a fix from a non-merged branch (see [Dockerfile](./Dockerfile)).

Common R packages are also installed. See `installPackages.R` to see which ones.

## Installation

To install the component for docker hub (assumining version 1.0.0):

```bash
docker pull eipm/bioinformatics:1.0.0
```

The user must have successfully logged in the docker DTR with `docker login`  

## Usage

The basic way to use this component is:

```bash
docker run --rm -it --name bioinfo <DTR-URL>/bioinformatics:1.0.0  /bin/bash
```

If specific file mounts are needed, use the `-v` option (see [docker run reference documentation](https://docs.docker.com/engine/reference/run/)). For example:

```bash
docker run --rm -it --name bioinfo -v /path/to/local/folder/:/path/to/internal/folder eipm/bioinformatics:1.0.0  /bin/bash
```

**Tip**: use the `:ro` option to mount read-only folders, e.g. `-v /path/to/local/folder/:/path/to/internal/folder:ro`
