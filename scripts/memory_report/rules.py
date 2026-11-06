"""Evaluate R1-R5 and order class growth contributors."""
from .model import RuleResult
from .render import comparison_table


def is_tmail(key, context):
    name, origin = key
    if context.platform == "web":
        return origin == "object" and name in context.names
    return bool(origin) and origin.startswith(tuple(context.rules["tmailLibPrefixes"]))


def counted_class(key, name, platform):
    class_name, kind = key
    if class_name != name:
        return False
    return platform == "android" or kind == "object"


def class_count(sample, name, platform):
    return sum(value[0] for key, value in sample["rows"].items() if counted_class(key, name, platform))


def baseline_rules(context):
    results, failed_names = [], []
    for name in context.config.get("mustReturnToBaseline", []):
        if name not in context.names:
            # A renamed class would otherwise pass as 0 -> 0.
            results.append(RuleResult(f"R1 {name} (class not found)", (0, 0), "0", False))
            continue
        old, new = (class_count(sample, name, context.platform)
                    for sample in (context.before, context.after))
        results.append(RuleResult(f"R1 {name}", (old, new), "0", new <= old))
        if new > old:
            failed_names.append(name)
    return results, failed_names


def metric_rule(context, label, metric, setting):
    limit = context.config[setting]
    old, new = context.before[metric], context.after[metric]
    return RuleResult(label, (old, new), f"< {limit}", new - old < limit, limit)


def contributor_order(row):
    return (-(row[2][1] - row[1][1]), row[0][0], row[0][1] or "")


def class_contributors(context):
    contributors = []
    before, after = context.before["rows"], context.after["rows"]
    for key in before.keys() | after.keys():
        old, new = before.get(key, [0, 0]), after.get(key, [0, 0])
        contributors.append((key, old, new, is_tmail(key, context)))
    contributors.sort(key=contributor_order)
    return contributors


def tmail_rule(context, contributors):
    tmail = [row for row in contributors if row[3]]
    worst = max(tmail, key=lambda row: row[2][1] - row[1][1], default=None)
    old, new = (worst[1][1], worst[2][1]) if worst else (0, 0)
    limit = context.config["maxTmailClassGrowthBytes"]
    label = "R4" + (f" {worst[0][0]}" if worst else "")
    return RuleResult(label, (old, new), f"<= {limit}", new - old <= limit, limit)


def compare(context):
    results, failed_names = baseline_rules(context)
    results.append(metric_rule(context, "R2", "buffer", "maxBufferGrowthBytes"))
    results.append(metric_rule(context, "R3", "total", "maxTotalGrowthBytes"))
    contributors = class_contributors(context)
    results.append(tmail_rule(context, contributors))
    if context.platform == "android":
        results.append(metric_rule(context, "R5", "rss", "maxRssGrowthBytes"))
    return comparison_table(context, results, contributors, failed_names), results
