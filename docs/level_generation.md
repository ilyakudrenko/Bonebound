# Bonebound Level Generation Notes

Date: June 20, 2026

This document tracks how Bonebound currently generates levels and should be updated whenever the level-generation system changes.

The goal is not to build a complex procedural generator too early. The current approach is intentionally simple: use hand-authored rooms, then assemble them in randomized sequences.

## Current Goal

The current level-generation goal is to create a playable graveyard route that feels slightly different each run while still using rooms designed by hand.

This gives us:

- Control over room layout quality.
- Randomness without fully random chaos.
- A clear way to add new rooms over time.
- A foundation for future Dead Cells-inspired procedural generation.

## Main Scene

The current generated level scene is:

- `res://scenes/levels/GraveyardLevel.tscn`

This is the scene the player should run to test the generated graveyard route.

The main script is:

- `res://scripts/graveyard_level.gd`

The room catalog is:

- `res://scripts/room_catalog.gd`

The room sequence catalog is:

- `res://scripts/room_sequence_catalog.gd`

## Room Library

Rooms are stored as separate authored scenes in:

- `res://scenes/rooms/`

Current room types:

- Start room
- Combat rooms
- Loot rooms
- Puzzle rooms
- Exit room

Current room scenes:

- `Room_Start.tscn`
- `Room_Exit.tscn`
- `Room_Combat_1.tscn`
- `Room_Combat_2.tscn`
- `Room_Combat_3.tscn`
- `Room_Combat_4.tscn`
- `Room_Combat_5.tscn`
- `Room_Loot_1.tscn`
- `Room_Loot_2.tscn`
- `Room_Loot_3.tscn`

## Room Catalog

`room_catalog.gd` is the central room discovery helper.

It scans:

- `res://scenes/rooms/`

Rooms are no longer manually added to arrays.

When a new room scene is placed in `res://scenes/rooms/`, the catalog can automatically find it as long as the filename follows the room naming rule.

## Room Naming Rule

Room filenames should use this pattern:

```text
Room_<Type>_<ID>.tscn
```

Examples:

- `Room_Combat_1.tscn`
- `Room_Combat_2.tscn`
- `Room_Loot_1.tscn`
- `Room_Loot_3.tscn`
- `Room_Puzzle_1.tscn`

The room type is read from the second word:

- `Room_Combat_3.tscn` becomes a combat room.
- `Room_Loot_2.tscn` becomes a loot room.
- `Room_Puzzle_1.tscn` becomes a puzzle room.

The ID is read from the third word:

- `Room_Combat_5.tscn` has ID `5`.
- `Room_Loot_12.tscn` has ID `12`.
- `Room_Puzzle_3.tscn` has ID `3`.

Start and exit rooms also use the same naming idea:

- `Room_Start.tscn`
- `Room_Exit.tscn`

The room search is case-insensitive for the naming parts, so the existing `Room_Combat_1.tscn` format works.

## Generation Method

The generator works in two randomization steps.

Step 1:

- Randomly choose a level sequence template.

Step 2:

- For each room type in that sequence, randomly choose a room from the matching room pool.

Start and exit rooms are not randomized yet. They stay fixed.

## Current Sequence Templates

Sequence templates are stored as text files in:

```text
res://scenes/rooms/room_sequences/
```

Sequence filenames use this pattern:

```text
Level_<LevelName>_<ID>.txt
```

Examples:

- `Level_Graveyard_1.txt`
- `Level_Graveyard_2.txt`

When `GraveyardLevel.tscn` loads, it randomly chooses one valid graveyard sequence file, then builds the route described inside it.

Current sequence files:

Template 1:

```text
Start -> Combat -> Combat -> Loot -> Combat -> Exit
```

Template 2:

```text
Start -> Combat -> Loot -> Combat -> Combat -> Loot -> Exit
```

Inside the text files, the same sequence can be written in a simple editable format:

```text
start, combat, combat, loot, combat, end
```

Supported separators:

- Commas
- Spaces
- New lines
- `->`

Supported room words:

- `start`
- `combat`
- `loot`
- `puzzle`
- `exit`
- `end`, which is treated as `exit`

After choosing the template:

- Each `Combat` slot picks a random combat room.
- Each `Loot` slot picks a random loot room.
- `Start` picks from start rooms.
- `Exit` or `End` picks from exit rooms.
- The same room can appear more than once in a run for now.
- The available combat and loot room pools are discovered automatically from the rooms folder.

## Room Placement

Rooms are placed horizontally from left to right.

The generator:

- Instances each room scene.
- Reads the room's `TileMap` used rectangle.
- Aligns the next room after the previous room's right edge.
- Keeps all rooms on the same vertical baseline.

This avoids the earlier problem where rooms appeared at different heights.

## Test Nodes Inside Rooms

Some authored rooms may contain helper/test nodes while being designed, such as:

- `Player`
- `GameplayCamera`

When a room is used inside the generated level, the generator removes duplicate test player and camera nodes from the instanced room.

The generated level uses:

- One main player from `GraveyardLevel.tscn`.
- One main gameplay camera from `GraveyardLevel.tscn`.

## Player Start Position

The generator uses the start room's test player position as the generated player's spawn position.

If the start room does not contain a test player, the script falls back to a default start position.

## Room Spawn Markers

Rooms can contain marker folders under a root `Markers` node. These markers are invisible in gameplay and act as authored spawn positions.

Enemy spawn markers use:

```text
Markers/EnemySpawnPoints
```

Chest spawn markers use:

```text
Markers/ChestSpawnPoints
```

Each child `Marker2D` under `ChestSpawnPoints` spawns one loot chest when the room loads.

Consumable spawn markers use:

```text
Markers/ConsumableSpawnPoints
```

Each child `Marker2D` under `ConsumableSpawnPoints` spawns one random consumable item when the room loads.

Challenge chest spawn markers use:

```text
Markers/ChallengeChestSpawnPoints
```

Each child `Marker2D` under `ChallengeChestSpawnPoints` has a 40% chance to spawn one challenge chest when the room loads. If the roll fails, nothing spawns at that marker.

Current consumables have equal spawn chance:

- Bone Flask
- Bone Repair Kit
- Soul Vial
- Swift Bone

Reusable marker scene bricks live in:

```text
res://scenes/scaled/pickups/markers/
```

Available marker bricks:

- `Markers_16px.tscn`: full room marker template with enemy, chest, and consumable folders.
- `EnemySpawnPoint_16px.tscn`: individual enemy spawn marker.
- `ChestSpawnPoint_16px.tscn`: individual chest spawn marker.
- `ConsumableSpawnPoint_16px.tscn`: individual consumable spawn marker.
- `ChallengeChestSpawnPoint_16px.tscn`: individual challenge chest chance marker.

For rooms, the folder names still matter. Enemy markers must be under `Markers/EnemySpawnPoints`, chest markers under `Markers/ChestSpawnPoints`, consumable markers under `Markers/ConsumableSpawnPoints`, and challenge chest markers under `Markers/ChallengeChestSpawnPoints`.

Challenge chest markers are also accepted directly under `Markers` if their node name starts with `ChallengeChestSpawn`. This keeps the reusable marker brick forgiving when it is dragged into a room by hand.

## Update: June 22, 2026

Room and level generation now use the reorganized scene structure:

- Runtime level scene: `res://scenes/levels/GraveyardLevel.tscn`
- Authored rooms: `res://scenes/rooms/`
- Scaled gameplay objects: `res://scenes/scaled/`
- Testing scene: `res://scenes/testing/Room_Testing_16px.tscn`

The room catalog still discovers room scenes automatically from `res://scenes/rooms/` using the `Room_<Type>_<ID>.tscn` naming rule.

Chest loot now comes from `ItemDatabase.get_chest_loot_pool()`. This pool is built from registered weapons and shields, so new weapons or shields added to the item database can become chest rewards without editing a separate chest loot array.

Challenge Chests are intentionally separate from regular generated chest markers. They should be manually placed in authored rooms when a special guaranteed legendary reward challenge is desired. They do not use common, rare, or legendary chest spawn weights.

## Chest Rarity Generation

Chest spawning uses a weighted table, similar to enemy spawning.

Current chest spawn weights:

- Common chest: 65%
- Rare chest: 25%
- Legendary chest: 10%

The spawned chest's rarity decides the rarity of the item it creates.

Current behavior:

- Common chests can drop any chest item as a common item.
- Rare chests can drop any chest item as a rare item.
- Legendary chests can drop any chest item as a legendary item.

For this first version, rarity is passed through the chest and pickup UI pipeline. The deeper stat-affix effects of item rarity are intentionally left for a later step.

## Current Strengths

This approach is useful because:

- Rooms remain handmade and readable.
- We can quickly add more rooms without rewriting the generator.
- Level length can vary by adding more sequence templates.
- Room order can change while still following a controlled structure.
- It supports future expansion into branches, locked routes, treasure rooms, secret rooms, boss rooms, and exits.

## Current Limitations

Current limitations:

- The route is still mostly linear.
- Rooms are connected only left-to-right.
- There are no branches yet.
- There are no door/entrance compatibility rules yet.
- The same room can repeat in one generated level.
- Start and exit rooms are fixed.
- The generator does not yet track difficulty pacing.
- Loot placement is room-authored, not generated separately.
- Chest positions are room-authored, but chest rarity is generated at runtime.

These limitations are acceptable for the current prototype.

## Update Rules For This Document

Update this document when we change major level-generation behavior, such as:

- Adding new room types.
- Adding new sequence templates.
- Changing how rooms are selected.
- Changing how rooms are positioned.
- Adding branching routes.
- Adding secret rooms.
- Adding room entrance/exit rules.
- Adding difficulty pacing rules.
- Adding biome-specific room pools.

Do not update this document for tiny bug fixes unless the fix changes how generation works conceptually.
