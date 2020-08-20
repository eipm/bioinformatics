FROM rocker/tidyverse:4.0.2 as rstudio

#===============================#
# Docker Image Configuration	#
#===============================#
LABEL vendor="Englander Institute for Precision Medicine" \
		description="Bioinformatics Tools" \
		maintainer="ans2077@med.cornell.edu" \
		base_image="rocker/tidyverse" \
		base_image_version="4.0.2" \
    	base_image_SHA256="sha256:cbc4ee809d594f0f6765be1d0fa046f48dfcda7340b5830473dd28fc71940c3c"

ENV APP_NAME="bioinformatics" \
	TZ='US/Eastern' \
	PROGRAMS="opt"
#===========================#
# Tidyverse Preparation    	#
#===========================#
RUN apt-get update && apt-get upgrade -y --fix-missing
RUN apt-get install build-essential -y && apt-get install -y \
 	vim \
	emacs \
	bedtools \
	bcftools \
	vcftools \
	bwa \
	libncurses5-dev \
	libbz2-dev \
	liblzma-dev 

#===========================#
# Install BEDTOOLS			#
#===========================#
# ENV BEDTOOLS_VERSION 2.27.1
# ENV bedtools_dir /${PROGRAMS}/bedtools-${BEDTOOLS_VERSION}
# RUN wget -O bedtools-${BEDTOOLS_VERSION}.tar.gz https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/bedtools-${BEDTOOLS_VERSION}.tar.gz \
#  	&& tar zxf bedtools-${BEDTOOLS_VERSION}.tar.gz -C ${PROGRAMS} \
#  	&& rm bedtools-${BEDTOOLS_VERSION}.tar.gz \
#  	&& cd ${PROGRAMS}/bedtools2 \
#  	&& make \
# 	&& make install
#===========================#
# Install SAMTOOLS & HTSLIB #
#===========================#
ENV SAMTOOLS_VERSION 1.9
ENV HTSLIB_VERSION 1.9
ENV samtools_dir /${PROGRAMS}/samtools-${SAMTOOLS_VERSION}
ENV htslib_dir ${samtools_dir}/htslib-${HTSLIB_VERSION}
RUN wget -O samtools-${SAMTOOLS_VERSION}.tar.bz2 https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
	&& tar jxf samtools-${SAMTOOLS_VERSION}.tar.bz2 -C ${PROGRAMS} \
	&& rm samtools-${SAMTOOLS_VERSION}.tar.bz2 \
	&& cd ${samtools_dir} \
	&& make \
	&& make install \
	&& cd htslib-${HTSLIB_VERSION} \
	&& make \
	&& make install
# #===========================#
# # Install BCFTOOLS			#
# #===========================#
# ENV BCFTOOLS_VERSION 1.8
# ENV bcftools_dir /${PROGRAMS}/bcftools-${BCFTOOLS_VERSION}
# RUN wget -O bcftools-${BCFTOOLS_VERSION}.tar.bz2 https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
# 	&& tar jxf bcftools-${BCFTOOLS_VERSION}.tar.bz2 -C ${PROGRAMS} \
# 	&& rm bcftools-${BCFTOOLS_VERSION}.tar.bz2 \
# 	&& cd ${bcftools_dir} \
# 	&& make \
# 	&& make install
#===========================#
# Install VCFTOOLS			#
#===========================#
# ENV VCFTOOLS_VERSION 0.1.15
# ENV vcftools_dir ${PROGRAMS}/vcftools-${VCFTOOLS_VERSION}
# RUN wget -O vcftools-${VCFTOOLS_VERSION}.tar.gz https://github.com/vcftools/vcftools/releases/download/v${VCFTOOLS_VERSION}/vcftools-${VCFTOOLS_VERSION}.tar.gz \
# 	&& tar zxf vcftools-${VCFTOOLS_VERSION}.tar.gz -C ${PROGRAMS} \
# 	&& rm vcftools-${VCFTOOLS_VERSION}.tar.gz \
# 	&& cd ${vcftools_dir} \
# 	&& ./configure --bindir=/usr/local/bin \
# 	&& make \
# 	&& make install
#===========================#
# Install BWA				#
#===========================#
# ENV BWA_VERSION 0.7.17
# ENV bwa_dir /${PROGRAMS}/bwa-${BWA_VERSION}
# RUN wget -O bwa-${BWA_VERSION}.tar.bz2 http://sourceforge.net/projects/bio-bwa/files/bwa-${BWA_VERSION}.tar.bz2 \
# 	&& tar jxf bwa-${BWA_VERSION}.tar.bz2 -C /${PROGRAMS} \
# 	&& rm bwa-${BWA_VERSION}.tar.bz2 \
# 	&& cd ${bwa_dir} \
# 	&& make -f Makefile

#===========================#
# Install PINDEL			#
#===========================#
ENV pindel_dir /${PROGRAMS}/pindel
RUN cd ${PROGRAMS} \
	&& git clone https://github.com/genome/pindel \
	&& cd pindel \
	&& git fetch origin pull/64/head:fix \
	&& git checkout fix \
	&& ./INSTALL ${htslib_dir}

## PINDEL version: version 0.2.5b6, 20150915 (downloaded Nov 10 2015)
# https://github.com/genome/pindel/archive/v${PINDEL_VERSION}.tar.gz
# ENV PINDEL_VERSION 0.2.5b6
# ENV pindel_dir /${PROGRAMS}/pindel
# RUN wget -O pindel-master.zip https://github.com/genome/pindel/archive/master.zip \
# 	&& unzip pindel-master.zip \	
# 	&& rm pindel-master.zip \
# 	&& mv pindel-master pindel \
# 	&& cd pindel \
	# && ./INSTALL ${htslib_dir}/htslib-${HTSLIB_VERSION}
	# && ./INSTALL /${PROGRAMS}/samtools-${SAMTOOLS_VERSION}/htslib-${HTSLIB_VERSION}
# RUN ln -s    ${bwa_dir}/bwa /usr/local/bin/bwa \
# 	&& ln -s ${pindel_dir}/pindel /usr/local/bin/pindel 
RUN ln -s ${pindel_dir}/pindel /usr/local/bin/pindel 
RUN apt-get upgrade -y && apt-get -y clean all

## Adding common R libraries
RUN mkdir -p /R/scripts
ADD installPackages.R /R/scripts
RUN Rscript /R/scripts/installPackages.R 

### Add utilities file
COPY combine_pindel_vcfs.sh ${PROGRAMS}
COPY transformBAM.sh /usr/local/bin/
RUN chmod ugo+x /usr/local/bin/transformBAM.sh

#===========================#
# Security Updates			#
#===========================#
# ENV GHOSTSCRIPT_VER 9.52
# ENV GS_VER 952
# ENV GHOSTSCRIPT_DIR /${PROGRAMS}/ghostscript-${GHOSTSCRIPT_VER}
# RUN wget -O ghostscript-${GHOSTSCRIPT_VER}.tar.gz https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs952/ghostscript-9.52.tar.gz \
# 	&& tar -vxzf ghostscript-${GHOSTSCRIPT_VER}.tar.gz -C ${PROGRAMS} \
# 	&& rm ghostscript-${GHOSTSCRIPT_VER}.tar.gz \
# 	&& cd ${GHOSTSCRIPT_DIR} \
# 	&& ./configure \
# 	&& make \
# 	&& make install
