/*
 * Copyright (c) 2013 Snowplow Analytics Ltd. All rights reserved.
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
    "Akka Repository" at "http://repo.akka.io/releases/",
    "Spray Repository" at "http://repo.spray.cc/"
  )

  object V {
    val spark     = "0.8.1-incubating"
    val specs2    = "1.12.3" // -> "1.13" when we bump to Scala 2.10.0
    val guava     = "11.0.1"
    // Add versions for your additional libraries here...
  }

  object Libraries {
    val sparkCore    = "org.apache.spark"           %% "spark-core"            % V.spark        % "provided"
    // Add additional libraries from mvnrepository.com (SBT syntax) here...

    // Scala (test only)
    val specs2       = "org.specs2"                 % "specs2_2.9.2"           % V.specs2       % "test"
    val guava        = "com.google.guava"           % "guava"                  % V.guava        % "test"
  }
}
