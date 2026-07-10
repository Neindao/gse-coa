# GSE-CoA

GSE-CoA is a community-maintained version of Gnome Sequencer Enhanced designed specifically for **Ascension: Conquest of Azeroth**.

The project adapts and extends the WoW 3.3.5a version of GSE with improved macro compatibility, a redesigned sequence editor, safer internal storage, and support for Conquest of Azeroth's custom class and gameplay systems.

## Current Release

**GSE-CoA v2.1**

This is the first official public release under the GSE-CoA versioning system.

## Features

### Macro Engine

* Advanced macro sequences executed through a single action-bar button
* Improved Blizzard macro compatibility
* Multi-condition macro parsing
* CastSequence support
* CastSequence reset conditions
* KeyPress command preservation
* Improved spell translation
* Improved spell normalization
* CastSequence syntax highlighting

### Sequence Editor

* Create, edit, save, and delete sequences
* Redesigned sequence editor
* Separate internal sequence IDs and display names
* Sequence names containing spaces
* Sequence names containing underscores
* Create and delete macro icons
* Improved syntax highlighting
* Improved sequence-name handling

### Architecture and Reliability

* Internal sequence ID system
* Rewritten sequence storage
* Improved macro lookup
* Nil sequence protection
* Improved parser architecture
* Ascension: Conquest of Azeroth compatibility fixes

## Installation

1. Download the latest release ZIP from the GitHub **Releases** page.
2. Close World of Warcraft.
3. Extract the ZIP.
4. Copy these three folders into your WoW addon directory:

```text
World of Warcraft/
??? Interface/
    ??? AddOns/
        ??? GSE/
        ??? GSE_GUI/
        ??? GSE_LDB/
```

5. Start Ascension.
6. Enable all three GSE addons on the character-selection addon screen.
7. Enter the game and type:

```text
/gse
```

Do not place an additional wrapper folder around `GSE`, `GSE_GUI`, and `GSE_LDB`.

Correct:

```text
Interface/AddOns/GSE
Interface/AddOns/GSE_GUI
Interface/AddOns/GSE_LDB
```

Incorrect:

```text
Interface/AddOns/GSE-CoA-v2.1/GSE
```

## Basic Usage

Open the sequence editor:

```text
/gse
```

Create a sequence:

1. Open GSE.
2. Create a new sequence.
3. Enter a sequence name.
4. Select the appropriate Conquest of Azeroth class or configuration.
5. Add macro commands to the sequence.
6. Save the sequence.
7. Create its macro icon.
8. Drag the icon to an action bar.
9. Press the action-bar button repeatedly to advance the sequence.

Ascension: Conquest of Azeroth uses 21 custom classes. GSE-CoA is being developed specifically around those classes and their custom abilities, mechanics, and profiles.

## CastSequence Support

GSE-CoA includes compatibility improvements for Blizzard-style `/castsequence` commands.

Example:

```text
/castsequence reset=target/combat Spell One, Spell Two, Spell Three
```

Supported reset syntax includes Blizzard-style reset values such as:

```text
reset=target
reset=combat
reset=5
reset=target/combat
```

CastSequence behavior remains subject to World of Warcraft's secure execution rules and the behavior exposed by the Ascension client.

## Project Philosophy

GSE-CoA is designed specifically for Ascension: Conquest of Azeroth.

Development priorities are:

* Match Blizzard macro behavior wherever practical
* Support Conquest of Azeroth's 21 custom classes
* Prefer architectural fixes over temporary workarounds
* Build reusable systems instead of isolated fixes
* Preserve existing functionality unless a behavioral change is intentional
* Design for long-term maintainability
* Reduce technical debt through clean architecture
* Respect World of Warcraft's secure execution model

Upstream GSE improvements may be adopted when useful, but source compatibility with current upstream GSE is not a primary goal.

## Compatibility

GSE-CoA is intended for:

* Ascension: Conquest of Azeroth
* Conquest of Azeroth's 21 custom classes
* Ascension's customized WoW 3.3.5a client

It is not intended as a replacement for the current Retail, Classic, or other officially supported versions of GSE.

Compatibility with other Ascension realms or unrelated private servers is not guaranteed.

## Reporting Issues

Before reporting an issue:

1. Confirm that all three addon folders are installed.
2. Confirm that the issue occurs with the latest GSE-CoA release.
3. Reload the UI and reproduce the problem.
4. Record any Lua error shown.
5. Include the affected sequence or macro text.
6. Include the Conquest of Azeroth class being used.
7. Describe the exact expected and actual behavior.

Report reproducible problems through the repository's GitHub Issues page.

Please do not request GSE-CoA support from the original GSE maintainers or unrelated Ascension addon communities.

## Versioning

GSE-CoA uses the following version format:

```text
v2.1
v2.2
v2.3
```

Normal feature and compatibility releases increment the minor version.

Major architectural milestones may increment the major version:

```text
v3.0
v4.0
```

The earlier internal v7.x numbering has been retired and is not part of the public GSE-CoA release history.

## Credits

GSE-CoA exists because of the work of the projects and developers that came before it.

* **semlar** — creator of the original GnomeSequencer concept
* **TimothyLuke** — original author and maintainer of Gnome Sequencer Enhanced
* **Gummed** — WoW 3.3.5a/WotLK backport
* **cerberus** — revival and fixes for the WotLK backport
* **dmjohn0x** — Project Ascension adaptation
* **GSE-CoA contributors** — Conquest of Azeroth architecture, compatibility, editor, parser, translation, and macro-engine improvements

Related projects:

* Original GSE: https://github.com/TimothyLuke/GSE-Advanced-Macro-Compiler
* WotLK revival: https://github.com/cerberuscx/GSE-WotLK-3.3.5a
* Ascension adaptation: https://github.com/dmjohn0x/GSE-Ascension

GSE-CoA is an independent community project and is not affiliated with or endorsed by Blizzard Entertainment or Project Ascension.

## License

GSE-CoA is distributed under the MIT License.

See [LICENSE](LICENSE) for the complete license text.