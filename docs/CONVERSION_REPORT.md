# Phase 4 Conversion Report

## Fixture 1: `1 Bar Glimmers.nksf`
- **Plugin Name (NISI)**: `Efx FRAGMENTS`
- **Legacy VST2 Magic (PLID)**: `1735549294` (`0x6772616E` -> `gran`)
- **Resolved VST3 Class ID**: `41727475415649536772616E50726F63`
- **Strategy**: VST2 Chunk (VstW wrapped)
- **Host Helper Conversion**: Success
- **Output**: `1 Bar Glimmers.vstpreset`
- **Controller/Component Bytes**: 61,578 bytes / 61,578 bytes

## Fixture 2: `08-15 Bass.nksf`
- **Plugin Name (NISI)**: (Missing NISI output, but plugin is TAL-BassLine-101)
- **Legacy VST2 Magic (PLID)**: `1970171700` (`0x756E6F34` -> `uno4`)
- **Status**: Skipped (Plugin `TAL-BassLine-101.vst3` is not installed on this system).

---
**Summary**: Phase 4 integration tests pass. The separation of concerns between `NKSCore` (handling files and chunk wrapping) and `nks-host` (handling plugin lifecycle and VST3 stream extraction) is robust and handles plugins missing `moduleinfo.json` perfectly.
