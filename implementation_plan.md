# Implementation Plan for Cassinito

## Current State Analysis
The project has a solid foundation with `Deck`, `Hand`, and `Entity` (Player/CPU) logic implemented. The main game loop in `Cassino.gd` handles dealing and turn switching. However, the visual layer is disconnected from the data layer, and several key game mechanics are incomplete.

## Missing Components & Bugs

1.  **Card Visuals**: The `Card.tscn` scene lacks a script to update its sprite based on `CardData`. It currently shows a sample texture.
2.  **Entity Logic Bug**: `Entity.gd` calls `hand.remove_card()`, but `Hand.gd` defines `remove_card_from_hand()`.
3.  **Visual Feedback**: Selection highlighting is not implemented.
4.  **CPU Card Visibility**: CPU cards are spawned but not flipped face-down.
5.  **Build Visuals**: The logic to display builds (multiple cards stacked) is missing.
6.  **Ace Value Selection**: No UI exists to let the player choose between Ace value 1 and 14.
7.  **Scoring & Game Over**: The round ends with a print statement; no UI for score summary or restarting.

## Task List

### Phase 1: Core Fixes & Visuals
- [ ] **Fix `Entity.gd`**: Correct the method call to `hand.remove_card_from_hand`.
- [ ] **Create `Card.gd`**: Attach a script to `Card.tscn` to handle:
    - Setting texture region from `CardData`.
    - Toggling face-up/face-down state.
    - Highlighting (selection state).
- [ ] **Update `Cassino.gd`**:
    - Integrate `Card.gd` setup in `_spawn_hand_card` and `_spawn_table_card`.
    - Implement `_highlight_selection`.
    - Ensure CPU cards are face-down.

### Phase 2: Game Mechanics
- [ ] **Ace Value Logic**: Implement logic to handle Ace as 1 or 14 (likely auto-detect for capture, ask user for builds if ambiguous).
- [ ] **Build Implementation**:
    - Update `_rebuild_all_visuals` to recursively handle nested arrays for builds.
    - Visual representation for builds (offsetting cards).

### Phase 3: Polish & UI
- [ ] **Game Over Screen**: Create a UI to show final scores and offer a restart.
- [ ] **Animations**: Add tweening for card movements (deal, capture).
