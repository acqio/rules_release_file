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
import json
import yaml

parser = argparse.ArgumentParser(description='Resolve stamp references.')

parser.add_argument('--file', action='append', metavar="KEY=VALUE", required=True,
                    help='The release file that will be the base for the new release file.')

parser.add_argument('--output', action='append', metavar="KEY=VALUE", required=True,
                    help='The new release file.')

parser.add_argument('--substitution', action='append', metavar="KEY=VALUE",
                    help='The key and value to substitution. e.g. expo.version=path/to/file/with/value')

parser.add_argument('--increment', action='append', metavar="KEY=VALUE",
                    help='The key and value to increment.')

def read_field(dictionary, path):
    keys = path.split(".")
    current = dictionary
    for key in keys:
        if key in current:
            current = current.get(key)
        else:
            raise Exception('The key "%s" not existe in dictionary:\n%s' % (path, dictionary))

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
    if current[last].__class__ == str:
        value = str(value)
    current[last] = value

    return dictionary

def parse_var(s):
    items = s.split('=')
    key = items[0].strip() # we remove blanks around keys, as is logical
    if len(items) > 1:
        # rejoin the rest:
        value = '='.join(items[1:])
    return (key, value)

def _split_extension(p):

    b = p.rpartition("/")[-1]
    last_dot_in_basename = b.rfind(".")

    if last_dot_in_basename <= 0:
        return (p, "")

    dot_distance_from_end = len(b) - last_dot_in_basename
    return (p[:-dot_distance_from_end], p[-dot_distance_from_end:])

def main():

    args = parser.parse_args()
    files_list = args.file
    output_list = args.output

    for index, file in enumerate(files_list, start=0):
        with open(file, 'r') as read_file:

            file_extension = _split_extension(read_file.name)[1]

            objs = []
            yaml_objects = []

            if file_extension == ".json":
                objs.append(json.loads(read_file.read()))
            else:
                objs = yaml.safe_load_all(read_file)

            for obj in objs:
                if obj:
                    if args.increment:
                        for increment in args.increment:
                            inc = parse_var(increment)
                            field_value = read_field(obj, inc[0])
                            update_field(obj, inc[0], int(field_value) + int(inc[1]))

                    if args.substitution:
                        for substitution in args.substitution:
                            sub = parse_var(substitution)
                            field_value = read_field(obj, sub[0])
                            update_field(obj, sub[0], read_file_content(sub[1]))

                    with open(output_list[index], 'w') as outfile:
                        if file_extension == ".json":
                            json.dump(obj, outfile, sort_keys=True, indent=2, separators=(',', ': '))
                        else:
                            yaml_objects.append(obj)
                            yaml.dump_all(yaml_objects, outfile, sort_keys=True, indent=2, default_flow_style=False)

if __name__ == '__main__':
    main()
