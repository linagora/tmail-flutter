"""Shared sample input and row accumulation."""
import json


def load_json(path):
    with path.open(encoding="utf-8") as stream:
        return json.load(stream)


def add_row(rows, key, count, size):
    row = rows.setdefault(key, [0, 0])
    row[0] += count
    row[1] += size
