# Project Anti-Hero

**Working title:** *Thronebound: Still He Returns*  
**Current prototype name:** Project Anti-Hero  
**Engine:** Godot 4  
**Genre:** 2D side-scrolling boss-room action prototype  
**Core idea:** You play as the final boss, not the hero.

---

## Project Overview

Project Anti-Hero is a 2D side-scrolling action prototype where the player controls the final boss seated in his throne room. A weak but determined Hero repeatedly enters the arena, dies, and returns stronger each time.

The central twist is that the player is not trying to become stronger like a traditional hero. The player begins as the strongest being in the room. The challenge comes from the Hero’s persistence, adaptation, and eventual ability to threaten what once seemed unbeatable.

The prototype is inspired by the “boss perspective” concept seen in games like *The Dark Queen of Mortholme*, but this project is being developed as its own original gameplay loop.

---

## Core Gameplay Loop

1. The Hero enters the throne room.
2. The Boss fights the Hero using powerful attacks.
3. The Hero dies.
4. The Hero returns stronger, faster, and more dangerous.
5. The Boss must defeat the Hero repeatedly before the Hero finally brings him down.
6. The game ends when:
   - The Hero defeats the Boss, or
   - The Boss breaks the Hero’s will after enough defeats.

---

## Current Prototype Features

The prototype currently includes:

- A playable Boss character
- A basic arena with floor and wall collision
- Boss movement
- Boss light attack
- Boss heavy attack
- Boss projectile attack
- Hero movement AI
- Hero auto-attack
- Hero death and respawn loop
- Hero scaling across attempts
- Boss health that persists across Hero attempts
- HUD showing combat and scaling stats
- Win/loss conditions
- Restart after game over
- Explicit targeting rules to prevent self-damage bugs

---

## Planned Working Title

The current favorite title for the eventual game/prototype is:

> **Thronebound: Still He Returns**

For now, the project and repository may continue using the development name **Project Anti-Hero** until the prototype reaches a branding/menu phase.

---

## Development Workflow

This project is being built phase by phase.

The current workflow is:

1. Plan each phase.
2. Use Claude to generate Godot/GDScript code.
3. Review the plan before implementing.
4. Implement in Godot 4.
5. Test the phase.
6. Commit to a dedicated Git branch.
7. Merge into `main` only after the phase works.

The `main` branch is treated as the latest stable version.

---

## Branching Strategy

Each new phase uses its own branch, for example:

```text
phase-12-boss-projectile
phase-13-combat-rules-cleanup
phase-14-hero-scaling-pass
phase-15-hero-adaptation-milestones
```

Once a phase works, it is committed, pushed, and merged into `main`.

---

# Prototype Roadmap

This roadmap is a rough draft of the 40 phases planned to reach a finished, playable prototype.

A “finished prototype” means an ugly-but-playable version that proves the core game loop. It does not require final art, final sound, or production polish.

---

## Foundation Phases

### Phase 0 — Setup Workflow

Set up the basic development workflow: install Godot, set up Claude for code generation, create the GitHub repository, establish folder structure, and begin using branches/checkpoints safely.

### Phase 1 — Placeholder Room

Create the first visible `Main.tscn` scene with placeholder nodes: Arena, Boss, Hero, Camera2D, floor, and walls. No real gameplay yet, just a visual layout.

### Phase 2 — Boss Movement + Physics Floor

Convert Boss into a `CharacterBody2D`, make the floor a `StaticBody2D`, add gravity, and allow the Boss to move left and right without falling through the floor.

### Phase 3 — Hero Physics Body + Boss Facing

Convert Hero into a `CharacterBody2D` with collision and gravity. Add basic Boss facing direction tracking so later attacks know which direction to appear.

---

## Core Combat Loop Phases

### Phase 4 — Boss Light Attack: Backhand Swipe

Add the Boss’s first attack: a short-range Backhand Swipe on `J`. Create a visible `Area2D` hitbox that damages the Hero.

### Phase 5 — Hero Death + Respawn Loop

Add Hero health, a death signal, GameManager respawn logic, attempt count, and basic Hero health scaling after each defeat.

### Phase 6 — Basic Hero AI Movement

Make the Hero walk toward the Boss automatically, stop near the Boss, and scale Hero movement speed slightly across attempts.

### Phase 7 — Hero Basic Attack + Boss Health

Give the Hero a basic auto-attack and give the Boss health. Boss HP persists across Hero attempts so the Hero can slowly chip away at the Boss over repeated runs.

### Phase 8 — Basic HUD

Add simple on-screen HUD labels for Boss HP, Hero HP, attempt number, and Hero speed. Later fixes also ensure Hero/Boss attacks do not damage themselves.

### Phase 9 — Arena Wall Colliders

Convert left and right wall placeholders into `StaticBody2D` colliders so the Boss and Hero cannot leave the arena.

### Phase 10 — Win/Loss Conditions + Restart

Add game-over rules: Hero wins if Boss HP reaches 0, Boss wins if Hero is defeated enough times. Show result text and allow restarting with `R`.

### Phase 11 — Boss Heavy Attack: Ground Slam

Add the Boss’s second attack: Ground Slam on `K`. It has a larger hitbox, higher damage, a visible warning/windup, and a cooldown.

### Phase 12 — Boss Dark Projectile

Add the Boss’s ranged attack on `L`. Create a separate Projectile scene that travels horizontally, damages Hero on contact, and disappears on hit, wall contact, or timeout.

### Phase 13 — Combat Rules Cleanup

Make all combat targeting explicit and safe: Boss attacks only damage Hero, Hero attacks only damage Boss, projectile only damages Hero, and no self-damage occurs.

### Phase 14 — Hero Scaling Pass

Make Hero scaling more intentional. Scale health, speed, attack damage, and attack cooldown across attempts, with speed caps and milestone-based damage/cooldown tiers.

---

## Hero Adaptation Phases

### Phase 15 — Hero Adaptation Milestones

Add milestone messages so the Hero’s growth feels intentional. At key attempts, show short adaptation text such as “The Hero studies your rhythm.”

### Phase 16 — Hero Lunge Attack

Add the Hero’s first new learned behavior: a lunge attack unlocked after enough attempts. It lets the Hero threaten the Boss from slightly farther away.

### Phase 17 — Hero Dodge / Backstep

Add a simple defensive movement behavior. The Hero occasionally backsteps or retreats, making him feel less like a simple walking target.

---

## Boss Power Expansion Phases

### Phase 18 — Boss Special Arena Ability

Add a dramatic Boss ability such as floor spikes, shadow chains, or throne magic. It should use a warning marker, delay, and area damage.

### Phase 19 — Overwhelm Meter

Add a Boss resource meter that builds when the Boss successfully hits or dominates the Hero. Show it on the HUD and use it to unlock a powerful payoff move.

### Phase 20 — Execution Attack

Add a high-impact Boss attack that spends the Overwhelm meter. It should feel like a final-boss finisher: large, dramatic, high damage, and limited by the meter.

### Phase 21 — Balance Pass 1

Tune the actual numbers: Boss HP, Hero HP scaling, Hero speed, Hero damage, Hero cooldowns, Boss attack damage, projectile cooldowns, and the defeat limit.

---

## Game Feel and Readability Phases

### Phase 22 — Hit Flash

Add simple visual feedback when either character takes damage. Hero and Boss briefly flash or change color so hits are easier to read.

### Phase 23 — Attack Telegraph Cleanup

Improve readability of attacks. Make warning boxes, attack flashes, and active hitboxes clearer so the player understands what is about to happen and what caused damage.

### Phase 24 — Hit Pause / Impact Freeze

Add a very short freeze or pause on successful hits to make attacks feel more impactful and powerful without needing full animations.

### Phase 25 — Screen Shake

Add camera shake for heavy attacks and major impacts. Ground Slam and big attacks should feel more powerful than basic hits.

### Phase 26 — Placeholder Animations

Add simple rectangle/sprite motion polish: squash/stretch, attack lean, flickers, respawn flash, or basic movement animation. Still no final art required.

---

## Presentation and Game Structure Phases

### Phase 27 — Start Screen

Add a basic start screen with the working title, a start prompt, and control instructions. This makes the prototype feel like a real game instead of launching directly into combat.

### Phase 28 — Pause / Restart Controls

Add a pause state and improve restart behavior. `Esc` can pause, `R` can restart, and controls should be clearer and safer during playtesting.

### Phase 29 — Better Game Over Screen

Improve the result screen. Show final attempt count, Boss HP remaining, who won, and a restart instruction in a more readable layout.

### Phase 30 — Prototype Tutorial Text

Add short tutorial text or opening instructions: explain that the player is the final boss, the Hero returns stronger, and the Boss must break the Hero’s will before being defeated.

---

## Narrative and Flavor Phases

### Phase 31 — Hero Death Dialogue

Add short Hero dialogue lines after deaths. These lines should show the Hero learning, refusing to give up, and slowly becoming more threatening.

### Phase 32 — Boss Dialogue / Taunts

Add Boss taunts or reactions, especially after Hero deaths or milestone attempts. This helps sell the boss perspective and the emotional shift from arrogance to unease.

### Phase 33 — Attempt Milestone Messages

Expand milestone messaging beyond stats. Clearly show when the Hero learns something new, becomes more aggressive, unlocks lunge, or refuses to break.

---

## Audio, Art, Export, and Final QA Phases

### Phase 34 — Placeholder Sound Effects

Add simple sound effects for attacks, hits, deaths, respawn, game over, and restart. Placeholder audio is fine; the goal is feedback.

### Phase 35 — Placeholder Music

Add looping battle music. Optionally increase intensity at later attempts or after key milestones.

### Phase 36 — Placeholder Art Upgrade

Replace plain rectangles with simple readable silhouettes or placeholder sprites for the Boss, Hero, throne room, attacks, and arena.

### Phase 37 — Export Build

Create a playable exported Windows build. Test the game outside the Godot editor and confirm that inputs, scenes, scripts, restart, and assets work.

### Phase 38 — Prototype QA Pass

Do a full bug pass. Verify both win conditions, restart, attack targeting, wall collisions, respawn timing, HUD updates, game-over freeze, and projectile cleanup.

### Phase 39 — Final Balance Pass

Tune the game for fun and pacing. Decide whether the Hero is too weak or too strong, whether 15 deaths feels right, and whether the Boss’s tools are satisfying.

### Phase 40 — Finished Prototype Milestone

Package the completed prototype milestone. It should include the playable arena, Boss attacks, Hero adaptation, HUD, win/loss, restart, basic feedback, dialogue/flavor, and an exportable build.

---

## Suggested Milestone Targets

### Essential Mechanics Prototype

Complete through **Phase 21**.

This should prove the full combat and scaling loop.

### Presentable Prototype

Complete through **Phase 30**.

This should feel understandable to someone opening the project for the first time.

### Finished-Enough-to-Show Prototype

Complete through **Phase 40**.

This should be playable, readable, testable, and exportable.

---

## Current Development Status

As of the current roadmap, the project has reached:

```text
Stable through Phase 14
```

Next planned phase:

```text
Phase 15 — Hero Adaptation Milestones
```

---

## Controls

Current prototype controls:

```text
A / Left Arrow  — Move Boss left
D / Right Arrow — Move Boss right
J               — Boss Backhand Swipe
K               — Boss Ground Slam
L               — Boss Dark Projectile
R               — Restart after game over
```

---

## Notes

This repository is a learning-focused prototype built step by step in Godot 4.

The goal is not to start with perfect architecture. The goal is to build a working game loop, learn Godot safely, keep stable Git checkpoints, and gradually refactor only when the project needs it.
