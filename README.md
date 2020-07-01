# Release file Rules for Bazel

## Overview

[Bazel](https://bazel.build/) is a tool for building and testing software and can handle large, multi-language projects at scale.

This project defines a rule for making changes to a release file. Only files in json format are supported.

## Requirements

* Python Version > 2.7.9 or > 3.6

## Setup

Add the following to your `WORKSPACE` file to add the necessary external dependencies:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_release_file",
    sha256 = "a0028c81e1cb4a64297bb549a3fa1cbada5199a50b6b957c49262ed5b27243c1",
    strip_prefix = "rules_release_file-0.1",
    urls = [
        "https://github.com/jullianow/rules_release_file/archive/v0.1.tar.gz"
    ],
)

load("@rules_release_file//:repositories.bzl", "repositories")
```

## Rules

* [release](docs/release.md)
