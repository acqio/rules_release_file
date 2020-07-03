load("@rules_release_pip_deps//:requirements.bzl", "pip_install")

def pip_deps():
    pip_install()
