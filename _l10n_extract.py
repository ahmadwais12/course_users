import os, re, json

root = 'lib'
report = {}
for dirpath, dirnames, filenames in os.walk(root):
    for f in sorted(filenames):
        if not f.endswith('.dart'):
            continue
        p = os.path.join(dirpath, f).replace(os.sep, '/')
        txt = open(p, encoding='utf-8', errors='replace').read()
        if 'AppLocalizations.translate' in txt or 'translate(' in txt or '/l10n/' in txt:
            continue
        lines = txt.splitlines()
        hits = []
        for i, line in enumerate(lines, 1):
            if re.search(r"Text\(['\"]|labelText:\s*['\"]|hintText:\s*['\"]|tooltip:\s*['\"]", line):
                hits.append((i, line.strip()))
        if hits:
            report[p] = hits

out = json.dumps(report, ensure_ascii=False, indent=1)
open('_l10n_extract.json', 'w', encoding='utf-8').write(out)
print("Files:", len(report))
total = sum(len(v) for v in report.values())
print("Total UI literal lines:", total)
