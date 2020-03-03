load("//internal:utils.bzl", "runfile", "resolve_stamp")

def _release_impl(ctx):

  runfiles=[]
  outfiles=[]
  tpl_cmd=[]
  args=ctx.actions.args()

  for src in ctx.files.files:
    out_file = ctx.actions.declare_file(src.basename + ".generated")
    args.add("--file", src.path)
    args.add("--output", out_file.path)
    runfiles.append(src)
    outfiles.append(out_file)
    if ctx.attr.apply:
      tpl_cmd.append("cp -f %s $BUILD_WORKSPACE_DIRECTORY/%s" % (runfile(ctx,out_file), src.path))

  for (key, value) in ctx.attr.substitutions.items():

    if key.strip() or value.strip():
      substitution_file = ctx.actions.declare_file(key + ".substitution")
      runfiles.append(substitution_file)

      if "{" in value:
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
    arguments = [args]
  )

  ctx.actions.expand_template(
    template = ctx.file._template,
    substitutions = {
      "%{tpl_cmd}": '; '.join(tpl_cmd)
    },
    output = ctx.outputs.executable,
    is_executable = True,
  )

  return [
      DefaultInfo(
          runfiles = ctx.runfiles(
              files = runfiles,
              transitive_files = depset(outfiles)
          ),
          files = depset(outfiles),
      ),
  ]

_release = rule(
  implementation = _release_impl,
  executable = True,
  attrs = dict(
    {
      "files": attr.label_list(
        mandatory = True,
        allow_empty = False,
        allow_files = [".json"]
      ),
      "substitutions": attr.string_dict(),
      "increments": attr.string_dict(),
      "apply": attr.bool(
        default = False
      ),
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
  ),
)

def release(name, **kwargs):
  _release(name=name, **kwargs)
  _release(name=name+'.apply', apply=True, **kwargs)
