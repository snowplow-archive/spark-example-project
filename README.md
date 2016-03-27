# Spark Example Project [![Build Status](https://travis-ci.org/snowplow/spark-example-project.png)](https://travis-ci.org/snowplow/spark-example-project)

## Introduction

This is a simple word count job written in Scala for the [Spark] [spark] cluster computing platform, with instructions for running on [Amazon Elastic MapReduce] [emr] in non-interactive mode. The code is ported directly from Twitter's [`WordCountJob`] [wordcount] for Scalding.

This was built by the Data Science team at [Snowplow Analytics] [snowplow], who use Spark on their [Data pipelines and algorithms] [data-pipelines-algos] projects.

_See also:_ [Spark Streaming Example Project] [spark-streaming-example-project] | [Scalding Example Project] [scalding-example-project]

## Building

Assuming git, [Vagrant] [vagrant-install] and [VirtualBox] [virtualbox-install] installed:

```bash
 host> git clone https://github.com/snowplow/spark-example-project
 host> cd spark-example-project
 host> vagrant up && vagrant ssh
guest> cd /vagrant
guest> sbt assembly
```

The 'fat jar' is now available as:

    target/spark-example-project-0.4.0.jar

## Unit testing

The `assembly` command above runs the test suite - but you can also run this manually with:

    $ sbt test
    <snip>
    [info] + A WordCount job should
    [info]   + count words correctly
    [info] Passed: : Total 1, Failed 0, Errors 0, Passed 1, Skipped 0

## Running on Amazon EMR

### Prepare

Create:

1. An AWS CLI profile, e.g. _spark_
2. An Amazon S3 bucket, e.g. _spark-example-project-your-name_
3. A EC2 keypair, e.g. _spark-ec2-keypair_
4. A VPC public subnet, e.g. _subnet-3dc2bd2a_

Make sure you have assembled the jarfile (see above).

### Upload and run

```bash
guest> inv upload spark spark-example-project-your-name
guest> inv run_emr spark spark-example-project-your-name spark-ec2-keypair subnet-3dc2bd2a
```

You can now monitor the running EMR jobflow in the AWS Elastic MapReduce UI.

### Inspect

Once the job has completed, you should see a folder structure like this in your output bucket:

     results
     |
     +- _SUCCESS
     +- part-00000
     +- part-00001
     +- part-00002
     +- part-...

Download the files and check that one file contains:

    (hello,1)
    (world,2)

while another file contains:

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

* Change output from tuples to TSV ([#2] [issue-2])

## Copyright and license

Copyright 2013-2015 Snowplow Analytics Ltd.

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

[vagrant-install]: http://docs.vagrantup.com/v2/installation/index.html
[virtualbox-install]: https://www.virtualbox.org/wiki/Downloads

[spark-streaming-example-project]: https://github.com/snowplow/spark-streaming-example-project
[scalding-example-project]: https://github.com/snowplow/scalding-example-project

[issue-1]: https://github.com/snowplow/spark-example-project/issues/1
[issue-2]: https://github.com/snowplow/spark-example-project/issues/2
[aws-spark-tutorial]: http://aws.amazon.com/articles/4926593393724923
[spark-emr-howto]: https://forums.aws.amazon.com/thread.jspa?messageID=458398

[emr]: http://aws.amazon.com/elasticmapreduce/
[hello-txt]: https://github.com/snowplow/spark-example-project/raw/master/data/hello.txt
[emr-client]: http://aws.amazon.com/developertools/2264

[elasticity]: https://github.com/rslifka/elasticity
[spark-plug]: https://github.com/ogrodnek/spark-plug
[lemur]: https://github.com/TheClimateCorporation/lemur
[boto]: http://boto.readthedocs.org/en/latest/ref/emr.html

[license]: http://www.apache.org/licenses/LICENSE-2.0
