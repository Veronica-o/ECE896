FROM jupyter/minimal-notebook:latest
#FROM ubuntu:16.04

# Install system dependencies required for compiling Python packages with native extensions
USER root

COPY vivado_cfg.txt /tmp/vivado_cfg.txt
COPY install_vivado.sh /tmp/install_vivado.sh

COPY Xilinx_Vivado_SDK_2018.3_1207_2324.tar.gz /tmp/vivado.tar.gz

RUN chmod +x /tmp/install_vivado.sh

COPY y2k22_patch.zip /tmp/y2k22_patch.zip

# Install system dependencies required for Vivado and other tools
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    libx11-6 \
    curl \
    unzip \
    libncurses5 \
    graphviz \
    g++ \
    libgl1-mesa-glx \
    cmake \
    make\
    gcc \
    python3-dev \
    protobuf-compiler \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Run the Vivado installation script and clean up
RUN /tmp/install_vivado.sh && rm /tmp/install_vivado.sh

RUN conda install python=3.10.6
# Install necessary packages

ENV PATH="/opt/Xilinx/Vivado/2018.3/bin:${PATH}"



#RUN chown jovyan /home/jovyan/work && chmod -R 777 /home/jovyan/work


# RUN chown jovyan /tmp/vivado_cfg.txt && chmod 777 /tmp/vivado_cfg.txt
# RUN chown jovyan /tmp/install_vivado.sh && chmod +x /tmp/install_vivado.sh
# RUN chown jovyan /tmp/vivado.tar.gz && chmod 777 /tmp/vivado.tar.gz

# Switch back to the jovyan user (default user in jupyter Docker images)
#USER jovyan
#RUN pip3 install --no-cache-dir setuptools

# Copy the requirements file into the container
COPY ./requirements.txt /tmp/requirements.txt

#RUN apt-get update && apt-get install -y cmake

# Install additional packages from the requirements file
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Set JupyterLab to run without authentication token
CMD ["jupyter", "lab", "--port", "8080", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''"]

RUN echo "PATH is: $PATH"
