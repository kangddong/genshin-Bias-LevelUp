# JSON Schema Reference

## characters.json
- item fields: `id`, `image`, `imageAlternatives`, `name`, `element`, `nation`, `materialId`
- `image`: character icon URL string
- `imageAlternatives`: optional fallback URL array
- `localImage`: optional bundled file path (for example `Images/characters/gaming.png`)
- `element`: `anemo|geo|electro|dendro|hydro|pyro|cryo`
- `nation`: `mondstadt|liyue|inazuma|sumeru|fontaine|natlan|nodkrai|snezhnaya|other`

## weapons.json
- item fields: `id`, `image`, `imageAlternatives`, `name`, `rarity`, `type`, `materialId`
- `rarity`: integer 1...5
- `type`: `sword|claymore|polearm|catalyst|bow`
- `image`: weapon icon URL string
- `imageAlternatives`: optional fallback URL array
- `localImage`: optional bundled file path (for example `Images/weapons/the_catch.png`)

## schedules.json
- item fields: `materialId`, `materialName`, `domainName`, `weekdays`, `kind`
- `materialName`: user-facing Korean material name
- `weekdays`: array of `monday|tuesday|wednesday|thursday|friday|saturday|sunday`
- `kind`: `character|weapon`
