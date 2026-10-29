import json, re

data = json.load(open('_l10n_extract.json', encoding='utf-8'))

# Collect unique UI strings (strip dart interpolation like $e, ${x})
def literal_of(line):
    # find first quoted string after Text(/labelText:/hintText:/tooltip:
    m = re.search(r"(?:Text\(|labelText:\s*|hintText:\s*|tooltip:\s*)(['\"])(.*?)\1", line, re.S)
    return m.group(2) if m else None

unique = {}
occurrences = {}
for path, hits in data.items():
    for (ln, line) in hits:
        s = literal_of(line)
        if s is None or len(s) < 2:
            continue
        unique.setdefault(s, 0)
        unique[s] += 1
        occurrences.setdefault(s, []).append((path, ln))

print("Unique literal strings:", len(unique))
print("Total occurrences:", sum(unique.values()))
print()

# Load existing EN translations to find reusable keys
en_txt = open('lib/l10n/app_localizations_en.dart', encoding='utf-8').read()
# values: map from key->english text:  L.xxx: 'Text'  or 'key': 'Text'
existing = {}
for m in re.finditer(r"^\s*(L\.[A-Za-z0-9_.]+|'[^']+'):\s*'((?:[^'\\]|\\.)*)'", en_txt, re.M):
    existing[m.group(2)] = m.group(1)

covered = [s for s in unique if s in existing]
new = [s for s in unique if s not in existing]
print("Already covered by existing EN translation (reusable):", len(covered))
print("NEW strings needing translation:", len(new))
print()
print("=== NEW strings (first 120) ===")
for s in sorted(new)[:120]:
    print(f"  {unique[s]:3d}x  {s!r}")
