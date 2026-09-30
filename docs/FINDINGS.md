# Findings

## Phase 1 (Core Parsing)
* NKSF is a RIFF container with form type `NIKS`.
* The `PLID` chunk contains a MessagePack map identifying the plugin (`VST.magic` or `VST3.uid`).
* The `NISI` chunk contains a MessagePack map with preset metadata.
* `PCHK` contains raw state bytes.
* Swift's `Data` slicing retains original indices. We must use `.dropFirst(N)` or re-initialize `Data` to avoid out-of-bounds crashes when indexing slices.
* All unit tests for parsing RIFF, MessagePack, NKSF, and reading `.vstpreset` have passed.
* Next step requires real `.nksf` fixtures to verify the parser handles them correctly before proceeding to Scanner and Matching.

## Phase 2 (Scanner and Matching)
* Scanner iterates over `/Library/Audio/Plug-Ins/VST3` and user library successfully.
* `moduleinfo.json` parsing strips comments and trailing commas as expected.
* Endianness handling is crucial for reading `Mach-O` headers properly; thin binaries can be read differently on an arm64 host, but checking for `0xfeedfacf` little-endian magic works consistently across architectures on macOS.
* The matching algorithm successfully parses VST2 magic from the fixture `08-15 Bass.nksf` and translates it.
* Tested the `08-15 Bass.nksf` fixture against local plugins: the matcher correctly yielded 0 matches because the required plugin (TAL-U-No-LX-V2) is not installed on this system.
* The latest stable SDK release `v3.8.1_build_84` was cloned with submodules successfully.
* SDK License: Steinberg VST3 SDK is dual-licensed (Proprietary / GPLv3). We will note the proprietary license usage in the README.
* Arturia plugins (e.g. `Efx FRAGMENTS`) do not provide a `moduleinfo.json`, requiring `nks-host scan` to extract the `ClassInfo`.
* Arturia VST3 Class IDs embed the legacy VST2 magic inside a custom UID string. For example, `Efx FRAGMENTS` has magic `gran` (`0x6772616E`), and its VST3 Class ID is `41727475415649536772616E50726F63` (`ArtuAVISgranProc`). This confirms that relying on the C++ helper is mandatory for plugins that do not follow the strict `565354...` legacy format and don't provide a `moduleinfo.json` compatibility table.
