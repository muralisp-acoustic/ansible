#!/bin/bash
while read aws_account
do
  rm -f files/*.txt
  for region in `echo "us-east-1 eu-central-1 ca-central-1 ap-south-1 ap-southeast-1 ap-southeast-2"`
  do
    export AWS_REGION=$region
    export AWS_PROFILE=$aws_account
    ansible-playbook get_ebs_volumes_with_available_status.yml
    cat files/*.txt > reports/detached_ebs_$AWS_PROFILE.csv
    
    sed -it '/^ *$/d' reports/detached_ebs_$AWS_PROFILE.csv
    sed -it 's/^ *//' reports/detached_ebs_$AWS_PROFILE.csv
  done
  #sed -it '/^ *$/d' reports/discount_tag_$AWS_PROFILE.csv
  #sed -it '/^ *$/d' reports/discount_tag_$AWS_PROFILE.csv
done < aws_accounts

