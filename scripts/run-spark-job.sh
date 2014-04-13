#!/usr/bin/env bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Script version 0.1.0

# Die if anything happens
set -e

# Paths
spark_home=/home/hadoop/spark
spark_env=${spark_home}/conf/spark-env.sh
user_jars=${spark_home}/user-jars

# Usage
if [[ "$#" -lt 2 ]]; then
  echo "Usage: run-spark <jar> <class> [<args>]" >&2
  exit 1
fi

# Load environment variables from conf/spark-env.sh, if it exists
if [[ -f ${spark_env} ]]; then
  . ${spark_env}
fi

# Find Java binary
if [[ -n "${JAVA_HOME}" ]]; then
  runner="${JAVA_HOME}/bin/java"
else
  if [[ `command -v java` ]]; then
    runner="java"
  else
    echo "JAVA_HOME is not set" >&2
    exit 1
  fi
fi

# Download jarfile from S3 to local
jarfile=${user_jars}/${1##*/}
if [[ ! -f ${jarfile} ]]; then
  mkdir -p ${user_jars}
  hadoop fs -get ${1} ${user_jars}/
fi

# Since our fatjar doesn't include spark-core (that dependency is "provided"),
# also add our standard Spark classpath, built using compute-classpath.sh.
classpath=`${spark_home}/bin/compute-classpath.sh`
classpath="${jarfile}:${classpath}"

# Exports for job
export SPARK_HOME="${spark_home}"

shift 1 # Drop the jarfile arg
exec "${runner}" -cp "${classpath}" "$@"
