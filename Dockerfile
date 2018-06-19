# Dockerfile for Myeloid Pipeline based on centOS:7.4.1708
FROM ipm-dc-dtr.weill.cornell.edu/ipm/centos@sha256:cf98f0b57bf606eaee397b125c240f6bde5544480be3b7e46ad08934860434a9
#===============================#
# Docker Image Configuration	#
#===============================#
LABEL vendor="Englander Institute for Precision Medicine" \
		description="Bioinformatics Tools" \
		maintainer="ans2077@med.cornell.edu" \
		base_image="ipm-dc-dtr.weill.cornell.edu/ipm/centos" \
		base_image_version="7.4.1708.patched20180504" \
		base_image_SHA256="sha256:cf98f0b57bf606eaee397b125c240f6bde5544480be3b7e46ad08934860434a9"

ENV APP_NAME="bioinformatics" \
	TZ='US/Eastern' \
	PROGRAMS="opt"
#===========================#
# CentOS Preparation    	#
#===========================#
RUN yum groupinstall -y "Development Tools" && yum install -y \
		wget \
		tar \
		gcc \
		gcc-c++ \
		openssl-devel \
		zip \
		unzip \
		make \
		cmake \
		which \
		readline-devel \
		libX11-devel \
		libXt-devel \
		cairo-devel \
		pango-devel \
		lzo-devel \
		flex-devel \
		dejavu* \
		systemctl \
	&& yum -y clean all

#===========================#
# Install BEDTOOLS			#
#===========================#
ENV BEDTOOLS_VERSION 2.26.0
ENV bedtools_dir /${PROGRAMS}/bedtools2/bin/
RUN wget -O bedtools-${BEDTOOLS_VERSION}.tar.gz https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/bedtools-${BEDTOOLS_VERSION}.tar.gz \
 	&& tar zxf bedtools-${BEDTOOLS_VERSION}.tar.gz \
 	&& rm bedtools-${BEDTOOLS_VERSION}.tar.gz \
 	&& cd bedtools2 \
 	&& make
#===========================#
# Install SAMTOOLS & HTSLIB #
#===========================#
ENV SAMTOOLS_VERSION 1.2
ENV HTSLIB_VERSION 1.2.1
ENV samtools_dir /${PROGRAMS}/samtools-${SAMTOOLS_VERSION}
ENV htslib_dir ${samtools_dir}/htslib-${HTSLIB_VERSION}
RUN wget -O samtools-${SAMTOOLS_VERSION}.tar.bz2 https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
	&& tar jxf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
	&& rm samtools-${SAMTOOLS_VERSION}.tar.bz2 \
	&& cd samtools-${SAMTOOLS_VERSION} \
	&& make \
	&& cd htslib-${HTSLIB_VERSION} \
	&& make
#===========================#
# Install BCFTOOLS			#
#===========================#
ENV BCFTOOLS_VERSION 1.2
ENV bcftools_dir /${PROGRAMS}/bcftools-${BCFTOOLS_VERSION}
RUN wget -O bcftools-${BCFTOOLS_VERSION}.tar.bz2 https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
	&& tar jxf bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
	&& rm bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
	&& cd bcftools-${BCFTOOLS_VERSION} \
	&& make
#===========================#
# Install VCFTOOLS			#
#===========================#
ENV VCFTOOLS_VERSION="0.1.13"
ENV vcftools_dir /${PROGRAMS}/vcftools_${VCFTOOLS_VERSION}/bin/
RUN wget http://sourceforge.net/projects/vcftools/files/vcftools_${VCFTOOLS_VERSION}.tar.gz \
	&& tar zxf vcftools_${VCFTOOLS_VERSION}.tar.gz \
	&& rm vcftools_${VCFTOOLS_VERSION}.tar.gz \
	&& cd vcftools_${VCFTOOLS_VERSION} \
	&& make
#===========================#
# Install BWA				#
#===========================#
ENV BWA_VERSION 0.7.12
ENV bwa_dir /${PROGRAMS}/bwa-${BWA_VERSION}
RUN wget http://sourceforge.net/projects/bio-bwa/files/bwa-${BWA_VERSION}.tar.bz2 \
	&& tar jxf bwa-${BWA_VERSION}.tar.bz2 \
	&& rm bwa-${BWA_VERSION}.tar.bz2 \
	&& cd bwa-${BWA_VERSION} \
	&& sed -e's#INCLUDES=#INCLUDES=-I../zlib-${ZLIB_VERSION}/ #' -e's#-lz#../zlib-${ZLIB_VERSION}/libz.a#' Makefile > Makefile.zlib \
	&& make -f Makefile.zlib
#===========================#
# Install PINDEL			#
#===========================#
## PINDEL version: version 0.2.5b6, 20150915 (downloaded Nov 10 2015)
# https://github.com/genome/pindel/archive/v${PINDEL_VERSION}.tar.gz
ENV PINDEL_VERSION 0.2.5b6
ENV pindel_dir /${PROGRAMS}/pindel
RUN wget -O pindel-master.zip https://github.com/genome/pindel/archive/master.zip \
	&& unzip pindel-master.zip \
	&& rm pindel-master.zip \
	&& mv pindel-master pindel \
	&& cd pindel \
	&& ./INSTALL /${PROGRAMS}/samtools-${SAMTOOLS_VERSION}/htslib-${HTSLIB_VERSION}


