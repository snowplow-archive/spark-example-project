# Spark Example Project

## Introduction

This is a simple word count job written in Scala for the [Spark] [spark] cluster computing platform, with instructions for running on [Amazon Elastic MapReduce] [emr]. The algorithm is ported directly from Twitter's [`WordCountJob`] [wordcount] for Scalding.

This was built by the Professional Services team at [Snowplow Analytics] [snowplow], who use Spark on their [Data pipelines and algorithms] [data-pipelines-algos] projects.

**See also:** [Scalding Example Project] [scalding-example-project] | [Cascalog Example Project] [cascalog-example-project]

## Building

Section to come.

## Unit testing

Section to come.

## Running on Amazon EMR

_Much of this section has been adapted from the Amazon tutorial [Run Spark and Shark on Amazon Elastic MapReduce] [aws-spark-tutorial]._

### Prepare

First, upload the jar to S3 - if you haven't yet built the project (see above), you can grab the latest copy of the jar from this repo's [Downloads] [downloads].

Next, upload the data file [`data/hello.txt`] [hello-txt] to S3.

### Run

Finally, you are ready to run this job using the [Amazon Ruby EMR client] [emr-client]:

    $ Command to come

Replace `{{JAR_BUCKET}}`, `{{IN_BUCKET}}` and `{{OUT_BUCKET}}` with the appropriate paths.

### Inspect

Once the output has completed, you should see a folder structure like this in your output bucket:

    Listing to come

Download the <<SECTION TO COME>> and check that <<TO COME>> contains:

	goodbye	1
	hello	1
	world	2

## Running on your own Hadoop cluster

If you have successfully run this on your own Hadoop cluster, we would welcome a pull-request updating the instructions in this section.

## Next steps

Fork this project and adapt it into your own custom Spark job.

Use the excellent [Elasticity] [elasticity] Ruby library to invoke/schedule your Spark job on EMR.

## Roadmap

Nothing planned currently.

## Copyright and license

Copyright 2013 Snowplow Analytics Ltd.

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

[aws-spark-tutorial]: http://aws.amazon.com/articles/4926593393724923

[emr]: http://aws.amazon.com/elasticmapreduce/
[downloads]: https://github.com/snowplow/spark-example-project/downloads
[hello-txt]: https://github.com/snowplow/spark-example-project/raw/master/data/hello.txt
[emr-client]: http://aws.amazon.com/developertools/2264

[elasticity]: https://github.com/rslifka/elasticity
[license]: http://www.apache.org/licenses/LICENSE-2.0