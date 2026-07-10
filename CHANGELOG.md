# Changelog

All notable changes to GSE-CoA are documented in this file.

The project follows the versioning scheme:

* Minor releases: v2.1, v2.2, v2.3...
* Major architectural releases: v3.0, v4.0...

---

## [2.1] - 2026-07-10

### First Public Release

This is the first official public release of GSE-CoA.

### Highlights

#### Macro Engine

* Added CastSequence compatibility
* Added CastSequence reset support
* Added CastSequence syntax highlighting
* Added multi-condition parser
* Improved Blizzard macro compatibility
* Improved spell translation and normalization

#### Editor

* Complete editor rewrite
* Internal Sequence ID system
* Separate display names and internal IDs
* Support for spaces in sequence names
* Support for underscores in sequence names
* Improved syntax highlighting
* Create/Delete macro icon support

#### Architecture

* Rewritten sequence storage
* Improved macro lookup
* Nil sequence protection
* Parser improvements
* Improved long-term maintainability

#### Compatibility

* Designed specifically for Ascension: Conquest of Azeroth
* Improved compatibility with Conquest of Azeroth's custom class system
* Preserves Blizzard secure macro behavior wherever possible

### Credits

Based on work by:

* semlar
* TimothyLuke
* Gummed
* cerberus
* dmjohn0x

with continued development by the GSE-CoA community.