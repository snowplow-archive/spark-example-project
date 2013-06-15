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

// Java
import java.io.{FileWriter, File}

// Scala
import scala.io.Source

// Google Guava
import com.google.common.io.Files

// Specs2
import org.specs2.mutable.Specification

class WordCountTest extends Specification {

  "A WordCount job" should {

    "count words correctly" in {

      val tempDir = Files.createTempDir()
      val inputFile = new File(tempDir, "input").getAbsolutePath
      val inWriter = new FileWriter(inputFile)
      inWriter.write("hack hack hack and hack")
      inWriter.close
      val outputDir = new File(tempDir, "output").getAbsolutePath

      WordCount.execute(
        master = "local",
        args   = List(inputFile, outputDir)
      )

      val outputFile = new File(outputDir, "part-00000")
      val actual = Source.fromFile(outputFile).mkString
      actual must_== "(hack,4)\n(and,1)\n"
    }
  }
}
