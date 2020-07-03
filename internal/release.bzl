load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("//internal:helpers.bzl", "validate_stamp", "resolve_stamp", "runfile",)

_common_attr = dict(
    {
        "files": attr.label_list(
            mandatory = True,
            allow_empty = False,
            allow_files = [".json", ".yaml", ".yml"],
        ),
        "substitutions": attr.string_dict(),
        "increments": attr.string_dict(),
        "_stamper": attr.label(
            default = Label("//internal:stamper"),
            cfg = "host",
            executable = True,
        ),
        "_release_tool": attr.label(
            default = Label("//internal:release.par"),
            cfg = "host",
            executable = True,
        ),
        "_template": attr.label(
            default = Label("//internal:release.sh.tpl"),
            allow_single_file = True,
        ),
    },
)

def _release_impl(ctx):
    runfiles = []
    outfiles = []
    CMD = []
    args = ctx.actions.args()

    for src in ctx.files.files:
        out_file = ctx.actions.declare_file(src.basename + ".generated")
        args.add("--file", src.path)
        args.add("--output", out_file.path)
        outfiles.append(out_file)
        if ctx.attr._apply:
            CMD.append("cp -f %s $BUILD_WORKSPACE_DIRECTORY/%s" % (runfile(ctx, out_file), src.path))

    runfiles += ctx.files.files

    for (key, value) in ctx.attr.substitutions.items():
        if key.strip() or value.strip():
            substitution_file = ctx.actions.declare_file(key + ".substitution")
            runfiles.append(substitution_file)

            if validate_stamp(value):
                resolve_stamp(ctx, value, substitution_file)
            else:
                ctx.actions.write(substitution_file, value)

            args.add("--substitution", "%s=%s" % (key, substitution_file.path))
        else:
            fail("The dictionary key or value cannot be empty.\n%s" % str(ctx.attr.substitutions))

    for (key, value) in ctx.attr.increments.items():
        if key.strip() or value.strip():
            args.add("--increment", "%s=%s" % (key, value))
        else:
            fail("The dictionary key or value cannot be empty.\n%s" % str(ctx.attr.increments))

    ctx.actions.run(
        inputs = runfiles,
        outputs = outfiles,
        executable = ctx.executable._release_tool,
        tools = [ctx.executable._release_tool],
        arguments = [args],
    )

    ctx.actions.expand_template(
        template = ctx.file._template,
        substitutions = {
            "%{CMD}": " && ".join(CMD),
        },
        output = ctx.outputs.executable,
        is_executable = True,
    )

    return [
        DefaultInfo(
            runfiles = ctx.runfiles(
                files = runfiles,
                transitive_files = depset(outfiles),
            ),
            files = depset(outfiles + [ctx.outputs.executable]),
        ),
    ]

_release = rule(
    implementation = _release_impl,
    executable = True,
    attrs = dicts.add(
        _common_attr,
        dict(
            {
                "_apply": attr.bool(
                    default = False,
                ),
            },
        ),
    ),
)

_release_apply = rule(
    implementation = _release_impl,
    executable = True,
    attrs = dicts.add(
        _common_attr,
        dict(
            {
                "_apply": attr.bool(
                    default = True,
                ),
            },
        ),
    ),
)

def release(name, **kwargs):
    _release(name = name, **kwargs)
    _release_apply(name = name + ".apply", **kwargs)
