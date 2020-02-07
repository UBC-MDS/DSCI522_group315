# author: Sam Edwardes
# date: 2020-02-04
# attribution:
#   https://github.com/ttimbers/makefile2graph/blob/master/Dockerfile
#   https://github.com/ttimbers/data_analysis_pipeline_eg/blob/master/Dockerfile

# BUILD:
#   docker build --tag dsci-522-ufc .
# RUN CONTAINER AND OPEN BASH:
#   docker run -it --rm dsci-522-ufc bin/bash
# RUN CONTAINTER, OPEN BASH AND ATTACH WORKING DIRECTORY:
#   docker run -it --rm -v $(pwd):/root/ufc dsci-522-ufc bin/bash
# RUN UFC ANALYSIS
#   docker run --rm -v $(pwd):/root/ufc dsci-522-ufc cd root/ufc make all

FROM rocker/tidyverse

#############################
# R
#############################

# Install additional R packages
RUN Rscript -e "install.packages('caret')"
RUN Rscript -e "install.packages('docopt')"
RUN Rscript -e "install.packages('GGally')"
RUN Rscript -e "install.packages('janitor')"
RUN Rscript -e "install.packages('kableExtra')"
RUN Rscript -e "install.packages('tidyselect')"
RUN Rscript -e "install.packages('ggridges')"


#############################
# Python
#############################

# install the anaconda distribution of python
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy && \
    /opt/conda/bin/conda update -n base -c defaults conda

# install docopt python package
RUN /opt/conda/bin/conda install -y -c anaconda docopt
RUN /opt/conda/bin/conda update -y --all

# altair
# https://github.com/UBC-MDS/docker-stack-altair/blob/master/Dockerfile
RUN apt-get update && apt install -y chromium && apt-get install -y libnss3 && apt-get install unzip
# Install chromedriver
RUN wget -q "https://chromedriver.storage.googleapis.com/79.0.3945.36/chromedriver_linux64.zip" -O /tmp/chromedriver.zip \
    && unzip /tmp/chromedriver.zip -d /usr/bin/ \
    && rm /tmp/chromedriver.zip && chown root:root /usr/bin/chromedriver && chmod +x /usr/bin/chromedriver
RUN /opt/conda/bin/conda install -y -c conda-forge altair 
RUN /opt/conda/bin/conda install -y vega_datasets 
RUN /opt/conda/bin/conda install -y selenium

# put anaconda python in path
ENV PATH="/opt/conda/bin:${PATH}"

#############################
# makefile2graph
#############################
# get OS updates and install build tools
# RUN apt-get install -y build-essential
# install graphviz
# RUN apt-get install -y graphviz
