# Bonebound Prototype Progress

Date: June 20, 2026

## Project Overview

Bonebound is a Godot 4 2D side-scroller roguelike / roguelite prototype inspired by games like Dead Cells, but built around a body-part system instead of traditional equipment-only progression.

The player begins as a weak skeleton made from separate body parts:

- Head
- Torso
- Left arm
- Right arm
- Left leg
- Right leg

The core idea is that the player can sacrifice, throw, lose, recover, and replace body parts. Body parts are both the character's body and part of the build system.

The character, enemies, weapons, and body parts still use simple placeholder shapes, but the level-building prototype now uses a temporary 16x16 graveyard tileset. This lets rooms be blocked out with readable platform art while combat systems remain easy to inspect and change.

## Current Prototype Scene

The main runtime prototype scene is:

- `res://scenes/levels/level_graveyard/GraveyardLevel.tscn`

The older playground scene still exists for isolated testing, but current room and level work is focused on the graveyard scene.

The graveyard level currently includes:

- Runtime assembly from authored room scenes
- A scaled 16px player prototype
- Scaled enemies
- Ladders
- Doors
- Spike hazards
- Parallax background layers
- Sword, shield, and axe pickups in the starting room
- Camera follow behavior tuned for the scaled player

## Progress Update: June 22, 2026

Major prototype updates since the previous save:

- Project scenes and scripts were reorganized into clearer folders for legacy scenes, scaled gameplay objects, rooms, levels, testing scenes, UI, pickups, world objects, and data.
- The active 16px prototype now uses scaled weapons, shields, body parts, enemies, doors, ladders, projectiles, and chests.
- Item data was centralized in `ItemDatabase`, including weapon stats, shield stats, icon regions, pickup scenes, rarity modifiers, and chest loot discovery.
- Body-part reward data was centralized in `BodyPartDatabase`, including body-part ids, reward ids, colors, labels, descriptions, and drop weights.
- Challenge Chest data was moved into `ChallengeDatabase`, making challenge definitions easier to extend.
- Regular loot chests now support common, rare, and legendary visual states using actual chest sprites instead of only color tinting.
- Challenge Chests were added as separate hand-placed special chests. They are not part of regular rarity chest spawning and can reward a random legendary item after the player completes a challenge.
- Current Challenge Chest prototypes include: kill two enemies without taking damage, kill one enemy using a thrown body part, and sacrifice the left arm.
- New weapons and shields were added to the prototype item system, including Grave Rapier, Bone Cleaver, Soul Harvester, Bone Mirror, and Spiked Shield.
- Weapon and shield rarity behavior has been expanded for common, rare, and legendary item states.
- Soul Harvester now shows visual Soul Stack pips in the HUD.
- Body-part abilities now include Boomerang Arms, Harpoon Arms, Stomp Legs, and Spider Legs.
- Enemy variety now includes the basic patrol enemy, shield enemy, and bomb-throwing ranged enemy.
- The testing room `res://scenes/testing/Room_Testing_16px.tscn` remains useful for isolated mechanics testing.

## Player Body System

The player is built from separate `ColorRect` body parts:

- Head: yellow
- Torso: blue
- Arms: red by default
- Legs: green by default

The player tracks body part state with booleans:

- `has_head`
- `has_left_arm`
- `has_right_arm`
- `has_left_leg`
- `has_right_leg`

The player also now tracks body part IDs and colors, allowing future scaling into many different body part types.

Examples:

- `skeleton_right_arm`
- `enemy_right_arm`
- `skeleton_left_leg`
- `enemy_left_leg`

This means future body parts can have different stats, colors, abilities, and restrictions.

## Movement And Camera

Current movement includes:

- Move left/right with `A` and `D`
- Jump with `Space`
- Gravity
- Facing direction
- Roll with `Shift`
- Basic crawler mode when both legs are missing
- Ladder climbing

The camera uses a Dead Cells-inspired dead-zone behavior:

- The camera does not constantly follow every small movement.
- The player can move inside a camera area.
- When the player leaves that area, the camera gradually follows.
- The scaled graveyard player uses a closer camera zoom so 16x16 rooms remain readable.

## Ladder System

Ladders are now part of the 16px room-building toolkit.

Current ladder behavior:

- Ladders use the temporary graveyard ladder graphic.
- Ladders can be stacked vertically to reach different platform heights.
- When the player is inside ladder range, holding `Space` climbs upward.
- Releasing `Space` while on a ladder makes the player slowly slide downward.
- Holding `S` climbs downward faster.
- The player can move left or right away from the ladder.
- The player can roll off a ladder with `A/D + Shift`.

This gives rooms vertical routing without needing final art or a complex movement system.

## Leg Mechanics

The player can sacrifice basic skeleton legs with `3`.

Skeleton leg rules:

- One missing leg reduces movement and jump ability.
- Two missing legs put the player in crawler mode.
- In crawler mode, the player is lower to the ground.
- Crawler mode allows only a very small hop.
- Dropped legs can be picked back up.

Enemy leg rules:

- Enemy legs are light blue.
- Enemy legs give the player one mid-air double jump.
- The double jump resets when the player lands.
- Enemy legs cannot be detached or sacrificed.
- This creates a tradeoff: better mobility, but no emergency leg sacrifice jump.

## Arm Mechanics

The player can throw arms:

- `1`: throw left arm
- `2`: throw right arm

Thrown arms act like arcing projectiles:

- They fly forward in a parabola.
- They deal damage on hit.
- They stun enemies for a short time.
- After impact or after a short time, they drop to the ground.
- They can be picked back up.

Arm consequences:

- Throwing the right arm disables main-hand weapons.
- Throwing the left arm disables shield use.
- If a thrown arm carried a weapon or shield, that item is removed from inventory and restored only when the matching arm is picked back up.

Enemy arm rules:

- Enemy arm is pink.
- Enemy right arm counts as a stronger arm.
- Strong enemy arms allow the player to use heavy weapons.

## Weapons

The prototype currently has two main-hand weapons:

- Sword
- Axe

Main-hand weapons require the right arm.

### Sword

The sword is a light weapon.

Rules:

- Can be used with the basic skeleton right arm.
- Deals 1 damage.
- Has faster attack timing.
- Does not stun enemies.

### Axe

The axe is a heavy weapon.

Rules:

- Requires the enemy right arm.
- Cannot be picked up or used with the basic skeleton right arm.
- Deals 3 damage.
- Has slower attack timing.
- Has longer recovery/cooldown.
- Slows the player more during the attack.
- Stuns enemies on hit.

## Weapon Pickup And Swapping

Weapon pickup now works closer to Dead Cells.

Rules:

- If the player has no main-hand weapon, walking into a weapon picks it up.
- If the player already has a main-hand weapon, walking near another weapon shows `Press E`.
- Pressing `E` swaps the equipped weapon with the weapon on the ground.
- The old weapon appears on the ground where the new one was picked up.

Current examples:

- Sword can be picked up with the basic arm.
- Axe can only be picked up after obtaining the enemy arm.

## Shield System

The shield is an off-hand item tied to the left arm.

Rules:

- Shield pickup requires the left arm.
- Shield is used with `K`.
- Shield has a short parry window.
- If the player parries during the enemy's prepare/attack timing, the enemy is stunned.
- Throwing the left arm removes shield access until that arm is recovered.

## Roll System

The player has a roll mechanic inspired by Dead Cells.

Rules:

- Roll with `Shift`.
- Rolling pushes the player forward.
- The collision shape becomes smaller during the roll.
- The player can roll through low tunnels.
- If the player is inside a low tunnel, the roll state continues until the player exits instead of getting stuck.
- The player can jump out of roll.
- The player can roll in the air.

Current limitation:

- Roll is not yet connected to full invincibility frames or advanced enemy attack avoidance.

## Level Building: Doors

The prototype now has the first basic internal level door mechanic.

Current door behavior:

- Doors block the player while closed.
- When the player stands near a door, a `Press E` prompt appears.
- Pressing `E` opens a closed door.
- Pressing `E` near an opened door closes it again.
- Closed doors use a thin side-profile placeholder visual, matching the side-view Dead Cells reference.
- Opening the door switches it to a wider wooden-plank panel visual and disables its collision.
- The door collider matches only the thin closed-door profile, not the wider open panel.
- The door interaction area remains the same whether the door is open or closed.
- The open door panel is drawn behind the player so the player remains visible while passing through.
- The test playground background is drawn farther back, so opened door panels remain visible behind characters instead of disappearing behind the backdrop.
- Doors open away from the player. If the player opens the door from the left side, the door panel appears to the right. If opened from the right side, the panel appears to the left.
- Doors cannot close while the player is standing inside the doorway.
- If the doorway is blocked, the player receives a `Doorway blocked` feedback message.
- Doors can be smashed by weapon hits, thrown arms, or rolling into them while closed.
- Rolling through an opened door does not smash it.
- A smashed door hides its door visuals, disables collision and interaction, and spawns small non-recoverable wooden debris pieces.
- Smashed doors cannot be closed again.
- Thrown arms ignore non-damaging interaction areas, so they can pass through open doors and correctly hit closed doors instead of dropping on prompt triggers.

Current purpose:

- Begin building room-to-room flow inside an MVP level.
- Create a reusable foundation for future Dead Cells-inspired door interactions.

Future door improvements:

- Different door types can be added later, such as locked doors, heavy doors, shortcut doors, boss doors, or timed doors.

## Level Building: Graveyard Rooms

The project now has a first pass at an authored-room workflow for procedural level assembly.

Current room library:

- Start room
- Exit room
- Five combat rooms
- Two loot rooms

Current generation sequence:

- Start room
- Combat room
- Combat room
- Loot room
- Combat room
- Exit room

The start and exit rooms are fixed. Combat and loot rooms are chosen randomly from their room pools each time `GraveyardLevel.tscn` runs.

Current room assembly rules:

- Rooms are authored manually in separate scenes.
- The generator places room instances next to each other at runtime.
- Rooms are kept on the same vertical baseline so the level reads as one continuous route.
- Room contents keep their authored local positions when the room is moved.
- Duplicate player and camera nodes are removed from generated room instances so the level uses one main player and one main camera.

This is the first step toward a Dead Cells-inspired room-chain generator while still keeping room design hand-authored and controllable.

## Temporary 16px Scale Pass

The project now has scaled versions of key gameplay objects for the temporary 16x16 graveyard tileset.

Current scaled objects include:

- Player
- Thrown body parts
- Patrol enemy
- Door
- Ladder
- Sword pickup
- Shield pickup
- Axe pickup

The goal of this scale pass is to let the game be built around tile-sized rooms without breaking the older playground prototype.

Scaled weapon pickup behavior:

- The start room now includes sword, shield, and axe pickups.
- Sword and shield are usable immediately if the player has the required arm.
- Axe still requires the enemy arm because it is a heavy weapon.
- Swapping between scaled sword and axe pickups keeps dropped weapons scaled, instead of spawning the older large pickup scenes.

## Hazards

Spike tiles were added as the first tile-based hazard prototype.

Current spike behavior:

- Spike tiles use a separate physics layer from solid ground.
- The player can pass through spike tiles instead of treating them as walls.
- Touching spike tiles damages the player.
- Spike damage has a short cooldown so touching spikes does not drain all health instantly.

This allows ground, wall, and ceiling spike layouts to be built directly with the room tileset.

## Parallax Background

The graveyard level now has a temporary parallax background assembled from the imported graphics pack.

Current behavior:

- Multiple background layers are spawned behind the level.
- Layers move at different speeds relative to the camera.
- The moon is not repeated, avoiding the earlier duplicate-moon look.
- Background layers are scaled larger to better cover the camera view.

This is still temporary presentation work, but it makes the graveyard rooms easier to read and test.

## Enemy System

The current enemy is a simple patrol enemy.

Enemy behavior:

- Applies simple gravity when it has no ground underneath.
- If placed slightly above the ground or a platform, it falls until it lands.
- Patrol and attack logic waits until the enemy is grounded.
- Each enemy instance calculates its own patrol origin and left/right patrol limits from its placed position.
- Each copied enemy can optionally use personal patrol limits with `use_patrol_limits` and `patrol_distance` in the Inspector, but the default patrol behavior is environment-based.
- Each spawned enemy receives a random starting patrol direction.
- Each spawned enemy receives a small random patrol speed variation, so duplicated enemies feel slightly less identical.
- If an enemy falls to a different floor or platform and lands, it refreshes its personal patrol limits around the new landing position.
- Patrols left and right.
- Turns around at patrol limits only if `use_patrol_limits` is enabled for that enemy.
- Turns around when it detects an obstacle.
- Treats closed doors as obstacles, but ignores opened or smashed doors and can patrol through them during normal patrol.
- Checks its full body shape before moving horizontally, preventing it from passing through boxes, doors, or other solid level geometry if a simple ray check misses.
- Ignores other enemies during movement-blocking checks, so multiple patrol enemies can pass through each other instead of stopping or pushing each other around.
- Turns around when it detects there is no ground ahead, allowing duplicated enemies to patrol floating platforms without walking off the edge.
- Detects the player in front of it only when the player is roughly on the same floor/platform level.
- Uses a simple line-of-sight ray for detection, so closed doors and solid walls block enemy awareness.
- Each copied enemy can tune `same_level_detection_height` in the Inspector if a level needs a slightly taller or shorter detection band.
- Enters a prepare/windup state before attacking.
- Lunges toward the player.
- Attacks after the lunge.
- Can be stunned.

Enemy reaction improvements:

- If hit from behind, the enemy no longer ignores the player.
- A surviving enemy immediately turns toward the player and enters prepare/windup state.
- If the enemy is already stunned, damage does not cancel the stun.

## Combat Feel

Melee combat has simple attack phases:

- Startup
- Active hit window
- Recovery

The player is slowed during attacks.

Current attack philosophy:

- Sword is quick and light.
- Axe is slow, heavy, stronger, and stuns.
- Attacks are not just instant damage checks.
- Each attack has a small commitment period.

Damage numbers appear above enemies when they take damage.

## Player Feedback Messages

The prototype now has floating feedback messages for blocked actions.

These messages appear above the player and fade upward.

Current examples:

- `Need right arm` when trying to use a main-hand weapon without the right arm.
- `Need left arm` when trying to pick up a shield without the left arm.
- `Need enemy arm` when trying to pick up or swap to a heavy weapon like the axe without the enemy arm.
- `Enemy legs cannot detach` when pressing the leg sacrifice key while enemy legs are equipped.

This system replaces some debug-only `print()` messages with visible gameplay feedback, making body-part restrictions easier to understand during testing.

## Player Death

The player can now die when health reaches zero.

Current death behavior:

- The player does not disappear instantly.
- Controls are disabled.
- Collision is disabled.
- Active sword attacks, shield use, and roll state are stopped.
- Equipped weapon and shield UI are cleared.
- The assembled body is hidden.
- Currently attached body parts fall apart into separate ground pieces.
- Death pieces receive a small outward launch so the body reads as a loose pile of bones instead of overlapping in one spot.
- The result is a simple pile-of-bones death effect.

Death pieces are non-recoverable. This is intentional for the current prototype because the player is already dead.

Current limitation:

- There is no restart menu or respawn flow yet.
- Death is only a visual/gameplay stop state for now.

## Corpse And Body Part Collection

When an enemy dies:

- It leaves a corpse on the ground.
- The corpse is represented by a simple horizontal triangle.
- When the player approaches the corpse, a `Press E` prompt appears.
- Pressing `E` opens a simple body-part selection UI.

Current corpse options:

- Press `W` to choose enemy arm.
- Press `S` to choose enemy legs.

Current effects:

- Enemy arm replaces the right arm and turns it pink.
- Enemy legs replace both legs and turn them light blue.
- The corpse disappears after choosing a part.

## Current Controls

- `A`: move left
- `D`: move right
- `Space`: jump / climb up while on a ladder
- `Space` in air with enemy legs: double jump
- Release `Space` on ladder: slowly slide down
- `Shift`: roll
- `A/D + Shift` on ladder: roll off ladder
- `J`: attack with equipped main-hand weapon
- `K`: use shield
- `1`: throw left arm
- `2`: throw right arm
- `3`: sacrifice basic skeleton leg
- `5`: detach head
- `E`: interact / swap weapon / open corpse UI
- `W`: select enemy arm from corpse UI
- `S`: select enemy legs from corpse UI / climb down faster while on ladder

## Current Technical Direction

The project is still intentionally prototype-focused.

Current technical approach:

- Keep systems simple and readable.
- Use Godot 4 and GDScript.
- Use placeholder ColorRects instead of art assets.
- Add body part IDs and colors to prepare for scaling.
- Avoid building a full inventory system too early.
- Expand one mechanic at a time.

Important foundations already started:

- Body part identity
- Body part color/state tracking
- Recoverable thrown body parts
- Weapon weight categories
- Body-part-based equipment restrictions
- Corpse-based body part selection
- Authored room pools for procedural assembly
- 16px scaled object variants for tile-based level building
- Tile-based hazard layer support
- Basic parallax scene presentation

## Good Next Steps

Possible next small steps:

- Add UI feedback when the player cannot pick up a heavy weapon.
- Add a second enemy type with a different body part reward.
- Make corpse body part choices clickable or keyboard-highlighted.
- Add a simple hammer as another heavy weapon.
- Add a light weapon alternative to the sword.
- Add different stats for enemy arm beyond heavy weapon access.
- Add better enemy hit reactions.
- Add basic player damage/death feedback.
- Add a small HUD display showing current body part types.

## Current Design Pillars

The strongest current idea is:

The body is not just health or appearance. It is the character, the equipment system, and a sacrifice resource.

Current examples:

- Throwing an arm is powerful, but removes weapon or shield access.
- Enemy legs improve mobility, but remove leg sacrifice.
- Enemy arm unlocks heavy weapons.
- Heavy weapons hit harder, but require stronger body parts.

This is the core identity of the prototype and should guide future development.

## Long-Term Vision

Bonebound is not only a roguelike about collecting equipment. The long-term vision is a game about identity, adaptation, memory, and evolution.

The player's body should eventually function as:

- The character.
- The equipment system.
- A sacrifice resource.
- A progression system.
- A storytelling system.

These ideas are long-term design pillars, not immediate implementation goals. Current development should continue to prioritize simple prototypes, small iterations, MVP-first systems, and validating gameplay before building complex architecture.

## Long-Term Pillar: The World Remembers

One of the major future design pillars is:

`The world remembers previous runs.`

The player is not the first skeleton to wake up inside the Bone Tower. Many skeletons came before, and many failed. The current player is simply the newest iteration in a larger cycle.

Future direction:

- Every run may eventually leave traces behind.
- The world may slowly remember player habits.
- Death may eventually have consequences beyond a simple restart.
- The tower should feel like it remembers everyone who passed through it.

This system should not be built yet. For now, new mechanics should simply remain compatible with this future direction.

## Long-Term Pillar: Adaptive World

The world may eventually react to the player's habits.

Important design rule:

- The adaptive world should not punish mastery.
- It should encourage experimentation.
- It should keep runs fresh.
- It should make the world feel alive.

Bad example:

- The player rolls often.
- Rolling becomes useless.

Good example:

- The player rolls often.
- New enemy types appear that can punish careless rolls.
- Rolling remains useful.
- The player is encouraged to think more carefully.

The goal is not to invalidate builds. The goal is to make the world respond intelligently while preserving player agency.

This should remain a future system. Do not implement adaptive world logic until the core combat, body-part, enemy, and progression prototypes are stronger.

## Long-Term Pillar: Legacy Bosses

One of the most important future ideas is that previous versions of the player may eventually become enemies or bosses.

Concept:

- When the player dies, their build does not completely disappear.
- The world remembers it.
- A future run may contain an enemy or boss inspired by that previous character.

Example:

- Run 1 player uses sword, shield, and double-jump legs.
- The player dies.
- Several runs later, a boss appears with sword, shield, and double-jump-style movement.
- The player realizes this is not a random boss, but an echo of a previous character.

Design goals:

- Make each player's experience unique.
- Create stories that belong to that player.
- Connect runs together.
- Reinforce the idea that death has consequences.
- Support the lore of endless resurrection.
- Make the player feel like they are fighting the history of their own playthrough.

Design rules:

- Do not copy the player's build perfectly.
- Do not make bosses unfair.
- Use previous runs as inspiration, not exact simulations.
- Focus on recognizable traits.
- Make the player recognize themselves.

The emotional target is:

`Wait... this boss fights exactly how I used to fight.`

This is a long-term system. It should not be implemented during the current early prototype phase.

## Future Lore Direction

Current working lore concept:

The Bone Tower repeatedly resurrects skeletons. Each skeleton believes they are special. Eventually, they discover:

- Others came before.
- Others failed.
- Their predecessors still exist.
- The tower remembers everyone.

The player is part of a much larger cycle of resurrection, failure, adaptation, and memory.

## Long-Term Development Guidance

When developing future systems, keep these pillars in mind, but continue working in small practical steps.

Near-term priorities should remain:

- Core movement feel.
- Combat feel.
- Body-part tradeoffs.
- Weapon/body-part compatibility.
- Enemy behavior.
- Corpse rewards.
- Simple progression prototypes.
- Testable level design.

Do not build the Adaptive World system yet.

Do not build Legacy Bosses yet.

Instead, make current systems clean enough that these ideas can be supported later.

## Technical Notes

### Deferred Corpse Spawning

Enemy corpse spawning is deferred with `call_deferred()` when an enemy dies.

Reason:

- Enemies can die during physics collision callbacks, especially when hit by thrown body parts.
- The corpse scene contains an `Area2D`.
- Adding an `Area2D` immediately during a physics query can cause Godot's "Can't change this state while flushing queries" warning.
- Deferring the corpse add keeps gameplay behavior the same but avoids physics-server timing errors.
