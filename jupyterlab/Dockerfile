ARG CLUSTER_BASE_IMAGE=cluster-base
FROM ${CLUSTER_BASE_IMAGE}

# -- Layer: JupyterLab

ARG spark_version=3.0.0
ARG jupyterlab_version=2.1.5

RUN pip install wget pyspark==${spark_version} jupyterlab==${jupyterlab_version} jupyterlab-git

# -- Runtime

EXPOSE 8888
WORKDIR ${SHARED_WORKSPACE}
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=
