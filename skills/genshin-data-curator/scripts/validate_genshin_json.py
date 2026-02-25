#!/usr/bin/env python3
import json
import sys
from pathlib import Path

VALID_ELEMENTS = {"anemo", "geo", "electro", "dendro", "hydro", "pyro", "cryo"}
VALID_NATIONS = {
    "mondstadt",
    "liyue",
    "inazuma",
    "sumeru",
    "fontaine",
    "natlan",
    "nodkrai",
    "snezhnaya",
    "other",
}
VALID_WEEKDAYS = {"monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"}
VALID_KIND = {"character", "weapon"}
VALID_WEAPON_TYPE = {"sword", "claymore", "polearm", "catalyst", "bow"}


def load_json(path: Path):
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def validate(data_dir: Path):
    errors = []
    characters_path = data_dir / "characters.json"
    weapons_path = data_dir / "weapons.json"
    schedules_path = data_dir / "schedules.json"

    for p in (characters_path, weapons_path, schedules_path):
        if not p.exists():
            errors.append(f"missing file: {p}")

    if errors:
        return errors

    characters = load_json(characters_path)
    weapons = load_json(weapons_path)
    schedules = load_json(schedules_path)

    char_ids = set()
    weapon_ids = set()
    material_ids = set()

    for i, item in enumerate(characters):
        prefix = f"characters[{i}]"
        for key in ("id", "image", "name", "element", "nation", "materialId"):
            if key not in item:
                errors.append(f"{prefix}: missing {key}")
        cid = item.get("id")
        if cid in char_ids:
            errors.append(f"{prefix}: duplicate id {cid}")
        if cid:
            char_ids.add(cid)
        if not isinstance(item.get("image"), str):
            errors.append(f"{prefix}: image must be string")
        local_image = item.get("localImage")
        if local_image is not None and not isinstance(local_image, str):
            errors.append(f"{prefix}: localImage must be string when present")
        alternatives = item.get("imageAlternatives")
        if alternatives is not None:
            if not isinstance(alternatives, list) or not all(isinstance(x, str) for x in alternatives):
                errors.append(f"{prefix}: imageAlternatives must be array<string> when present")
        if item.get("element") not in VALID_ELEMENTS:
            errors.append(f"{prefix}: invalid element {item.get('element')}")
        if item.get("nation") not in VALID_NATIONS:
            errors.append(f"{prefix}: invalid nation {item.get('nation')}")
        if item.get("materialId"):
            material_ids.add(item["materialId"])

    for i, item in enumerate(weapons):
        prefix = f"weapons[{i}]"
        for key in ("id", "image", "name", "rarity", "type", "materialId"):
            if key not in item:
                errors.append(f"{prefix}: missing {key}")
        wid = item.get("id")
        if wid in weapon_ids:
            errors.append(f"{prefix}: duplicate id {wid}")
        if wid:
            weapon_ids.add(wid)
        if not isinstance(item.get("image"), str):
            errors.append(f"{prefix}: image must be string")
        local_image = item.get("localImage")
        if local_image is not None and not isinstance(local_image, str):
            errors.append(f"{prefix}: localImage must be string when present")
        alternatives = item.get("imageAlternatives")
        if alternatives is not None:
            if not isinstance(alternatives, list) or not all(isinstance(x, str) for x in alternatives):
                errors.append(f"{prefix}: imageAlternatives must be array<string> when present")
        rarity = item.get("rarity")
        if not isinstance(rarity, int) or not (1 <= rarity <= 5):
            errors.append(f"{prefix}: rarity must be integer 1...5")
        if item.get("type") not in VALID_WEAPON_TYPE:
            errors.append(f"{prefix}: invalid type {item.get('type')}")
        if item.get("materialId"):
            material_ids.add(item["materialId"])

    schedule_material_ids = set()
    for i, item in enumerate(schedules):
        prefix = f"schedules[{i}]"
        for key in ("materialId", "materialName", "domainName", "weekdays", "kind"):
            if key not in item:
                errors.append(f"{prefix}: missing {key}")
        material_id = item.get("materialId")
        if material_id:
            schedule_material_ids.add(material_id)
        if not isinstance(item.get("materialName"), str) or not item.get("materialName"):
            errors.append(f"{prefix}: materialName must be non-empty string")
        weekdays = item.get("weekdays", [])
        if not isinstance(weekdays, list) or not weekdays:
            errors.append(f"{prefix}: weekdays must be non-empty array")
        else:
            for day in weekdays:
                if day not in VALID_WEEKDAYS:
                    errors.append(f"{prefix}: invalid weekday {day}")
        if item.get("kind") not in VALID_KIND:
            errors.append(f"{prefix}: invalid kind {item.get('kind')}")

    for material_id in sorted(material_ids):
        if material_id not in schedule_material_ids:
            errors.append(f"missing schedule for materialId: {material_id}")

    return errors


def main():
    if len(sys.argv) != 2:
        print("Usage: validate_genshin_json.py <data_dir>")
        return 2

    data_dir = Path(sys.argv[1])
    errors = validate(data_dir)
    if errors:
        print("Validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
