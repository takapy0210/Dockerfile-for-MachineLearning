# Python3.6
FROM python:3.6

# Install dependencies
RUN apt-get update && apt-get install -y \
    libblas-dev \
	liblapack-dev\
    libatlas-base-dev \
    mecab \
    mecab-naist-jdic \
    mecab-ipadic-utf8 \
    swig \
    libmecab-dev \
	gfortran \
    libav-tools \
    sudo \
    cmake \
    python3-setuptools

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python library for Data Science
RUN pip --no-cache-dir install \
        tensorflow \
        keras \
        xgboost \
        catboost \
        https://download.pytorch.org/whl/cpu/torch-1.0.1.post2-cp36-cp36m-linux_x86_64.whl \
        torchvision \
        sklearn \
        jupyter \
        ipykernel \
		scipy \
        simpy \
        matplotlib \
        ipython \
        seaborn \
        xlrd \
        numpy \
        pandas \
        plotly \
        sympy \
        mecab-python3 \
        librosa \
        Pillow \
        h5py \
        google-api-python-client \
        tornado==5.1.1 \
        tqdm \
        japanize-matplotlib \
        nltk \
        gensim \
        opencv-python \
        wordcloud \
        beautifulsoup4 \
        && \
    python -m ipykernel.kernelspec

# mecab-ipadic-neologd install
WORKDIR /opt
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
WORKDIR /opt/mecab-ipadic-neologd
RUN ./bin/install-mecab-ipadic-neologd -n -y
WORKDIR /opt
RUN rm -rf mecab-ipadic-neologd

# lightgbm install
WORKDIR /opt
RUN git clone --recursive https://github.com/Microsoft/LightGBM
WORKDIR /opt/LightGBM
RUN export CXX=g++-8 CC=gcc-8
RUN mkdir build
WORKDIR /opt/LightGBM/build
RUN cmake ..
RUN make -j4
WORKDIR /opt/LightGBM/python-package
RUN python3 setup.py install --precompile
WORKDIR /opt
RUN rm -rf LightGBM

# Set up Jupyter Notebook config
ENV CONFIG /root/.jupyter/jupyter_notebook_config.py
ENV CONFIG_IPYTHON /root/.ipython/profile_default/ipython_config.py

RUN jupyter notebook --generate-config --allow-root && \
    ipython profile create

RUN echo "c.NotebookApp.ip = '0.0.0.0'" >>${CONFIG} && \
    echo "c.NotebookApp.port = 8888" >>${CONFIG} && \
    echo "c.NotebookApp.open_browser = False" >>${CONFIG} && \
    echo "c.NotebookApp.iopub_data_rate_limit=10000000000" >>${CONFIG} && \
    echo "c.MultiKernelManager.default_kernel_name = 'python3'" >>${CONFIG}

RUN echo "c.InteractiveShellApp.exec_lines = ['%matplotlib inline']" >>${CONFIG_IPYTHON}

# Port
EXPOSE 8888

# Mount
VOLUME /notebooks

# Run Jupyter Notebook
WORKDIR "/notebooks"
CMD ["jupyter","notebook", "--allow-root"]
