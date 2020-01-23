# Copyright 2017 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Resolve release files."""

import argparse
import sys
import json
import os

parser = argparse.ArgumentParser(description='Resolve stamp references.')

parser.add_argument('--file', action='append',
                    help='The release file that will be the base for the new release file.')

parser.add_argument('--output', action='append',
                    help='The new release file.')

parser.add_argument('--substitution', action='append',
                    help='The key and value to substitution. e.g. expo.version={STABLE_GIT_COMMIT}')

parser.add_argument('--increment', action='append',
                    help='The key and value to increment.')

parser.add_argument('--output_to_workspce', action='store',
                    help='Copy output file to workspace bazel project.')

def read_field(dictionary, path):
    keys = path.split(".")
    current = dictionary
    for key in keys:
        current = current.get(key)
    return current

def update_field(dictionary, path, value):
    keys = path.split(".")
    last = keys[-1]
    keys = keys[:-1]
    current = dictionary
    for key in keys:
        current = current.get(key)
    current[last] = value
    return dictionary

def main():

    args = parser.parse_args()
    files_list = args.file
    output_list = args.output

    for index, file in enumerate(files_list,start=0):
        with open(file,'r+') as json_file:

            _json = json.load(json_file)

            if args.substitution:
                for sub in args.substitution:
                    subs = sub.split("=")
                    update_field(_json, subs[0], subs[1])

            if args.increment:
                for inc in args.increment:
                    inc = inc.split("=")
                    update_field(_json,inc[0],int(read_field(_json, inc[0])) + int(inc[1]))

            json_file.seek(0) # Clear file.

            with open(output_list[index], 'w') as outfile:
                json.dump(_json, outfile, sort_keys=True, indent=2, separators=(',', ': '))

if __name__ == '__main__':
  main()
