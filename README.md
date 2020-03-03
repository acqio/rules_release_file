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

# This requires that python be available in your distribution,
# as this project uses rules_python to build the binary databricks cli.
# Download the rules_databricks repository at release v0.1

http_archive(
    name = "rules_release_file",
    sha256 = "cc75cf0d86312e1327d226e980efd3599704e01099b58b3c2fc4efe5e321fcd9",
    strip_prefix = "rules_databricks-0.1",
    urls = [
        "https://github.com/bazelbuild/rules_databricks/releases/download/v0.1/rules_databricks-v0.1.tar.gz"
    ],
)

```

## Rules

* [release](#release)

<a name="release"></a>
### release

```python
release(name, files, substitutions, increments)
```

<table class="table table-condensed table-bordered table-implicit">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Implicit targets</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code><i>name</i>.apply</code></td>
      <td>
        <code>File modification in workspace</code>
        <p>
          This target changes the file passed in the files attribute in the workspace.
        </p>
      </td>
    </tr>
  </tbody>
</table>

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <code>Name, required</code>
        <p>A unique name for this rule.</p>
      </td>
    </tr>
    <tr>
      <td><code>files</code></td>
      <td>
        <code>The list of files `.json`s, required</code>
        <p>
          A list of files <code>.json</code> that should be used as the basis for the new release files.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>substitutions</code></td>
      <td>
        <code>Dictionary from strings to strings, optional</code>
        <p>Raw substitution of the value of a given document key.</p>
        <p>This field supports stamp variables.</p>
        <p>
          <code>
            substitutions = {
              "path.to.foo": "{BUILD_TIMESTAMP}",
              "path.to.bar": "20.02.02",
           ...
          },
          </code>
        </p>
      </td>
    </tr>
    <tr>
      <td><code>increments</code></td>
      <td>
        <code>Dictionary from strings to strings, optional</code>
        <p>Increment of an integer value existing in a document key.
          The key value can be a string, which contains an integer.</p>
        <p>The increment unit will be the value defined in the dictionary.</p>
        <p>
          <code>
            increments = {
              "path.to.foo": "1",
           ...
          },
          </code>
        </p>
      </td>
    </tr>
  </tbody>
</table>
