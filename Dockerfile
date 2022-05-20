ARG ROOT_CONTAINER=ubuntu:focal

FROM $ROOT_CONTAINER

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    curl \
    gpg-agent \
    wget \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    software-properties-common \
    unixodbc \
    unixodbc-dev \
    openjdk-8-jre-headless \
    run-one && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update --yes && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update --yes && \
    apt-get install --yes python3.8 python3.8-dev python3.8-distutils python3.8-venv && \
    apt-get install --yes python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

ARG MS_SQL_IP=85.192.35.44
ARG MS_SQL_PORT=443
# https://github.com/mkleehammer/pyodbc/wiki/Connecting-to-SQL-Server-from-Linux
RUN echo "[MSSQLServerDatabase]\n\
Driver      = ODBC Driver 17 for SQL Server\n\
Description = Connect to my SQL Server instance\n\
Trace       = No\n\
Server      = $MS_SQL_IP,$MS_SQL_PORT" > DSN_file && \
    sudo odbcinst -i -s -f DSN_file -l

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Install a pyspark venv and add it to a jupyter kernel list
ARG SETUP_FILE_PATH ./setup.py
ENV SETUP_FILE_PATH ${SETUP_FILE_PATH}
COPY $SETUP_FILE_PATH .
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir notebook
RUN python3.8 -m venv .venv
RUN . .venv/bin/activate && pip install wheel && pip install --no-cache-dir -e . && pip install --no-cache-dir ipykernel && python -m ipykernel install --name=physical_spark_kernel
RUN rm -rf $SETUP_FILE_PATH

WORKDIR home
WORKDIR work
CMD ["jupyter","notebook","--ip=0.0.0.0","--no-browser","--allow-root"]
