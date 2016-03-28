# Copyright (c) 2015 Snowplow Analytics Ltd. All rights reserved.
#
# This program is licensed to you under the Apache License Version 2.0,
# and you may not use this file except in compliance with the Apache License Version 2.0.
# You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the Apache License Version 2.0 is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

from invoke import run, task

import boto.s3
from boto.s3.connection import Location
from boto.s3.key import Key

import boto3

HELLO_TXT = "in/hello.txt"
JAR_FILE  = "spark-example-project-0.4.0.jar"

S3_REGIONS = { 'us-east-1': Location.DEFAULT,
                 'us-west-1': Location.USWest,
                 'us-west-2': Location.USWest2,
                 'eu-west-1': Location.EU,
                 'ap-southeast-1': Location.APSoutheast,
                 'ap-southeast-2': Location.APSoutheast2,
                 'ap-northeast-1': Location.APNortheast,
                 'sa-east-1': Location.SAEast }

S3_LOCATIONS = {v: k for k, v in S3_REGIONS.items()}

# Taken from https://github.com/bencpeters/save-tweets/blob/ac276fac41e676ee12a426df56cbc60138a12e62/save-tweets.py
def get_valid_location(region):
    if region not in [i for i in dir(boto.s3.connection.Location) \
                               if i[0].isupper()]:
        try:
            return S3_REGIONS[region]
        except KeyError:
            raise ValueError("%s is not a known AWS location. Valid choices " \
                 "are:\n%s" % (region,  "\n".join( \
                 ["  *%s" % i for i in S3_REGIONS.keys()])))
    else:
        return getattr(Location, region)

def get_valid_region(location):
    return S3_LOCATIONS[location]

@task
def test():
    run("sbt test", pty=True)

@task
def assembly():
   run("sbt assembly", pty=True)

#@task
#def create_ec2_key(profile, ...)

#@task
#def create_public_subnet(profile, ...)

#@task
#def create_bucket(profile, bucket, region):
#    c = boto.connect_s3(profile_name=profile)
#    c.create_bucket(bucket, location=get_valid_location(region))

@task
def upload(profile, bucket):
    c = boto.connect_s3(profile_name=profile)    
    b = c.get_bucket(bucket)
    
    k1 = Key(b)
    k1.key = HELLO_TXT
    k1.set_contents_from_filename("./data/" + HELLO_TXT)
    
    k2 = Key(b)
    k2.key = "jar/" + JAR_FILE
    k2.set_contents_from_filename("./target/scala-2.10/" + JAR_FILE)

@task
def run_emr(profile, bucket, ec2_keyname, vpc_subnet_id):
    s3_client = boto.connect_s3(profile_name=profile)
    region = get_valid_region(s3_client.get_bucket(bucket).get_location())

    boto3.setup_default_session(profile_name=profile)
    client = boto3.client('emr', region_name=region)
    response = client.run_job_flow(
        Name='Spark Example Project',
        LogUri="s3://" + bucket + "/logs",
        Instances={
            'MasterInstanceType': 'm3.xlarge',
            'SlaveInstanceType': 'm3.xlarge',
            'InstanceCount': 3,
            'KeepJobFlowAliveWhenNoSteps': False,
            'TerminationProtected':False,
            'Ec2KeyName': ec2_keyname,
            'Ec2SubnetId': vpc_subnet_id,
        },
        ReleaseLabel='emr-4.4.0',
        Applications=[
            {
                'Name': 'Spark'
            },
        ],
        VisibleToAllUsers=True,
        JobFlowRole='EMR_EC2_DefaultRole',
        ServiceRole='EMR_DefaultRole',
        Steps=[
            {
                'Name': 'Run Spark WordCountJob',
                'ActionOnFailure': 'TERMINATE_JOB_FLOW',
                'HadoopJarStep': {
                    'Jar': "command-runner.jar",
                    'Args': [
                        "spark-submit",
                        "--deploy-mode", "cluster",
                        "--master", "yarn-cluster",
                        "--class", "com.snowplowanalytics.spark.WordCountJob",
                        "s3://" + bucket + "/jar/" + JAR_FILE,
                        "s3n://" + bucket + "/" + HELLO_TXT,
                        "s3n://" + bucket + "/out"
                    ],
                },
            },
        ],
    )
    print "Started jobflow " + response['JobFlowId']
