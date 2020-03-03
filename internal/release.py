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

parser.add_argument('--file', action='append', metavar="KEY=VALUE",
                    help='The release file that will be the base for the new release file.')

parser.add_argument('--output', action='append', metavar="KEY=VALUE",
                    help='The new release file.')

parser.add_argument('--substitution', action='append', metavar="KEY=VALUE",
                    help='The key and value to substitution. e.g. expo.version=path/to/file/with/value')

parser.add_argument('--increment', action='append', metavar="KEY=VALUE",
                    help='The key and value to increment.')

def read_field(dictionary, path):
    keys = path.split(".")
    current = dictionary
    for key in keys:
        current = current.get(key)
    return current

def read_file_content(path):
    with open(path) as f: return f.read()

def update_field(dictionary, path, value):
    keys = path.split(".")
    last = keys[-1]
    keys = keys[:-1]
    current = dictionary
    for key in keys:
        current = current.get(key)
    if current[last].__class__ == unicode:
        value = str(value)
    current[last] = value

    return dictionary

def parse_var(s):
    """
    Parse a key, value pair, separated by '='
    That's the reverse of ShellArgs.

    On the command line (argparse) a declaration will typically look like:
        foo=hello
    or
        foo="hello world"
    """
    items = s.split('=')
    key = items[0].strip() # we remove blanks around keys, as is logical
    if len(items) > 1:
        # rejoin the rest:
        value = '='.join(items[1:])
    return (key, value)

def main():

    args = parser.parse_args()
    files_list = args.file
    output_list = args.output

    for index, file in enumerate(files_list,start=0):
        with open(file,'r') as json_file:

            _json = json.load(json_file)

            if args.substitution:
                for substitution in args.substitution:
                    sub = parse_var(substitution)
                    update_field(_json, sub[0], read_file_content(sub[1]))

            if args.increment:
                for increment in args.increment:
                    inc = parse_var(increment)
                    update_field(_json,inc[0],int(read_field(_json, inc[0])) + int(inc[1]))

            with open(output_list[index], 'w') as outfile:
                json.dump(_json, outfile, sort_keys=True, indent=2, separators=(',', ': '))

if __name__ == '__main__':
  main()
