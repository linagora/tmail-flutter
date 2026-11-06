"""Related comparison inputs and evaluated rule values."""
from dataclasses import dataclass


@dataclass
class Comparison:
    before: dict
    after: dict
    platform: str
    rules: dict
    config: dict
    names: set


@dataclass
class RuleResult:
    label: str
    values: tuple
    limit: str
    passed: bool
    limit_bytes: int = 0
