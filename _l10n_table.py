import json, re

data = json.load(open('_l10n_extract.json', encoding='utf-8'))

def literal_of(line):
    m = re.search(r"(?:Text\(|labelText:\s*|hintText:\s*|tooltip:\s*)(['\"])(.*?)\1", line, re.S)
    return m.group(2) if m else None

unique = {}
occ = {}
for path, hits in data.items():
    for (ln, line) in hits:
        s = literal_of(line)
        if s is None or len(s) < 2:
            continue
        unique[s] = unique.get(s, 0) + 1
        occ.setdefault(s, []).append(f"{path}:{ln}")

# Parse locale_keys.dart: L/class attr -> key string
lk = open('lib/l10n/locale_keys.dart', encoding='utf-8').read()
classes = {'L': {}}
cur = 'L'
for line in lk.splitlines():
    m = re.match(r"abstract final class (\w+)", line)
    if m:
        cur = m.group(1); classes[cur] = {}; continue
    m = re.match(r"\s*static const (\w+) = '([^']+)'", line)
    if m:
        classes[cur][m.group(1)] = m.group(2)

# Parse EN map: value -> key-string (resolve L.X via classes)
en_txt = open('lib/l10n/app_localizations_en.dart', encoding='utf-8').read()
value_to_key = {}
for m in re.finditer(r"^\s*(L([A-Za-z0-9_]*)\.[A-Za-z0-9_]+|'([^']+)'):\s*'((?:[^'\\]|\\.)*)'", en_txt, re.M):
    expr = m.group(1)
    val = m.group(4)
    if expr.startswith("'"):
        key = expr.strip("'")
    else:
        ref = expr[1:]
        if '.' in ref:
            cls, attr = ref.split('.', 1)
        else:
            cls, attr = 'L', ref
        cls = 'L' + cls if not cls.startswith('L') else cls
        key = classes.get(cls, {}).get(attr)
    if key and key not in value_to_key:
        value_to_key[val] = key

def snake(s):
    s2 = re.sub(r"[^A-Za-z0-9]+", "_", s).strip("_").lower()
    s2 = re.sub(r"_+", "_", s2)
    return s2

out = []
for s in sorted(unique):
    if s in value_to_key:
        out.append(f"REUSE\t{value_to_key[s]}\t{s}\t{unique[s]}")
    else:
        out.append(f"NEW\t{snake(s)}\t{s}\t{unique[s]}")

with open('_l10n_table.tsv', 'w', encoding='utf-8') as f:
    f.write("\n".join(out))
    f.write(f"\n# TOTAL {len(out)} REUSE {sum(1 for x in out if x.startswith('REUSE'))} NEW {sum(1 for x in out if x.startswith('NEW'))}\n")

print("table written", len(out))
