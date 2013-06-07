/*
 * Copyright (c) 2012-2013 SnowPlow Analytics Ltd. All rights reserved.
 *
 * This program is licensed to you under the Apache License Version 2.0,
 * and you may not use this file except in compliance with the Apache License Version 2.0.
 * You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the Apache License Version 2.0 is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.
 */
package com.snowplowanalytics.spark

// Spark
import spark._

object WordCountJob {
  
  def main(args: Array[String]) {
    
    // See http://spark-project.org/docs/latest/api/core/index.html#spark.SparkContext
    val sc = new SparkContext(
      master = args(0),
      appName = "WordCountJob",
      sparkHome = System.getenv("SPARK_HOME"),
      jars = Seq(System.getenv("SPARK_EXAMPLE_JAR"))
    )
    
    // Adapted from Word Count example on http://spark-project.org/examples/
    val file = sc.textFile(args(1))
	  val counts = file.flatMap(line => line.split(" "))
                  .map(word => (word, 1))
                  .reduceByKey(_ + _)
    counts.saveAsTextFile(args(2))

    // Exit with success
    System.exit(0)
  }
}