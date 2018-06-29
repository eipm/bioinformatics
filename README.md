# Bioinformatics
This application provides some of the basic bioinformatics tools for development, debugging, and troubleshooting applications. 

It includes:
* R 3.5.0
* bedtools 2.27.1
* samtools & htslib 1.8
* bcftools 1.8
* vcftools 0.1.15
* bwa 0.7.17-r1188
* pindel (latest:0.2.5b9, 20160729)

The installed tools are the latest available as of Jun 29, 2018.

**Note**: *pindel* includes a fix from a non-merged branch (see [Dockerfile](./Dockerfile)).

## Installation
To install the component:
```
docker pull ipm-dc-dtr.weill.cornell.edu/ipm/bioinformatics:1.0.0
```
The user must have successfully logged in the docker DTR with `docker login`  

## Usage:
The basic way to use this component is:
```
docker run --rm -it --name bioinfo ipm-dc-dtr.weill.cornell.edu/ipm/bioinformatics:1.0.0  /bin/bash
```

If specific file mounts are needed, use the `-v` option (see [docker run reference documentation](https://docs.docker.com/engine/reference/run/))
