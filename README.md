# GSE-CoA

GSE-CoA is a community-maintained version of Gnome Sequencer Enhanced designed specifically for **Ascension: Conquest of Azeroth**.

The project adapts and extends the WoW 3.3.5a version of GSE while preserving Blizzard macro compatibility wherever practical and improving long-term stability, maintainability, and Conquest of Azeroth support.

---

# Current Release

**Current Version:** **v2.2**

Latest release:

https://github.com/Neindao/gse-coa/releases/latest

---

# Features

## Macro Engine

- Execute advanced macro sequences from a single action bar button
- Blizzard-compatible macro behavior
- CastSequence compatibility
- Multi-condition macro parsing
- KeyPress and KeyRelease support
- Improved spell translation
- Improved syntax highlighting

---

## Sequence Management

- Create sequences
- Edit sequences
- Delete sequences
- True sequence rename
- Rename before first save
- Stable internal sequence identity
- Preserve macro bindings after rename

---

## Macro Management

- Create Blizzard macros
- Delete Blizzard macros
- Dynamic macro icons
- Preserve macro icons after rename
- Improved macro lookup

---

## Editor

- Improved sequence editor
- Space support
- Underscore support
- `/startattack` condition highlighting
- Multi-condition parsing
- Better validation

---

## Architecture

GSE-CoA focuses on long-term maintainability.

Major architectural improvements include:

- Internal Sequence IDs
- Display Name / Internal ID separation
- Storage rewrite
- Improved macro lookup
- Rename integrity
- Cleaner macro reference handling

---

# Roadmap

Current priorities:

- UI polish
- CoA build/profile detection
- Spell translation improvements
- Additional syntax highlighting improvements
- Future custom condition framework

---

# Installation

1. Download the latest release.
2. Extract the archive.
3. Copy the following folders into your WoW `Interface/AddOns` directory:

```
GSE
GSE_GUI
GSE_LDB
```

4. Restart World of Warcraft.

---

# Compatibility

- World of Warcraft 3.3.5a
- Ascension: Conquest of Azeroth

---

# Project Philosophy

GSE-CoA aims to remain compatible with upstream GSE whenever practical while improving compatibility with Conquest of Azeroth.

The project prioritizes:

- Clean architecture
- Long-term maintainability
- Stable behavior
- Backwards compatibility
- Root-cause fixes over workarounds

---

# Issues

If you encounter a bug, please create a GitHub Issue describing:

- What happened
- Expected behavior
- Steps to reproduce
- Screenshots or Lua errors if available

---

# Credits

- TimothyLuke — Original GSE project
- Ascension Community
- Conquest of Azeroth Community
- Everyone who reports bugs and helps test GSE-CoA
