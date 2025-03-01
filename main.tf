 provider "aws" {
          region = "ap-south-1"
               }
#####iam role####     
data "aws_iam_role" "lambda" {
name = "DevOps-Candidate-Lambda-Role"
}
######s3 bucket###
    resource "aws_s3_bucket" {
    S3 Bucket: "3.devops.candidate.exam"
    Region: "ap-south-1"
    Key: "rupali.yeilwad"
    acl = "private"
             }

 ####vpc###
     data "aws_vpc" "vpc" {
     id = "vpc-00bf0d10a6a41600c"
        }
 #######nat gateway#####
     data "aws_nat_gateway" "nat" {
     id = "nat-01d2eff9a9af1f937"
       }
 #####creating subnets######

resource "aws_subnet" "subnet-1" {
vpc_id = "vpc-00bf0d10a6a41600c"
cidr_block = "10.10.1.0/24"
availability_zone = "ap-south-1a"
tags = {
Name = "subnet-1"
}
}

resource "aws_subnet" "subnet-2" {
vpc_id = "vpc-00bf0d10a6a41600c"
cidr_block = "10.10.2.0/24"
availability_zone = "ap-south-1b"
tags = {
Name = "subnet-2"
}
}
#####public-rt-creation#####

resource "aws_route_table" "public-rt" {
vpc_id = "vpc-00bf0d10a6a41600c""

route {
cidr_block = "0.0.0.0/0"
gateway_id = "${aws_internet_gateway.vpc-igw.id}"
}

}
####association of subents####

resource "aws_route_table_association" "public-routing-1" {

subnet_id = "${aws_subnet.subnet-1.id}"
route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_route_table_association" "public-routing-2" {

subnet_id = "${aws_subnet.subnet-2.id}"
route_table_id = "${aws_route_table.public-rt.id}"
}
######### creating internet igw#######

resource "aws_internet_gateway" "vpc-igw" {

vpc_id = "${aws_vpc.vpc.id}"
tags = {
Name = "vpc-igw"
}
}

##lambada functioncreation

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs16.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
    
       
           
