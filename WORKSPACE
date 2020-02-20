workspace(name = "rules_release_file")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

http_archive(
    name = "rules_python",
    sha256 = "aa96a691d3a8177f3215b14b0edc9641787abaaa30363a080165d06ab65e1161",
    urls = [
        "https://github.com/bazelbuild/rules_python/releases/download/0.0.1/rules_python-0.0.1.tar.gz"
    ],
)

git_repository(
    name = "subpar",
    remote = "https://github.com/google/subpar",
    commit = "9fae6b63cfeace2e0fb93c9c1ebdc28d3991b16f",
    shallow_since = "1565833028 -0400"
)
