#!/bin/bash
# Copyright 2014 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
if [ -n 'config.sh' ] && [ -f 'config.sh' ]; then
  . config.sh
  echo "Loaded config.sh"
fi

# MISC FUNCTIONS
test_error()
{
  if [[ $1 =~ '"message":"404 Not Found"' ]]; then
    echo "$2"
    exit 1
  fi
}

# GROUP
group_getid()
{
  if [ -z "$1" ]; then
    echo 'Error, group name not provided'
    exit 1
  fi
  local _id=$(curl -s -X GET --header "PRIVATE-TOKEN: $TOKEN" \
              "$URL"/groups \
              | grep -o "\"id\":[0-9]*,\"name\":\"${1}" \
              | grep -o '"id":[0-9]*,' | grep -o '[0-9]*')
  if [ -z "$_id" ]; then
    echo '0'
  else
    echo "$_id"
  fi
}

#name (required) - The name of the group
#path (required) - The path of the group
#description (optional) - The group's description
group_add()
{
  id=$(group_getid "$1")
  #User found
  if [ "$id" == '0' ]; then
    echo 'Creating new Group...'
    result=$(curl -s -X POST --header "PRIVATE-TOKEN: $TOKEN" "$URL"/groups \
             --data "name=${1}&path=${2}&description=${3}")
    test_error "$result" 'Error, user was not created'
  else
    echo "Group found with id:[$id], modifying..."
    result=$(curl -s -X PUT --header "PRIVATE-TOKEN: $TOKEN" "$URL"/groups/"$id" \
             --data "name=${1}&path=${2}&description=${3}")
  fi
}
group_delete()
{
  id=$(group_getid "$1")
  echo 'Deleting Group...'
  result=$(curl -s -X DELETE --header "PRIVATE-TOKEN: $TOKEN" "$URL"/groups/"$id" )
  test_error "$result" 'Error, Group was not deleted'
}
group_set_avatar()
{
  #File must be in the same folder that this script, or be fully qualified
  id=$(group_getid "$1")
  file="$2"
  db="$3"
  if [ ! -d gitlab/public/uploads/group/avatar/"${id}" ]; then
    mkdir -p gitlab/public/uploads/group/avatar/"${id}"
  fi
  cp -v "$2" gitlab/public/uploads/group/avatar/"${id}"
  if [ "$db" == 'mysql' ]; then
    mysql -v gitlabhq_production \
    -e "update namespaces set avatar = '${file}' where id=${id};"
  else
    echo "Error, DB ${db} is not implemented."
  fi
}

#id (required) - The ID or path of a group
#user_id (required) - The ID of a user to add
#access_level (required) - Project access level
#    GUEST     = 10
#    REPORTER  = 20
#    DEVELOPER = 30
#    MASTER    = 40
#    OWNER     = 50
#Requires that each user is send like format: 'name@domain;30'
group_add_user()
{
  id=$(group_getid "$1")
  shift
  while (( "$#" )); do
    uid=$(echo "$1" | awk -F';' '{print $1}')
    uid=$(./user.sh --search "$uid" | tail -n 1)
    level=$(echo "$1" | awk -F';' '{print $2}')
    echo "Adding user [${uid}] to group [${id}]..."
    result=$(curl -s -X POST --header "PRIVATE-TOKEN: $TOKEN" \
                  "$URL"/groups/"$id"/members \
                  --data "user_id=${uid}&access_level=${level}")
    if [[ $result =~ '"message":"Already exists"' ]]; then
      echo "User [${uid}] exists in group [${id}]."
    fi
    shift
  done
}
group_delete_user()
{
  id=$(group_getid "$1")
  uid=$(./user.sh --search "$2" | tail -n 1)
  level="$3"
  echo 'Deleting user [${uid}] from group [${id}]...'
  result=$(curl -s -X DELETE --header "PRIVATE-TOKEN: $TOKEN" \
           "$URL"/groups/"$id"/members/"${uid}" )
}

#POST  /groups/:id/projects/:project_id
group_add_project()
{
  id=$(group_getid "$1")
  shift
  while (( "$#" )); do
    pid=$(./project.sh --search "$1" | tail -n 1)
    echo "Adding project [${pid}] to group [${id}]..."
    result=$(curl -s -X POST --header "PRIVATE-TOKEN: $TOKEN" \
                  "$URL"/groups/"$id"/projects/"${pid}" )
    if [[ $result =~ '"message":"404 Not Found"' ]]; then
      echo "  Project [${pid}] already exists in group [${id}]"
    fi
    shift
  done
}

#CASE SELECTION --------------------
option="$1"
shift
case ${option} in
  '--add')
    group_add "$@"
    ;;
  '--delete')
    group_delete "$@"
    ;;
  '--avatar')
    group_set_avatar "$@"
    ;;
  '--adduser')
    group_add_user "$@"
    ;;
  '--deleteuser')
    group_delete_user "$@"
    ;;
  '--addproject')
    group_add_project "$@"
    ;;
esac