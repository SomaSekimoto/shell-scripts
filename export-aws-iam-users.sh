adminusernames=(user1 user2)
useractions=(get-user list-user-policies list-attached-user-policies )
groupactions=(list-group-policies list-attached-group-policies)

for username in ${adminusernames[@]};
do
  for action in ${useractions[@]};do
    RES=$(aws iam $action --user-name $username --output table)
    echo "$RES" >> $username.txt
  done;
  GROUP=$(aws iam list-groups-for-user --user-name $username --output table)
  echo "$GROUP" >> $username.txt
  GROUPNAME=$(echo $(aws iam list-groups-for-user --user-name $username --output json | jq '.Groups[].GroupName') | sed 's/"//g')
  echo $GROUPNAME
  for action in ${groupactions[@]};do
    echo $username
    RES=$(aws iam $action --group-name $GROUPNAME  --output table)
    echo "$RES" >> $username.txt
    if [ $action = list-attached-group-policies ]; then
      PolicyArns=$(aws iam $action --group-name $GROUPNAME  --output json | jq '.AttachedPolicies[].PolicyArn')
      for arn in ${PolicyArns[@]};do
        policy=$(aws iam get-policy-version --policy-arn $(echo $arn | sed 's/"//g') --version-id $(aws iam get-policy --policy-arn $(echo $arn | sed 's/"//g') --output json | jq -r '.Policy.DefaultVersionId'))
        echo "$policy" >> $username.txt
      done;
    fi
  done;
done;


