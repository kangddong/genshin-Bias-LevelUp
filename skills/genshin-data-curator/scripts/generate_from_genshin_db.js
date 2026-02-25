#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

let db;
try {
  db = require('genshin-db');
} catch (error) {
  console.error('Missing dependency: genshin-db');
  console.error('Install once and rerun: npm i genshin-db');
  process.exit(2);
}

const DAY_MAP = {
  Monday: 'monday',
  Tuesday: 'tuesday',
  Wednesday: 'wednesday',
  Thursday: 'thursday',
  Friday: 'friday',
  Saturday: 'saturday',
  Sunday: 'sunday'
};

const ELEMENT_MAP = {
  ELEMENT_ANEMO: 'anemo',
  ELEMENT_GEO: 'geo',
  ELEMENT_ELECTRO: 'electro',
  ELEMENT_DENDRO: 'dendro',
  ELEMENT_HYDRO: 'hydro',
  ELEMENT_PYRO: 'pyro',
  ELEMENT_CRYO: 'cryo'
};

const REGION_MAP = {
  Mondstadt: 'mondstadt',
  Liyue: 'liyue',
  Inazuma: 'inazuma',
  Sumeru: 'sumeru',
  Fontaine: 'fontaine',
  Natlan: 'natlan',
  'Nod-Krai': 'nodkrai',
  Snezhnaya: 'snezhnaya'
};

const WEAPON_TYPE_MAP = {
  WEAPON_SWORD_ONE_HAND: 'sword',
  WEAPON_CLAYMORE: 'claymore',
  WEAPON_POLE: 'polearm',
  WEAPON_CATALYST: 'catalyst',
  WEAPON_BOW: 'bow'
};

function slugify(value) {
  return value
    .toLowerCase()
    .replace(/[’']/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

function uniqueNonEmpty(values) {
  const seen = new Set();
  const result = [];
  for (const value of values) {
    if (!value || seen.has(value)) continue;
    seen.add(value);
    result.push(value);
  }
  return result;
}

function mapNation(character) {
  if (REGION_MAP[character.region]) {
    return REGION_MAP[character.region];
  }

  const assoc = character.associationType ?? '';
  if (assoc.startsWith('ASSOC_NODKRAI')) {
    return 'nodkrai';
  }
  if (assoc === 'ASSOC_FATUI') {
    return 'snezhnaya';
  }
  return 'other';
}

function materialFromCosts(costs) {
  if (!Array.isArray(costs)) return null;

  for (const item of costs) {
    if (!item?.name) continue;

    const materialEn = db.material(item.name, {
      resultLanguage: 'English',
      queryLanguages: ['English']
    });

    if (!materialEn?.daysOfWeek?.length) continue;

    const materialKo = db.material(item.name, {
      resultLanguage: 'Korean',
      queryLanguages: ['English']
    }) || materialEn;

    return {
      materialId: slugify(materialEn.name),
      weekdays: materialEn.daysOfWeek.map((day) => DAY_MAP[day]).filter(Boolean),
      domainName: materialKo.dropDomainName || materialEn.dropDomainName || '',
      materialName: materialKo.name || materialEn.name,
      nameKo: materialKo.name || materialEn.name
    };
  }

  return null;
}

function buildData() {
  const scheduleMap = new Map();
  const characters = [];
  const weapons = [];

  const characterNames = db.characters('names', { matchCategories: true });
  for (const enName of characterNames) {
    const characterEn = db.character(enName, { resultLanguage: 'English' });
    if (!characterEn) continue;

    const element = ELEMENT_MAP[characterEn.elementType];
    if (!element) continue;

    const talent = db.talents(enName, { resultLanguage: 'English' });
    const material = materialFromCosts(talent?.costs?.lvl2);
    if (!material) continue;

    const characterKo = db.character(enName, {
      resultLanguage: 'Korean',
      queryLanguages: ['English']
    }) || characterEn;

    const imageCandidates = uniqueNonEmpty([
      characterKo.images?.hoyowiki_icon,
      characterKo.images?.mihoyo_icon,
      characterKo.images?.['hoyolab-avatar'],
      characterKo.images?.card
    ]);

    const item = {
      id: slugify(enName),
      image: imageCandidates[0] || '',
      imageAlternatives: imageCandidates.slice(1),
      name: characterKo.name,
      element,
      nation: mapNation(characterEn),
      materialId: material.materialId
    };

    characters.push(item);

    if (!scheduleMap.has(material.materialId)) {
      scheduleMap.set(material.materialId, {
        materialId: material.materialId,
        materialName: material.materialName,
        domainName: material.domainName,
        weekdays: material.weekdays,
        kind: 'character'
      });
    }
  }

  const weaponNames = db.weapons('names', { matchCategories: true });
  for (const enName of weaponNames) {
    const weaponEn = db.weapon(enName, { resultLanguage: 'English' });
    if (!weaponEn) continue;

    const material = materialFromCosts(weaponEn?.costs?.ascend1);
    if (!material) continue;

    const weaponKo = db.weapon(enName, {
      resultLanguage: 'Korean',
      queryLanguages: ['English']
    }) || weaponEn;

    const imageCandidates = uniqueNonEmpty([
      weaponKo.images?.icon,
      weaponKo.images?.mihoyo_icon,
      weaponKo.images?.mihoyo_awakenIcon,
      weaponEn.images?.icon,
      weaponEn.images?.mihoyo_icon,
      weaponEn.images?.mihoyo_awakenIcon
    ]);

    const item = {
      id: slugify(enName),
      name: weaponKo.name,
      rarity: Number(weaponEn.rarity) || 1,
      image: imageCandidates[0] || '',
      imageAlternatives: imageCandidates.slice(1),
      type: WEAPON_TYPE_MAP[weaponEn.weaponType] || 'sword',
      materialId: material.materialId
    };

    weapons.push(item);

    if (!scheduleMap.has(material.materialId)) {
      scheduleMap.set(material.materialId, {
        materialId: material.materialId,
        materialName: material.materialName,
        domainName: material.domainName,
        weekdays: material.weekdays,
        kind: 'weapon'
      });
    }
  }

  characters.sort((a, b) => a.name.localeCompare(b.name, 'ko'));
  weapons.sort((a, b) => a.name.localeCompare(b.name, 'ko'));

  const schedules = Array.from(scheduleMap.values()).sort((a, b) => {
    if (a.kind !== b.kind) return a.kind.localeCompare(b.kind);
    return a.materialId.localeCompare(b.materialId);
  });

  return { characters, weapons, schedules };
}

function writeJson(filePath, data) {
  fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
}

function main() {
  const outDirArg = process.argv[2];
  if (!outDirArg) {
    console.error('Usage: node generate_from_genshin_db.js <out_dir>');
    process.exit(2);
  }

  const outDir = path.resolve(process.cwd(), outDirArg);
  fs.mkdirSync(outDir, { recursive: true });

  const { characters, weapons, schedules } = buildData();
  writeJson(path.join(outDir, 'characters.json'), characters);
  writeJson(path.join(outDir, 'weapons.json'), weapons);
  writeJson(path.join(outDir, 'schedules.json'), schedules);

  console.log(`Generated characters: ${characters.length}`);
  console.log(`Generated weapons: ${weapons.length}`);
  console.log(`Generated schedules: ${schedules.length}`);
}

main();
