#!/bin/bash
#
# Copyright (c) 2013 Snowplow Analytics Ltd. All rights reserved.
#
# This program is licensed to you under the Apache License Version 2.0,
# and you may not use this file except in compliance with the Apache License Version 2.0.
# You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the Apache License Version 2.0 is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.
#
# Version:     0.1.4
# URL:         https://github.com/snowplow/spark-example-project/blob/master/scripts/install-spark-run-job.sh
#
# Authors:     Alex Dean
# Copyright:   Copyright (c) 2013 Snowplow Analytics Ltd
# License:     Apache License Version 2.0

# Configure variables
HADOOP_HOME=/home/hadoop
SCALA_HOME=$HADOOP_HOME/scala-2.9.3
SPARK_HOME=$HADOOP_HOME/spark-0.7.2
MASTER_HOST=$(grep -i "job.tracker<" /home/hadoop/conf/mapred-site.xml | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
MASTER_PORT=7077
MASTER=spark://$MASTER_HOST:$MASTER_PORT
SPACE=$(mount | grep mnt | awk '{print $3"/spark/"}' | xargs | sed 's/ /,/g')

# Download and install Spark & Scala
cd $HADOOP_HOME
wget http://www.spark-project.org/download-spark-0.7.2-prebuilt-hadoop1
wget http://www.scala-lang.org/downloads/distrib/files/scala-2.9.3.tgz
tar -xvzf scala-2.9.3.tgz
tar -xvzf download-spark-0.7.2-prebuilt-hadoop1

# Build Spark environment
spark_env=$SPARK_HOME/conf/spark-env.sh
touch $spark_env
cat >$spark_env <<EOL
export SPARK_MASTER_IP=$MASTER
export SCALA_HOME=$SCALA_HOME
export SPARK_HOME=$SPARK_HOME
export MASTER=$MASTER
export SPARK_LIBRARY_PATH=/home/hadoop/native/Linux-amd64-64
export SPARK_JAVA_OPTS="-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Dspark.local.dir=$SPACE"
EOL

# Install config file and jars
cp $HADOOP_HOME/conf/core-site.xml $SPARK_HOME/conf/
cp $HADOOP_HOME/hadoop-core.jar $SPARK_HOME/lib_managed/jars/hadoop-core-1.0.3.jar 
cp $HADOOP_HOME/lib/gson-* $SPARK_HOME/lib_managed/jars/
cp $HADOOP_HOME/lib/aws-java-sdk-* $SPARK_HOME/lib_managed/jars/
cp $HADOOP_HOME/lib/emr-metrics* $SPARK_HOME/lib_managed/jars/

# Start Spark master or Spark worker daemon
grep -Fq '"isMaster":true' /mnt/var/lib/info/instance.json
if [ $? -eq 0 ];
then
        # Start master
        $SPARK_HOME/bin/start-master.sh
        
        # Run our job (if we have one)
        if [ $# -ge 1 ]; then
                jar_uri=$1
                jobs=$SPARK_HOME/jobs
                mkdir $jobs
                cd $jobs
                wget $jar_uri
                job_path=$jobs/$(basename $jar_uri)
                java -jar $job_path ${*:2}
        fi

else
        nc -z $MASTER_HOST $MASTER_PORT
        while [ $? -eq 1 ]; do
                echo "Can't connect to the master, sleeping for 20 seconds"
                sleep 20
                nc -z  $MASTER_HOST $MASTER_PORT
        done
        echo "Connecting to the master was successful"
        $SPARK_HOME/bin/spark-daemon.sh start spark.deploy.worker.Worker $MASTER
fi
