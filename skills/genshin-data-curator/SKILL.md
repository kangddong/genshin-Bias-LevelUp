---
name: genshin-data-curator
description: Curate and validate bundled Genshin game data JSON (characters, weapons, weekday domain schedules) for this repository. Use when adding/changing in-app data files or schema fields.
---

# Genshin Data Curator

Use this skill when editing `Resources/Data/*.json`.

## Workflow
1. Update data files with stable IDs and valid enum values.
2. For full refresh from `genshin-db`, run:
```bash
node skills/genshin-data-curator/scripts/generate_from_genshin_db.js Resources/Data
```
3. To bundle character icons locally, run:
```bash
python3 skills/genshin-data-curator/scripts/download_character_images.py
```
4. To bundle weapon icons locally, run:
```bash
python3 skills/genshin-data-curator/scripts/download_weapon_images.py
```
5. Run validation script:
```bash
python3 skills/genshin-data-curator/scripts/validate_genshin_json.py Resources/Data
```
6. Fix reported schema or reference errors.
7. If schema changes are intentional, update `references/schema.md` and related Swift models.

## Rules
- IDs must be unique and lowercase snake/camel-style strings without spaces.
- `materialId` must exist in schedules.
- Weekdays must be one of: `monday`..`sunday`.
- `kind` must be `character` or `weapon`.
- Keep Korean display names user-facing and consistent.
