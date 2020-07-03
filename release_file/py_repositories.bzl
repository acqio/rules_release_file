load("@rules_python//python:pip.bzl", "pip3_import", "pip_repositories")

def py_deps():

    excludes = native.existing_rules().keys()
    if "rules_release_pip_deps" not in excludes:
        pip_repositories()

        pip3_import(
            name = "rules_release_pip_deps",
            requirements = "@rules_release_file//release_file:requirements.txt",
        )
