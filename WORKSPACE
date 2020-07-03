workspace(name = "rules_release_file")

load("@rules_release_file//release_file:repositories.bzl", release_files_repositories = "repositories")

release_files_repositories()

load("@rules_release_file//release_file:deps.bzl", release_files_deps = "deps")

release_files_deps()

load("@rules_release_file//release_file:pip_repositories.bzl", release_file_pip_deps = "pip_deps")

release_file_pip_deps()
