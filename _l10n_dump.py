import json, re

data = json.load(open('_l10n_extract.json', encoding='utf-8'))

def literal_of(line):
    m = re.search(r"(?:Text\(|labelText:\s*|hintText:\s*|tooltip:\s*)(['\"])(.*?)\1", line, re.S)
    return m.group(2) if m else None

unique = {}
occurrences = {}
for path, hits in data.items():
    for (ln, line) in hits:
        s = literal_of(line)
        if s is None or len(s) < 2:
            continue
        unique[s] = unique.get(s, 0) + 1
        occurrences.setdefault(s, []).append(f"{path}:{ln}")

en_txt = open('lib/l10n/app_localizations_en.dart', encoding='utf-8').read()
existing = {}
for m in re.finditer(r"^\s*(L\.[A-Za-z0-9_.]+|'[^']+'):\s*'((?:[^'\\]|\\.)*)'", en_txt, re.M):
    existing[m.group(2)] = m.group(1)

new = [s for s in unique if s not in existing]
static_new = [s for s in new if '$' not in s]
interp_new = [s for s in new if '$' in s]

with open('_l10n_new_strings.txt', 'w', encoding='utf-8') as f:
    f.write("=== STATIC NEW STRINGS (can be map keys) ===\n")
    for s in sorted(static_new):
        f.write(f"{unique[s]:3d}x  {s}\n")
    f.write("\n=== INTERPOLATED NEW STRINGS (need code-level handling) ===\n")
    for s in sorted(interp_new):
        f.write(f"{unique[s]:3d}x  {s}\n")
        for occ in occurrences[s]:
            f.write(f"        @ {occ}\n")

print("static new:", len(static_new))
print("interpolated new:", len(interp_new))
print("written to _l10n_new_strings.txt")
