"""Render rule results and class contributors as Markdown."""
COVERAGE = """Class sizes are *self* sizes: a buffer held by a controller shows under the buffer class, not the controller.
Android class rows cover the Dart heap only; R5 (RSS) covers native memory.
Web totals exclude the CanvasKit WebAssembly heap (wasmBytes shown per case).
"""
RULE_HEADER = ["| Rule | Before | After | Δ | Limit | ✅/❌ |",
               "| --- | ---: | ---: | ---: | --- | --- |"]
CLASS_HEADER = ["", "| Class | tmail | Δcount | Δbytes | before | after |",
                "| --- | --- | ---: | ---: | ---: | ---: |"]


def escape(value):
    return str(value).replace("|", "&#124;").replace("\n", "<br>").replace("\r", "")


def rule_row(result):
    old, new = result.values
    mark = '✅' if result.passed else '❌'
    return f"| {escape(result.label)} | {old} | {new} | {new - old} | {result.limit} | {mark} |"


def contributor_row(row, platform):
    (name, origin), old, new, owned = row
    if platform == "android" and origin:
        name = f"{name} [{origin}]"
    return f"| {escape(name)} | {'✅' if owned else ''} | {new[0] - old[0]} | {new[1] - old[1]} | {old[1]} | {new[1]} |"


def retainers(sample, name, label):
    return [f"\nRetainers {escape(name)} ({label}): {escape(retainer)}"
            for retainer in sample["retainers"].get(name, [])]


def android_notes(context, failed_names):
    lines = []
    for name in failed_names:
        lines.extend(retainers(context.before, name, "before"))
        lines.extend(retainers(context.after, name, "after"))
    return lines


def web_notes(context, failed_names):
    return [f"\nwasmBytes: before={context.before['wasm']}, after={context.after['wasm']}"]


PLATFORM_NOTES = {"android": android_notes, "web": web_notes}


def comparison_table(context, results, contributors, failed_names):
    lines = RULE_HEADER + [rule_row(result) for result in results]
    lines.extend(PLATFORM_NOTES[context.platform](context, failed_names))
    lines.extend(CLASS_HEADER)
    lines.extend(contributor_row(row, context.platform) for row in contributors[:context.config["topN"]])
    return lines
