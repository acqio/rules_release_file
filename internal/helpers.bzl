def _get_runfile_path(ctx, f):
    """Return the runfiles relative path of f."""
    if ctx.workspace_name:
        return ctx.workspace_name + "/" + f.short_path
    else:
        return f.short_path

def runfile(ctx, f):
    return "${RUNFILES}/%s" % _get_runfile_path(ctx, f)

def validate_stamp(stamp):
    if not (
            (
                stamp.count('{') == 1 and stamp.rindex("{") == 0) and (
                stamp.count('}') == 1 and stamp.rindex("}") == stamp.find('}')
            )
        ):
        fail ("The stamp string is badly formatted (eg {NAME}):\n" + str(stamp))
    return True

def resolve_stamp(ctx, string, output):
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
