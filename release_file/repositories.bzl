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
"""Rules to load all dependencies of rules_release_file."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def repositories():
    """Download dependencies of container rules."""
    excludes = native.existing_rules().keys()

    if "bazel_skylib" not in excludes:
        http_archive(
            name = "bazel_skylib",
            sha256 = "e5d90f0ec952883d56747b7604e2a15ee36e288bb556c3d0ed33e818a4d971f2",
            strip_prefix = "bazel-skylib-1.0.2",
            urls = [
                "https://github.com/bazelbuild/bazel-skylib/archive/1.0.2.tar.gz",
            ],
        )

    if "rules_python" not in excludes:
        git_repository(
            name = "rules_python",
            remote = "https://github.com/bazelbuild/rules_python/",
            commit = "708ed8679d7510a331ce9a7b910a2a056d24f7b1",
            shallow_since = "1590213058 +1000",
        )

    if "subpar" not in excludes:
        git_repository(
            name = "subpar",
            remote = "https://github.com/google/subpar",
            commit = "9fae6b63cfeace2e0fb93c9c1ebdc28d3991b16f",
            shallow_since = "1565833028 -0400",
        )
