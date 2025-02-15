#!/bin/bash

aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId, PublicIpAddress]" --output text