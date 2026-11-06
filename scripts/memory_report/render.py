"""Render rule results and class contributors as Markdown."""
COVERAGE = """Class sizes are *self* sizes: a buffer held by a controller shows under the buffer class, not the controller.
Android class rows cover the Dart heap only; R5 (RSS) covers native memory.
Web totals exclude the CanvasKit WebAssembly heap (wasmBytes shown per case).
"""
KIB = 1024
MIB = KIB * KIB
NEAR_LIMIT = 0.75
RULE_HEADER = ["| Rule | Before | After | Δ | Limit | % of limit | ✅/❌ |",
               "| --- | ---: | ---: | ---: | --- | ---: | --- |"]
SUMMARY_HEADER = ["| Flow | Platform | Result | Biggest growth |", "| --- | --- | --- | --- |"]
RULE_NAMES = {"R2": "buffer", "R3": "heap", "R4": "class", "R5": "RSS"}
CLASS_HEADER = ["", "| Class | tmail | Δcount | Δbytes | before | after |",
                "| --- | --- | ---: | ---: | ---: | ---: |"]


def escape(value):
    return str(value).replace("|", "&#124;").replace("\n", "<br>").replace("\r", "")


def size(value):
    # Class rows grow by bytes; under 1 MB they would all read 0.00 MB.
    if abs(value) < MIB:
        return f"{value / KIB:.1f} KB"
    return f"{value / MIB:.2f} MB"


def signed_size(value):
    return ('+' if value >= 0 else '-') + size(abs(value))


def growth(result):
    old, new = result.values
    return new - old


def limit_share(result):
    return growth(result) / result.limit_bytes if result.limit_bytes else 0


def is_near_limit(result):
    return result.passed and limit_share(result) >= NEAR_LIMIT


def mark(result):
    if not result.passed:
        return '❌'
    return '⚠️' if is_near_limit(result) else '✅'


def rule_row(result):
    old, new = result.values
    if not result.limit_bytes:
        return f"| {escape(result.label)} | {old} | {new} | {new - old} | {result.limit} |  | {mark(result)} |"
    operator = result.limit.split()[0]
    return (f"| {escape(result.label)} | {size(old)} | {size(new)} | {signed_size(new - old)} | "
            f"{operator} {size(result.limit_bytes)} | {limit_share(result):.0%} | {mark(result)} |")


def biggest_growth(results):
    sized = [result for result in results if result.limit_bytes]
    if not sized:
        return ""
    worst = max(sized, key=limit_share)
    name = RULE_NAMES.get(worst.label.split()[0], worst.label)
    return f"{escape(name)} {signed_size(growth(worst))} ({limit_share(worst):.0%} of {size(worst.limit_bytes)})"


def verdict(results):
    failed = sum(not result.passed for result in results)
    if failed:
        return f"❌ {failed} rule(s) failed"
    return "⚠️ Pass, near limit" if any(is_near_limit(result) for result in results) else "✅ No leak"


def summary_row(title, platform, result, growth_text=""):
    return f"| {escape(title)} | {platform} | {result} | {growth_text} |"


def one_line(value):
    return str(value).replace("\r", " ").replace("\n", " ")


def near_limit_warnings(case, platform, results):
    # Workflow commands are line-based; a newline would cut the annotation.
    return [f"::warning::{one_line(result.label)} {one_line(case)} ({platform}): {signed_size(growth(result))} = "
            f"{limit_share(result):.0%} of {size(result.limit_bytes)}. Near the limit: may fail without a real leak."
            for result in results if is_near_limit(result)]


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
