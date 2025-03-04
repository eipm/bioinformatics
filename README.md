# Bioinformatics

This application provides some of the basic bioinformatics tools for development, debugging, and troubleshooting applications.

[![Actions Status](https://github.com/eipm/bioinformatics/workflows/Docker/badge.svg)](https://github.com/eipm/bioinformatics/actions) [![Github](https://img.shields.io/badge/github-1.5.1-green?style=flat&logo=github)](https://github.com/eipm/bioinformatics) [![EIPM Docker Hub](https://img.shields.io/badge/EIPM%20docker%20hub-1.5.1-blue?style=flat&logo=docker)](https://hub.docker.com/repository/docker/eipm/bioinformatics) [![GitHub Container Registry](https://img.shields.io/badge/GitHub%20Container%20Registry-1.5.1-blue?style=flat&logo=docker)](https://github.com/orgs/eipm/packages/container/package/bioinformatics)

## 🤝 License
See [LICENSE](./LICENSE)

## 📚 How to Cite
> Andrea Sboner, Alexandros Sigaras, Andrea Sboner Lab, Evan Fernandez, RadiumPlatypus, & kathryn gorski. (2025). eipm/bioinformatics: v1.5.1 (v1.5.1.patched20250304). Zenodo. [https://doi.org/10.5281/zenodo.14968809](https://doi.org/10.5281/zenodo.14968809)

## Components

It includes:

* R 4.2.2
* bedtools (installed from distro with apt install: current version v2.30.0)
* bcftools (installed from distro with apt install: current 1.13 (using htslib 1.13+ds)
* vcftools (installed from distro with apt install: current 0.1.16)
* bwa (installed from distro with apt install: current 0.7.17-r1188)
* samtools (1.19 (using htslib 1.19))
* pindel (latest:0.2.5b9, 20160729)
* STAR (2.7.6a)

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
docker run --rm -it --name bioinfo -u $(id -u):$(id -g) eipm/bioinformatics:1.0.0  /bin/bash
```

If specific file mounts are needed, use the `-v` option (see [docker run reference documentation](https://docs.docker.com/engine/reference/run/)). For example:

```bash
docker run --rm -it --name bioinfo -u $(id -u):$(id -g) -v /path/to/local/folder/:/path/to/internal/folder eipm/bioinformatics:1.0.0  /bin/bash
```

**Tip**: use the `:ro` option to mount read-only folders, e.g. `-v /path/to/local/folder/:/path/to/internal/folder:ro`

### Combine pindel VCFs
This utility `combine_pindel_vcfs.sh` takes multiple pindel results and merge them [TBDs]
