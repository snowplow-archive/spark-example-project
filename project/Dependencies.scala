/*
 * Copyright (c) 2012 SnowPlow Analytics Ltd. All rights reserved.
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
import sbt._

object Dependencies {
  val resolutionRepos = Seq(
    ScalaToolsSnapshots
  )

  object V {
    val spark     = "0.7.2"
    val hadoop    = "1.0.4"
    val specs2    = "1.12.3" // -> "1.13" when we bump to Scala 2.10.0
    // Add versions for your additional libraries here...
  }

  object Libraries {
    val sparkCore    = "org.spark-project"          %% "spark-core"            % V.spark
    val hadoopCore   = "org.apache.hadoop"          %  "hadoop-core"           % V.hadoop       % "provided"
    // Add additional libraries from mvnrepository.com (SBT syntax) here...

    // Scala (test only)
    val specs2       = "org.specs2"                 %% "specs2"                % V.specs2       % "test"
  }
}