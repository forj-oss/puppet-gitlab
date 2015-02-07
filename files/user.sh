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

# USER
user_getid()
{
  if [ -z "$1" ]; then
    echo 'Error, user email not provided'
    exit 1
  fi
  local _id=$(curl -s -X GET --header "PRIVATE-TOKEN: $TOKEN" \
              "$URL"/users?search="$1" \
              | grep -o '"id":[0-9]*,' | grep -o '[0-9]*')
  if [ -z "$_id" ]; then
    echo '0'
  else
    echo "$_id"
  fi
}
#email (required) - Email
#password (required) - Password
#username (required) - Username
#name (required) - Name
user_add()
{
  id=$(user_getid "$1")
  #User found
  if [ "$id" == '0' ]; then
    echo 'Creating new user...'
    result=$(curl -s -X POST --header "PRIVATE-TOKEN: $TOKEN" "$URL"/users \
             --data "email=${1}&password=${2}&username=${3}&name=${4}")
    test_error "$result" 'Error, user was not created'
  else
    echo "User found with id:[$id], modifying..."
    result=$(curl -s -X PUT --header "PRIVATE-TOKEN: $TOKEN" "$URL"/users/"$id" \
             --data "email=${1}&password=${2}&username=${3}&name=${4}")
  fi
}
user_delete()
{
  id=$(user_getid "$1")
  echo 'Deleting user...'
  result=$(curl -s -X DELETE --header "PRIVATE-TOKEN: $TOKEN" "$URL"/users/"$id" )
  test_error "$result" 'Error, user was not deleted'
}

user_key_add()
{
  id=$(user_getid "$1")

  #Checking previous existance
  curl -s -X GET --header "PRIVATE-TOKEN: $TOKEN" \
       "$URL"/users/"$id"/keys \
       | grep "$3"
  if [ $? -eq 0 ]; then
    echo 'Key already exists for the user'
    exit 0
  fi

  echo "Adding key ${2} to user ${id}..."
  result=$(curl -s -X POST --header "PRIVATE-TOKEN: $TOKEN" \
                "$URL"/users/"$id"/keys \
                -F "title=$2" \
                -F "key=$3")
  test_error "$result" "Error, key was was not added to user ${id}"
}

user_set_avatar()
{
  #File must be in the same folder that this script, or be fully qualified
  id=$(user_getid "$1")
  file="$2"
  db="$3"
  if [ ! -d gitlab/public/uploads/user/avatar/"${id}" ]; then
    mkdir -p gitlab/public/uploads/user/avatar/"${id}"
  fi
  cp -v "$2" gitlab/public/uploads/user/avatar/"${id}"
  if [ "$db" == 'mysql' ]; then
    mysql -v gitlabhq_production \
    -e "update users set avatar = '${file}' where id=${id};"
  else
    echo "Error, DB ${db} is not implemented."
  fi
}

user_get_token()
{
  user="$1"
  pass="$2"
  curl -s -X POST \
       "$URL"/session \
       --data "login=${user}&password=${pass}" \
     | sed -E 's/.*token\":\"(.*)\".*/\1/g'
}

#CASE SELECTION --------------------
option="$1"
shift
case ${option} in
  '--add')
    user_add "$@"
    ;;
  '--delete')
    user_delete "$@"
    ;;
  '--search')
    user_getid "$@"
    ;;
  '--addkey')
    user_key_add "$@"
    ;;
  '--avatar')
    user_set_avatar "$@"
    ;;
  '--token')
    user_get_token "$@"
    ;;
esac