@echo off
setlocal enableextensions

set DEBIAN_BUSTER_IMAGE_TAG=8-jre-slim

set SPARK_VERSION=3.1.1
set HADOOP_VERSION=3.2
@REM set SPARK_VERSION=3.1.1
@REM set HADOOP_VERSION=2.7

set JUPYTERLAB_VERSION=3.0.12

set CLUSTER_IMAGE_NAME=cluster-base
set CLUSTER_IMAGE_TAG=%DEBIAN_BUSTER_IMAGE_TAG%

set SPARK_TAG=%DEBIAN_BUSTER_IMAGE_TAG%_%SPARK_VERSION%_%HADOOP_VERSION%

set SPARK_BASE_IMAGE_NAME=spark-base
set SPARK_BASE_IMAGE_TAG=%SPARK_TAG%

set SPARK_MASTER_IMAGE_NAME=spark-master
set SPARK_MASTER_IMAGE_TAG=%SPARK_TAG%

set SPARK_WORKER_IMAGE_NAME=spark-worker
set SPARK_WORKER_IMAGE_TAG=%SPARK_TAG%

set JUPYTERLAB_IMAGE_NAME=spark-jupyterlab
set JUPYTERLAB_IMAGE_TAG=%SPARK_TAG%_%JUPYTERLAB_VERSION%

set LATEST_TAG=latest

rem Building the Images

rem cluster-base
echo cluster-base
docker build ^
  --build-arg debian_buster_image_tag=%DEBIAN_BUSTER_IMAGE_TAG% ^
  -f cluster-base\Dockerfile ^
  -t %CLUSTER_IMAGE_NAME%:%CLUSTER_IMAGE_TAG% .\cluster-base

docker tag %CLUSTER_IMAGE_NAME%:%CLUSTER_IMAGE_TAG% %CLUSTER_IMAGE_NAME%:%LATEST_TAG%

rem spark-base
echo spark-base
docker build ^
  --build-arg cluster-base-image=%CLUSTER_IMAGE_NAME%:%CLUSTER_IMAGE_TAG% ^
  --build-arg spark_version=%SPARK_VERSION% ^
  --build-arg hadoop_version=%HADOOP_VERSION% ^
  -f spark-base\Dockerfile ^
  -t %SPARK_BASE_IMAGE_NAME%:%SPARK_BASE_IMAGE_TAG% .\spark-base

docker tag %SPARK_BASE_IMAGE_NAME%:%SPARK_BASE_IMAGE_TAG% %SPARK_BASE_IMAGE_NAME%:%LATEST_TAG%

rem spark-master
echo spark-master
docker build ^
  --build-arg spark-base-image=%SPARK_BASE_IMAGE_NAME%:%SPARK_BASE_IMAGE_TAG% ^
  -f spark-master\Dockerfile ^
  -t %SPARK_MASTER_IMAGE_NAME%:%SPARK_MASTER_IMAGE_TAG% .\spark-master

docker tag %SPARK_MASTER_IMAGE_NAME%:%SPARK_MASTER_IMAGE_TAG% %SPARK_MASTER_IMAGE_NAME%:%LATEST_TAG%

rem spark worker
echo spark worker
docker build ^
  --build-arg spark-base-image=%SPARK_BASE_IMAGE_NAME%:%SPARK_BASE_IMAGE_TAG% ^
  -f spark-worker\Dockerfile ^
  -t %SPARK_WORKER_IMAGE_NAME%:%SPARK_WORKER_IMAGE_TAG% .\spark-worker

docker tag %SPARK_WORKER_IMAGE_NAME%:%SPARK_WORKER_IMAGE_TAG% %SPARK_WORKER_IMAGE_NAME%:%LATEST_TAG%

rem spark-jupyterlab
echo spark-jupyterlab
docker build ^
  --build-arg cluster-base-image=%CLUSTER_IMAGE_NAME%:%CLUSTER_IMAGE_TAG% ^
  --build-arg spark_version="%SPARK_VERSION%" ^
  --build-arg jupyterlab_version="%JUPYTERLAB_VERSION%" ^
  -f jupyterlab\Dockerfile ^
  -t %JUPYTERLAB_IMAGE_NAME%:%JUPYTERLAB_IMAGE_TAG% .\jupyterlab

docker tag %JUPYTERLAB_IMAGE_NAME%:%JUPYTERLAB_IMAGE_TAG% %JUPYTERLAB_IMAGE_NAME%:%LATEST_TAG%

rem Remove dangling images
for /f "tokens=*" %%a in ('docker images -f "dangling=true" -q') do docker rmi -f %%a

echo.
echo.
echo Images created:
echo    %CLUSTER_IMAGE_NAME%:%CLUSTER_IMAGE_TAG%
echo    %SPARK_BASE_IMAGE_NAME%:%SPARK_BASE_IMAGE_TAG%
echo    %SPARK_MASTER_IMAGE_NAME%:%SPARK_MASTER_IMAGE_TAG%
echo    %SPARK_WORKER_IMAGE_NAME%:%SPARK_WORKER_IMAGE_TAG%
echo    %JUPYTERLAB_IMAGE_NAME%:%JUPYTERLAB_IMAGE_TAG%
echo.

docker save %CLUSTER_IMAGE_NAME%:%CLUSTER_IMAGE_TAG% | 7z a -si %CLUSTER_IMAGE_NAME%_%CLUSTER_IMAGE_TAG%.tar.7z
docker save %SPARK_BASE_IMAGE_NAME%:%SPARK_BASE_IMAGE_TAG% | 7z a -si %SPARK_BASE_IMAGE_NAME%_%SPARK_BASE_IMAGE_TAG%.tar.7z
docker save %SPARK_MASTER_IMAGE_NAME%:%SPARK_MASTER_IMAGE_TAG% | 7z a -si %SPARK_MASTER_IMAGE_NAME%_%SPARK_MASTER_IMAGE_TAG%.tar.7z
docker save %SPARK_WORKER_IMAGE_NAME%:%SPARK_WORKER_IMAGE_TAG% | 7z a -si %SPARK_WORKER_IMAGE_NAME%_%SPARK_WORKER_IMAGE_TAG%.tar.7z
docker save %JUPYTERLAB_IMAGE_NAME%:%JUPYTERLAB_IMAGE_TAG% | 7z a -si %JUPYTERLAB_IMAGE_NAME%_%JUPYTERLAB_IMAGE_TAG%.tar.7z

endlocal