def _get_runfile_path(ctx, f):
  """Return the runfiles relative path of f."""
  if ctx.workspace_name:
    return ctx.workspace_name + "/" + f.short_path
  else:
    return f.short_path

def runfile(ctx, f):
  return "${RUNFILES}/%s" % _get_runfile_path(ctx, f)
