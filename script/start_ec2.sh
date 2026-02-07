#!/bin/bash

if [ $# -eq 0 ]; then
  echo "usage: $0 <インスタンスID> [インスタンスID ...]"
  exit 1
fi

aws ec2 start-instances --instance-ids "$@"
# aws ec2 start-instances --instance-ids i-05f688f88e7906c22