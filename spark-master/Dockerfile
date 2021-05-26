ARG SPARK_BASE_IMAGE=spark-base
FROM ${SPARK_BASE_IMAGE}

# -- Runtime

ARG spark_master_web_ui=8080

EXPOSE ${spark_master_web_ui} ${SPARK_MASTER_PORT}
#CMD bin/spark-class org.apache.spark.deploy.master.Master >> logs/spark-master.out
CMD bin/spark-class org.apache.spark.deploy.master.Master
