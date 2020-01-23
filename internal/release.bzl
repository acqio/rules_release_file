def _get_runfile_path(ctx, f):
  """Return the runfiles relative path of f."""
  if ctx.workspace_name:
    return ctx.workspace_name + "/" + f.short_path
  else:
    return f.short_path

def _runfile(ctx, f):
  return "${RUNFILES}/%s" % _get_runfile_path(ctx, f)

def _resolve_stamp(ctx, string, output):
    stamps = [ctx.info_file, ctx.version_file]
    args = ctx.actions.args()
    args.add_all(stamps, format_each = "--stamp-info-file=%s")
    args.add(string, format = "--format=%s")
    args.add(output, format = "--output=%s")
    ctx.actions.run(
        executable = ctx.executable._stamper,
        arguments = [args],
        inputs = stamps,
        tools = [ctx.executable._stamper],
        outputs = [output],
        mnemonic = "Stamp",
    )

def _release_impl(ctx):

  runfiles=[]
  outfiles=[]
  copyfiles=[]
  args=[]

  runfiles.append(ctx.executable._release_tool)
  runfiles.append(ctx.file._template)

  for src in ctx.files.release_files:
    out_file = ctx.actions.declare_file(src.basename + "-generated")
    ctx.actions.write(output = out_file, content = "The content will be here when the BAZEL RUN is executed...\n")
    outfiles.append(out_file)
    args.append("--file=%s" % _runfile(ctx,src))
    args.append("--output=%s" % _runfile(ctx,out_file))
    runfiles.append(out_file)
    runfiles.append(src)

    if ctx.attr.copy:
      copyfiles.append("cp -f %s $BUILD_WORKSPACE_DIRECTORY/%s" % (_runfile(ctx,out_file), src.path))

  for (key, value) in ctx.attr.substitutions.items():
    if "{" in value:
      stamp_file = ctx.actions.declare_file(key + "-stamp")
      _resolve_stamp(ctx, value, stamp_file)
      runfiles.append(stamp_file)
      args.append("--substitution=%s=$(cat %s)" % (key, _runfile(ctx, stamp_file)))
    else:
      args.append("--substitution=%s=%s" % (key,value))

  for (key, value) in ctx.attr.increments.items():
    args.append("--increment=%s=%s" % (key,value))

  ctx.actions.expand_template(
    template = ctx.file._template,
    substitutions = {
      "%{release_tool}": _runfile(ctx, ctx.executable._release_tool),
      "%{args}": ' '.join(args) + ";",
      "%{copyfiles}": '; '.join(copyfiles)
    },
    output = ctx.outputs.executable,
    is_executable = True,
  )

  return [
      DefaultInfo(
          runfiles = ctx.runfiles(
              files = runfiles,
          ),
          files = depset(outfiles),
          executable = ctx.outputs.executable
      ),
  ]

_release = rule(
  implementation = _release_impl,
  executable = True,
  attrs = dict(
    {
      "release_files": attr.label_list(
        mandatory = True,
        allow_empty = False,
        allow_files = [".json"]
      ),
      "substitutions": attr.string_dict(
        allow_empty = False
      ),
      "increments": attr.string_dict(
        allow_empty = False
      ),
      "copy": attr.bool(
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
  _release(name=name+'.copy', copy=True, **kwargs)
