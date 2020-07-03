# Release file Rules for Bazel

## Overview

[Bazel](https://bazel.build/) is a tool for building and testing software and can handle large, multi-language projects at scale.

This project defines a rule for making changes to a release file. Only files in json format are supported.

## Requirements

* Python Version > 3.*

## Setup

Add the following to your `WORKSPACE` file to add the necessary external dependencies:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_release_file",
    sha256 = "ea23e5bf938b226327420752b33b1c29f218aa6b2e5a93a712203a8e23ed6636",
    strip_prefix = "rules_release_file-0.2",
    urls = [
        "https://github.com/jullianow/rules_release_file/archive/v0.2.tar.gz"
    ],
)

load("@rules_release_file//release_file:repositories.bzl", release_file_repositories = "repositories")

release_file_repositories()

load("@rules_release_file//release_file:deps.bzl", release_file_deps = "deps")

release_file_deps()

load("@rules_release_file//release_file:pip_repositories.bzl", release_file_pip_deps = "pip_deps")

release_file_pip_deps()
```

## Rules

* [release](docs/release.md) ([example](examples/))
