#!/bin/bash

# Download and install Spark & Scala
cd /home/hadoop/
wget http://www.spark-project.org/download-spark-0.7.2-prebuilt-hadoop1
wget http://www.scala-lang.org/downloads/distrib/files/scala-2.9.3.tgz
tar -xvzf scala-2.9.2.tgz
tar -xvzf download-spark-0.7.2-prebuilt-hadoop1
SCALA_HOME=/home/hadoop/scala-2.9.3
SPARK_HOME=/home/hadoop/spark-0.7.2

# Configure rest of variables
MASTER_HOST=$(grep -i "job.tracker<" /home/hadoop/conf/mapred-site.xml | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
MASTER_PORT=7077
MASTER=spark://$MASTER_HOST:$MASTER_PORT
SPACE=$(mount | grep mnt | awk '{print $3"/spark/"}' | xargs | sed 's/ /,/g')
JOBS_DIR=/home/hadoop/spark/jobs

# Build Spark environment
cat >/home/hadoop/spark/conf/spark-env.sh <<EOL
export SPARK_MASTER_IP=$MASTER
export SCALA_HOME=$SCALA_HOME
export SPARK_HOME=$SPARK_HOME
export MASTER=$MASTER
export SPARK_LIBRARY_PATH=/home/hadoop/native/Linux-amd64-64
export SPARK_JAVA_OPTS=\"-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Dspark.local.dir=$SPACE\"
EOL 

# Install config file and jars
cp /home/hadoop/conf/core-site.xml /home/hadoop/spark/conf/
cp /home/hadoop/hadoop-core.jar /home/hadoop/spark/lib_managed/jars/hadoop-core-1.0.3.jar 
cp /home/hadoop/lib/gson-* /home/hadoop/spark/lib_managed/jars/
cp /home/hadoop/lib/aws-java-sdk-* /home/hadoop/spark/lib_managed/jars/
cp /home/hadoop/lib/emr-metrics* /home/hadoop/spark/lib_managed/jars/

# Start Spark master or Spark worker daemon
grep -Fq '"isMaster":true' /mnt/var/lib/info/instance.json
if [ $? -eq 0 ];
then
        # Start master
        /home/hadoop/spark/bin/start-master.sh
        
        # Run our job (if we have one)
        if [ ${#} -ge 1 ];then
                job_uri=${1}
                cd $JOBS_DIR
                wget $job_uri
                job_path=$JOBS_DIR/$(basename $job_uri)
                java -jar $job_path $job_path "${*:2}" # Second job_path passed as first argument
        fi

else
        nc -z $MASTER_HOST $MASTER_PORT
        while [ $? -eq 1 ];                do
                        echo "Can't connect to the master, sleeping for 20 seconds"
                        sleep 20
                        nc -z  $MASTER_HOST $MASTER_PORT
                done
        echo "Connecting to the master was successful"
        /home/hadoop/spark/bin/spark-daemon.sh start spark.deploy.worker.Worker $MASTER
fi
