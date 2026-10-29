import os, re, json

# 1) Check suspicious lines
for p in ['lib/screens/student/student_screens.dart']:
    lines = open(p, encoding='utf-8', errors='replace').read().splitlines()
    for i, l in enumerate(lines, 1):
        if 'club.' in l or 'Today' in l:
            print(p, i, repr(l[:200]))

print("----")
# 2) For each file in the extract, dump the exact UI-literal lines with line numbers
data = json.load(open('_l10n_extract.json', encoding='utf-8'))
for path in sorted(data):
    print(f"=== {path} ({len(data[path])} lines)")
    for ln, line in data[path]:
        print(f"  {ln}: {line[:170]}")
