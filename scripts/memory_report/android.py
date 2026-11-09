"""Aggregate Android Dart heap class samples."""
from .data import add_row


def android_sample(data, rules):
    rows = {}
    for row in data["classes"]:
        add_row(rows, (row["class"], row.get("lib")), row["count"], row["bytes"])
    buffers = set(rules["bufferClasses"]["android"])
    return {"rows": rows, "total": data["heapUsage"] + data["externalUsage"],
            "buffer": sum(value[1] for (name, _), value in rows.items() if name in buffers),
            "rss": data["rss"], "retainers": data.get("retainers", {})}
