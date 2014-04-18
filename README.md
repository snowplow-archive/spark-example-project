# Spark Example Project [![Build Status](https://travis-ci.org/snowplow/spark-example-project.png)](https://travis-ci.org/snowplow/spark-example-project)

## Introduction

This is a simple word count job written in Scala for the [Spark] [spark] cluster computing platform, with instructions for running on [Amazon Elastic MapReduce] [emr] in non-interactive mode. The code is ported directly from Twitter's [`WordCountJob`] [wordcount] for Scalding.

This was built by the Professional Services team at [Snowplow Analytics] [snowplow], who use Spark on their [Data pipelines and algorithms] [data-pipelines-algos] projects.

_See also:_ [Scalding Example Project] [scalding-example-project] | [Cascalog Example Project] [cascalog-example-project]

## Building

Assuming you already have [SBT] [sbt] installed:

    $ git clone git://github.com/snowplow/spark-example-project.git
    $ cd spark-example-project
    $ sbt assembly

The 'fat jar' is now available as:

    target/spark-example-project-0.2.0.jar

## Unit testing

The `assembly` command above runs the test suite - but you can also run this manually with:

    $ sbt test
    <snip>
    [info] + A WordCount job should
    [info]   + count words correctly
    [info] Passed: : Total 1, Failed 0, Errors 0, Passed 1, Skipped 0

## Running on Amazon EMR

### Prepare

Assuming you have already assembled the jarfile (see above), now upload the jar to an Amazon S3 bucket and make the file publically accessible.

Next, upload the data file [`data/hello.txt`] [hello-txt] to S3.

### Run

Finally, you are ready to run this job using the [Amazon Ruby EMR client] [emr-client]:

```
$ elastic-mapreduce --create --name "Spark Example Project" --instance-type m1.xlarge --instance-count 3 \
  --bootstrap-action s3://elasticmapreduce/samples/spark/0.8.1/install-spark-shark.sh --bootstrap-name "Install Spark/Shark" \
  --jar s3://elasticmapreduce/libs/script-runner/script-runner.jar --step-name "Run Spark Example Project" \
  --step-action TERMINATE_JOB_FLOW \
  --arg s3://snowplow-hosted-assets/common/spark/run-spark-job-0.1.0.sh \
  --arg s3://{{JAR_BUCKET}}/spark-example-project-0.2.0.jar \
  --arg com.snowplowanalytics.spark.WordCountJob \
  --arg s3n://{{IN_BUCKET}}/hello.txt \
  --arg s3n://{{OUT_BUCKET}}/results
```

Replace `{{JAR_BUCKET}}`, `{{IN_BUCKET}}` and `{{OUT_BUCKET}}` with the appropriate paths.

### Inspect

Once the output has completed, you should see a folder structure like this in your output bucket:

     results
     |
     +- _SUCCESS
     +- part-00000
     +- part-00001

Download the files and check that `part-00000` contains:

    (hello,1)
    (world,2)

while `part-00001` contains:

    (goodbye,1)

## Running on your own Spark cluster

If you have successfully run this on your own Spark cluster, we would welcome a pull-request updating the instructions in this section.

## Next steps

Fork this project and adapt it into your own custom Spark job.

To invoke/schedule your Spark job on EMR, check out:

* [Spark Plug] [spark-plug] for Scala
* [Elasticity] [elasticity] for Ruby
* [Boto] [boto] for Python
* [Lemur] [lemur] for Clojure

## Roadmap

* Bump to Spark 0.9.x when this is supported by EMR ([#1] [issue-1]).
* Change output from tuples to TSV ([#2] [issue-2])

## Further reading

* [Run Spark and Shark on Amazon Elastic MapReduce] [aws-spark-tutorial]
* [Running Spark job on EMR as a jar in non-interactive mode] [spark-emr-howto]

## Copyright and license

Copyright 2013-2014 Snowplow Analytics Ltd.

Licensed under the [Apache License, Version 2.0] [license] (the "License");
you may not use this software except in compliance with the License.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[spark]: http://spark-project.org/
[wordcount]: https://github.com/twitter/scalding/blob/master/README.md
[snowplow]: http://snowplowanalytics.com
[data-pipelines-algos]: http://snowplowanalytics.com/services/pipelines.html

[scalding-example-project]: https://github.com/snowplow/scalding-example-project
[cascalog-example-project]: https://github.com/snowplow/cascalog-example-project

[issue-1]: https://github.com/snowplow/spark-example-project/issues/1
[issue-2]: https://github.com/snowplow/spark-example-project/issues/2
[aws-spark-tutorial]: http://aws.amazon.com/articles/4926593393724923
[spark-emr-howto]: https://forums.aws.amazon.com/thread.jspa?messageID=458398

[sbt]: http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html

[emr]: http://aws.amazon.com/elasticmapreduce/
[hello-txt]: https://github.com/snowplow/spark-example-project/raw/master/data/hello.txt
[emr-client]: http://aws.amazon.com/developertools/2264

[elasticity]: https://github.com/rslifka/elasticity
[spark-plug]: https://github.com/ogrodnek/spark-plug
[lemur]: https://github.com/TheClimateCorporation/lemur
[boto]: http://boto.readthedocs.org/en/latest/ref/emr.html

[license]: http://www.apache.org/licenses/LICENSE-2.0
