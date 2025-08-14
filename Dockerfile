FROM rocker/tidyverse:4.5.1 as rstudio

#===============================#
# Docker Image Configuration	#
#===============================#
LABEL org.opencontainers.image.source='https://github.com/eipm/bioinformatics' \
	vendor="Englander Institute for Precision Medicine" \
	description="Bioinformatics Tools" \
	maintainer="ans2077@med.cornell.edu" \
	base_image="rocker/tidyverse" \
	base_image_version="4.2.2"

ENV APP_NAME="bioinformatics" \
	TZ='US/Eastern' \
	PROGRAMS="opt"
#===========================#
# Tidyverse Preparation    	#
#===========================#
RUN apt-get update \
	&& apt-get upgrade -y --fix-missing \
	&& apt-get install build-essential -y \
	&& apt-get install -y \
	libncurses5-dev \
	libbz2-dev \
	liblzma-dev \
	python-htseq \
	&& rm -rf /var/lib/apt/lists/*

#===========================#
# Install SAMTOOLS & HTSLIB #
#===========================#
ENV SAMTOOLS_VERSION 1.19
ENV HTSLIB_VERSION 1.19
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
RUN cp ${pindel_dir}/pindel /usr/local/bin/pindel 

#===========================#
# Install STAR              #
#===========================#
ENV STAR_VERSION 2.7.6a
ENV star_dir /${PROGRAMS}/STAR-${STAR_VERSION}
RUN wget -O STAR-${STAR_VERSION}.tar.gz https://github.com/alexdobin/STAR/archive/2.7.6a.tar.gz \
	&& tar xzf STAR-${STAR_VERSION}.tar.gz -C ${PROGRAMS} \
	&& rm STAR-${STAR_VERSION}.tar.gz \
	&& cd ${star_dir}/source \
	&& make STAR \
	&& cp STAR /usr/local/bin/
RUN apt-get upgrade -y && apt-get -y clean all


#===========================#
# Install MAFFT             #
#===========================#
ENV MAFFT_VERSION="7.526"
RUN  wget --no-check-certificate -O mafft_${MAFFT_VERSION}-1_amd64.deb https://mafft.cbrc.jp/alignment/software/mafft_${MAFFT_VERSION}-1_amd64.deb \
     && dpkg -i mafft_${MAFFT_VERSION}-1_amd64.deb \
     && rm mafft_${MAFFT_VERSION}-1_amd64.deb

## Multi-stage build
FROM rocker/tidyverse:4.5.1

ENV APP_NAME="bioinformatics" \
	TZ='US/Eastern' \
	PROGRAMS="opt" \
	STAR_VERSION='2.7.6a' \
	SAMTOOLS_VERSION='1.19' \
	HTSLIB_VERSION='1.19'

RUN apt-get update \
	&& apt-get upgrade -y --fix-missing \
	&& apt-get install -y \
	vim \
	emacs \
	bedtools \
	bcftools \
	vcftools \
	bwa \ 
	pigz \
	&& apt-get -y clean all
	
COPY --from=rstudio /usr/local/bin /usr/local/bin
RUN true
COPY --from=rstudio /${PROGRAMS}/samtools-${SAMTOOLS_VERSION} /${PROGRAMS}/samtools-${SAMTOOLS_VERSION}

## copy mafft over
COPY --from=rstudio /usr/bin/mafft /usr/bin/
COPY --from=rstudio /usr/bin/mafft-homologs.rb /usr/bin/mafft-homologs.rb
COPY --from=rstudio /usr/bin/mafft-sparsecore.rb /usr/bin/mafft-sparsecore.rb
COPY --from=rstudio /usr/bin/mafft-profile /usr/bin/mafft-profile 
RUN mkdir /usr/libexec/mafft
COPY --from=rstudio /usr/libexec/mafft/ /usr/libexec/mafft/



## Adding common R libraries
RUN mkdir -p /R/scripts
ADD installPackages.R /R/scripts
RUN Rscript /R/scripts/installPackages.R 

### Add utilities file
COPY combine_pindel_vcfs.sh ${PROGRAMS}



