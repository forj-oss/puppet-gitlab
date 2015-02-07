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

#HOOKS
hook_getid()
{
  if [ -z "$1" ]; then
    echo 'Error, hook url was not provided'
    exit 1
  fi
  local _id=$(curl -s -X GET --header "PRIVATE-TOKEN: $TOKEN" \
              "$URL"/hooks \
              | grep -o "{\"id\":[0-9]*,\"url\":\"${1}\"[^}]*" \
              | grep -o 'id":[0-9]*,' | grep -o [0-9]* )
  if [ -z "$_id" ]; then
    echo '0'
  else
    echo "$_id"
  fi
}
#url (required) - The hook URL
hook_add()
{
  id=$(hook_getid "$1")
  #found
  if [ "$id" == '0' ]; then
    echo 'Creating new system hook...'
    result=$(curl -s -X POST --header "PRIVATE-TOKEN: $TOKEN" "$URL"/hooks \
             --data "url=$1")
    test_error "$result" 'Error, system hook was not created'
  else
    echo "System hook found with id:[$id], skipping..."
  fi
}
hook_delete()
{
  id=$(hook_getid "$1")
  #found
  if [ "$id" == '0' ]; then
    echo 'Deleting system hook...'
    curl -s -X DELETE --header "PRIVATE-TOKEN: $TOKEN" "$URL"/hooks/"$id"
  fi
}

#CASE SELECTION --------------------
option="$1"
shift
case ${option} in
  '--add')
    hook_add "$@"
    ;;
  '--delete')
    hook_delete "$@"
    ;;
esac