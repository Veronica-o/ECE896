# Use the TensorFlow GPU Jupyter image as the base image
FROM tensorflow/tensorflow:2.8.0-gpu-jupyter

# Install system dependencies required for compiling Python packages with native extensions
USER root

COPY vivado_cfg.txt /tmp/vivado_cfg.txt
COPY install_vivado.sh /tmp/install_vivado.sh
COPY Xilinx_Vivado_SDK_2018.3_1207_2324.tar.gz /tmp/vivado.tar.gz

RUN chmod +x /tmp/install_vivado.sh

COPY y2k22_patch.zip /tmp/y2k22_patch.zip

#COPY ./hls4ml-frame-grabbers /home/jovyan/hls4ml-frame-grabbers

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub

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
    make \
    gcc \
    python3-dev \
    protobuf-compiler \
    python3 \
    python3-pip \
    python3-apt \
    && rm -rf /var/lib/apt/lists/*


# Run the Vivado installation script and clean up
RUN /tmp/install_vivado.sh && rm /tmp/install_vivado.sh

RUN curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh
    

ENV PATH="/opt/conda/bin:${PATH}"

# Install necessary packages
RUN conda install -y python=3.10.6

ENV PATH="/opt/Xilinx/Vivado/2018.3/bin:${PATH}"

#ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}


# Create and activate a new conda environment
#RUN conda create -y -n myenv python=3.10.6
#RUN echo "source activate myenv" > ~/.bashrc
#ENV PATH=/opt/conda/envs/myenv/bin:$PATH

# Copy the requirements file into the container
COPY ./requirements.txt /tmp/requirements.txt

# Copy pipeline scripts into the container
COPY ./pipeline_scripts /opt/pipeline_scripts

# Copy the Python scripts into the container
COPY ./hls4ml-frame-grabbers /opt/hls4ml-frame-grabbers

#RUN conda env create -f /opt/hls4ml-frame-grabbers/environment.yml

#ENV PATH = /opt/conda/envs/hls4ml_frame_grabber/bin:$PATH

# Install the Jupyter kernel for the newly created environment
#RUN ipython kernel install --user --name=hls4ml_frame_grabber --display-name "Python (hls4ml_frame_grabber)"

# Set executable permissions for pipeline scripts
RUN chmod +x /opt/pipeline_scripts/*.sh

# Install additional packages from the requirements file
RUN pip install --no-cache-dir -r /tmp/requirements.txt
#RUN conda install -n hls4ml_frame_grabber -y jupyterlab

WORKDIR /home/jovyan
#Define the entrypoint script to run specific stages of the pipeline
#ENTRYPOINT ["/bin/bash", "/opt/pipeline_scripts/entrypoint.sh"]
# Set JupyterLab to run without authentication token
CMD ["jupyter", "lab", "--port=8007", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''"]

# Print the PATH for verification
RUN echo "PATH is: $PATH"