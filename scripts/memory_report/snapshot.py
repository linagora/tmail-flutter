"""Parse V8 snapshots and exclude shared WebAssembly backing stores."""
from .data import add_row


STRING_KINDS = {"string", "concatenated string", "sliced string"}
NAMED_KINDS = {"object", "closure", "native", "hidden", "array", "code"}


def row_name(kind, name):
    if kind in STRING_KINDS:
        return f"({kind})"
    if kind in NAMED_KINDS:
        return name
    return f"({kind}) {name}"


def is_buffer(key, buffer_keys):
    return key[0] in buffer_keys


class Snapshot:
    def __init__(self, data):
        meta = data["snapshot"]["meta"]
        fields, edge_fields = meta["node_fields"], meta["edge_fields"]
        self.stride, self.edge_stride = len(fields), len(edge_fields)
        self.type_i, self.name_i = fields.index("type"), fields.index("name")
        self.size_i, self.count_i = fields.index("self_size"), fields.index("edge_count")
        self.to_i = edge_fields.index("to_node")
        self.types = meta["node_types"][self.type_i]
        self.nodes, self.edges, self.strings = data["nodes"], data["edges"], data["strings"]
        self.rows, self.starts, self.memories = {}, [], []
        self.total = 0

    def collect(self):
        edge_start = 0
        for offset in range(0, len(self.nodes), self.stride):
            kind = self.types[self.nodes[offset + self.type_i]]
            name = self.name(offset)
            size = self.nodes[offset + self.size_i]
            self.starts.append(edge_start)
            edge_start += self.nodes[offset + self.count_i] * self.edge_stride
            self.total += size
            if kind == "object" and name in {"Memory", "WebAssembly.Memory"}:
                self.memories.append(offset)
            add_row(self.rows, (row_name(kind, name), kind), 1, size)

    def name(self, offset):
        return self.strings[self.nodes[offset + self.name_i]]

    def targets(self, offset, name):
        start = self.starts[offset // self.stride]
        end = start + self.nodes[offset + self.count_i] * self.edge_stride
        for edge in range(start, end, self.edge_stride):
            target = self.edges[edge + self.to_i]
            if self.name(target) == name:
                yield target

    def wasm_bytes(self):
        data_nodes = set()
        for memory in self.memories:
            for buffer in self.targets(memory, "ArrayBuffer"):
                data_nodes.update(self.targets(buffer, "system / JSArrayBufferData"))
        return sum(self.nodes[offset + self.size_i] for offset in data_nodes)


def web_sample(data, rules):
    snapshot = Snapshot(data)
    snapshot.collect()
    wasm = snapshot.wasm_bytes()
    buffer_keys = set(rules["webBufferKeys"])
    buffer_bytes = sum(value[1] for key, value in snapshot.rows.items() if is_buffer(key, buffer_keys))
    return {"rows": snapshot.rows, "total": snapshot.total - wasm,
            "buffer": buffer_bytes - wasm, "wasm": wasm}
