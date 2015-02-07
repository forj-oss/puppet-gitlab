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

project_getid()
{
  if [ -z "$1" ]; then
    echo 'Error, project name was not provided'
    exit 1
  fi
  local _id=$(curl -s -X GET --header "PRIVATE-TOKEN: $TOKEN" \
              "$URL"/projects/search/"$1" \
              | grep -o '\[{"id":[0-9]*,' | grep -o '[0-9]*')
  if [ -z "$_id" ]; then
    echo '0'
  else
    echo "$_id"
  fi
}
# visibility=0/10/20
project_add()
{
  id=$(project_getid "$1")
  #found
  if [ "$id" == '0' ]; then
    echo 'Creating new project...'
    result=$(curl -s -X POST --header "PRIVATE-TOKEN: $TOKEN" "$URL"/projects \
             --data "name=${1}&visibility_level=${2}")
    test_error "$result" 'Error, user was not created'
    id=$(project_getid "$1") #get the id after creation
  else
    echo "Project found with id:[$id], modifying..."
    result=$(curl -s -X PUT --header "PRIVATE-TOKEN: $TOKEN" "$URL"/projects/"$id" \
             --data "name=${1}&visibility_level=${2}")
  fi

  if [ -n "$3" ]; then
    echo "  -> Adding hook $3 to project..."
    project_add_hook "${id}" "${3}" "${4}" "${5}" "${6}" "${7}"
  fi
}
project_delete()
{
  id=$(project_getid "$1")
  #found
  if [ "$id" == '0' ]; then
    echo 'Deleting project ...'
    curl -s -X DELETE --header "PRIVATE-TOKEN: $TOKEN" "$URL"/projects/"$id"
  fi
}

#PROJECT HOOKS
#id (required) - The ID or NAMESPACE/PROJECT_NAME of a project
#url (required) - The hook URL
#push_events - Trigger hook on push events
#issues_events - Trigger hook on issues events
#merge_requests_events - Trigger hook on merge_requests events
#tag_push_events - Trigger hook on push_tag events
project_add_hook()
{
  id="$1"
  #found
  if [ "$id" == '0' ]; then
    echo 'Project does not exist, cannot add hook...'
  else
    echo 'Checking if hook exists...'
    pid=$(curl -s -X GET --header "PRIVATE-TOKEN: $TOKEN" "$URL"/projects/"$id"/hooks \
              | grep -o "{\"id\":[0-9]*,\"url\":\"${2}" \
              | grep -o 'id":[0-9]*' | grep -o [0-9]*)
    if [ $? -ne 0 ]; then
      echo "Adding hook to project [$id]..."
      curl -s -X POST --header "PRIVATE-TOKEN: $TOKEN" "$URL"/projects/"$id"/hooks \
           --data "url=${2}&push_events=${3}&issues_events=${4}&merge_requests_events=${5}&tag_push_events=${6}"
    else
      echo 'Hook already exists [$pid], editing...'
      curl -s -X PUT --header "PRIVATE-TOKEN: $TOKEN" "$URL"/projects/"$id"/hooks/"$pid" \
           --data "url=${2}&push_events=${3}&issues_events=${4}&merge_requests_events=${5}&tag_push_events=${6}"
    fi
  fi
}

project_add_key()
{
  id=$(project_getid "$1")

  #Checking previous existance
  curl -s -X GET --header "PRIVATE-TOKEN: $TOKEN" \
       "$URL"/projects/"$id"/keys \
       | grep "$3"
  if [ $? -eq 0 ]; then
    echo 'Key already exists for the project'
    exit 0
  fi

  echo "Adding key $2 to project $id"
  result=$(curl -s -X POST --header "PRIVATE-TOKEN: $TOKEN" \
                "$URL"/projects/"$id"/keys \
                -F "title=$2" \
                -F "key=$3")
  test_error "$result" "Error, Could not add key ${2} to project"
}

#CASE SELECTION --------------------
option="$1"
shift
case ${option} in
  '--add')
    project_add "$@"
    ;;
  '--delete')
    project_delete "$@"
    ;;
  '--search')
    project_getid "$@"
    ;;
  '--addkey')
    project_add_key "$@"
    ;;
esac