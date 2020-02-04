# author: Sam Edwardes
# date: 2020-02-04
# attribution:
#   https://github.com/ttimbers/makefile2graph/blob/master/Dockerfile
#   https://github.com/ttimbers/data_analysis_pipeline_eg/blob/master/Dockerfile

# BUILD:
#   docker build --tag dsci-522-ufc .
# RUN CONTAINER BASIC:
#   docker run -it --rm dsci-522-ufc bin/bash
# RUN CONTAINTER WITH VOLUMES:
#   docker run -it --rm -v /Users/samedwardes/UBC/block-04/522-workflows/DSCI522_group315:/root/ufc dsci-522-ufc bin/bash

FROM rocker/tidyverse

#############################
# R tidyverse
#############################

# Install additional R packages
RUN Rscript -e "install.packages('caret')"
RUN Rscript -e "install.packages('docopt')"
RUN Rscript -e "install.packages('GGally')"
RUN Rscript -e "install.packages('janitor')"


#############################
# Python
#############################

# install the anaconda distribution of python
# RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh -O ~/anaconda.sh && \
#     /bin/bash ~/anaconda.sh -b -p /opt/conda && \
#     rm ~/anaconda.sh && \
#     ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#     echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
#     echo "conda activate base" >> ~/.bashrc && \
#     find /opt/conda/ -follow -type f -name '*.a' -delete && \
#     find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
#     /opt/conda/bin/conda clean -afy && \
#     /opt/conda/bin/conda update -n base -c defaults conda

# install docopt python package
# RUN /opt/conda/bin/conda install -y -c anaconda docopt

# put anaconda python in path
# ENV PATH="/opt/conda/bin:${PATH}"

#############################
# makefile2graph
#############################
# get OS updates and install build tools
# RUN apt-get install -y build-essential
# install graphviz
# RUN apt-get install -y graphviz
