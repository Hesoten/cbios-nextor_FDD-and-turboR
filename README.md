# cbios-nextor_FDD-and-turboR

Integration project that builds MSX 2 / 2+ / turbo R environments for
blueMSX and openMSX from:

- [C-BIOS with turbo R and Nextor disk-boot patches](https://github.com/Hesoten/cbios)
  (branch `feature/nextor-turbor`).
- [Nextor with C-BIOS compatibility patches](https://github.com/Hesoten/Nextor)
  (branch `feature/cbios-tc8566af`).
- A drive-based TC8566AF FDC driver (`driver/tc8566af.mac`) that plugs into
  the Nextor kernel via `mknexrom`, producing `nextor-tc8566af.rom`.

For each stock C-BIOS 2 / 2+ machine (which ships without FDD) the build
produces two variants: a plain non-FDD build that swaps in the patched
C-BIOS ROMs and an FDD build that additionally drops
`nextor-tc8566af.rom` into slot 3.3. The turbo R config gets the same
two variants.

## Known issues / limitations

- **`C-BIOS FDD` configs cannot host a MegaFlashROM SCC+ SD (MFRSD)
  simultaneously.** MFRSD ships its own Nextor kernel that becomes the
  disk master and clashes with the built-in Nextor + TC8566AF slave
  registration path. Use the plain non-FDD variant of the same machine
  when you want MFRSD.

## Machines produced

18 machines, one per config in `configs/blueMSX/Machines/` and
`configs/openMSX/machines/`:

| Machine                        | Video / Board  | Notes                                |
|--------------------------------|----------------|--------------------------------------|
| MSX2 - C-BIOS                  | V9938 / S1985  | international main ROM               |
| MSX2 - C-BIOS - BR             | V9938 / S1985  | Brazilian main ROM                   |
| MSX2 - C-BIOS - EU             | V9938 / S1985  | European main ROM                    |
| MSX2 - C-BIOS - JP             | V9938 / S1985  | JP main ROM + KANJI                  |
| MSX2 - C-BIOS FDD              | V9938 / S1985  | international main ROM + FDD         |
| MSX2 - C-BIOS FDD - BR         | V9938 / S1985  | Brazilian main ROM + FDD             |
| MSX2 - C-BIOS FDD - EU         | V9938 / S1985  | European main ROM + FDD              |
| MSX2 - C-BIOS FDD - JP         | V9938 / S1985  | JP main ROM + KANJI + FDD            |
| MSX2+ - C-BIOS                 | V9958 / T9769B | + MSX-MUSIC                          |
| MSX2+ - C-BIOS - BR            | V9958 / T9769B | + MSX-MUSIC                          |
| MSX2+ - C-BIOS - EU            | V9958 / T9769B | + MSX-MUSIC                          |
| MSX2+ - C-BIOS - JP            | V9958 / T9769B | + MSX-MUSIC + KANJI                  |
| MSX2+ - C-BIOS FDD             | V9958 / T9769B | + MSX-MUSIC + FDD                    |
| MSX2+ - C-BIOS FDD - BR        | V9958 / T9769B | + MSX-MUSIC + FDD                    |
| MSX2+ - C-BIOS FDD - EU        | V9958 / T9769B | + MSX-MUSIC + FDD                    |
| MSX2+ - C-BIOS FDD - JP        | V9958 / T9769B | + MSX-MUSIC + KANJI + FDD            |
| MSXturboR - C-BIOS             | V9958 / T9769C | R800 + MSX-MUSIC + KANJI             |
| MSXturboR - C-BIOS FDD         | V9958 / T9769C | R800 + MSX-MUSIC + KANJI + FDD       |

## Layout

```
cbios/                             git submodule, Hesoten/cbios
nextor/                            git submodule, Hesoten/Nextor
driver/tc8566af.mac                TC8566AF FDC driver
driver/build.sh                    Assembles driver + Nextor kernel into a ROM
configs/blueMSX/Machines/...       blueMSX machine configurations
configs/openMSX/machines/...       openMSX machine configurations
LICENSES/cbios.txt                 C-BIOS notice + license (as shipped)
LICENSES/LICENSE-Nextor.md         Nextor license (verbatim from upstream)
LICENSES/LICENSE-KANJI.txt         KANJI.rom license (jiskan16 / Sony / A to C)
```

## Building locally

Prerequisites:

- Pasmo (to build the C-BIOS main / sub / logo / music ROMs).
- N80 / mknexrom from
  [Nestor80 and the Nextor tools](https://github.com/Konamiman/Nestor80)
  on `$PATH` or in `~/nextor-tools/`.
- GNU Make.

```
git clone --recursive https://github.com/Hesoten/cbios-nextor_FDD-and-turboR
cd cbios-nextor_FDD-and-turboR

# C-BIOS ROMs (every main variant plus shared sub / logo / music)
make -C cbios \
  derived/bin/cbios_main_msx2.rom     derived/bin/cbios_main_msx2_br.rom \
  derived/bin/cbios_main_msx2_eu.rom  derived/bin/cbios_main_msx2_jp.rom \
  derived/bin/cbios_main_msx2+.rom    derived/bin/cbios_main_msx2+_br.rom \
  derived/bin/cbios_main_msx2+_eu.rom derived/bin/cbios_main_msx2+_jp.rom \
  derived/bin/cbios_main_msxtr_jp.rom \
  derived/bin/cbios_sub.rom \
  derived/bin/cbios_logo_msx2.rom     derived/bin/cbios_logo_msx2+.rom \
  derived/bin/cbios_music.rom

# Nextor kernel base
make -C nextor/source/kernel base

# Combine kernel + driver
./driver/build.sh
```

The Nextor + driver ROM lands at `bin/nextor-tc8566af.rom`.

## Deploying to blueMSX

For each machine, copy the referenced C-BIOS ROMs and (for FDD variants)
`bin/nextor-tc8566af.rom` next to that machine's `config.ini` under
`configs/blueMSX/Machines/<machine>/`, then drop the whole `<machine>/`
directory into blueMSX's `Machines/`.  The JP variants and the turbo R
configs also use the bundled `Machines/Shared Roms/KANJI.rom`; copy it
to the same path under blueMSX's `Machines/`.

## Deploying to openMSX

Copy the XML files from `configs/openMSX/machines/` and the built
C-BIOS ROMs plus `nextor-tc8566af.rom` all into `share/machines/`
under openMSX's system or user directory (openMSX resolves filenames
referenced by a machine XML relative to that XML's own directory).
Copy the bundled `KANJI.rom` into `share/systemroms/` (the openMSX ROM
pool); the MSX2+ JP and turbo R machine XMLs reference it by SHA-1,
which the pool resolves regardless of file name.

## Licenses

- C-BIOS: see [`LICENSES/cbios.txt`](LICENSES/cbios.txt).
- Nextor: see [`LICENSES/LICENSE-Nextor.md`](LICENSES/LICENSE-Nextor.md).
- KANJI.rom: see [`LICENSES/LICENSE-KANJI.txt`](LICENSES/LICENSE-KANJI.txt).
- TC8566AF driver (`driver/tc8566af.mac`) and integration code: BSD 3-clause
  unless a source file states otherwise; see
  [`LICENSES/LICENSE-TC8566AF.txt`](LICENSES/LICENSE-TC8566AF.txt).

## Acknowledgments

Many thanks to the C-BIOS project — BouKiCHi, Reikan, Maarten ter Huurne,
Albert Beevendorp, Patrick van Arkel, Manuel Bilderbeek, Joost Yervante
Damad, Jussi Pitkänen, Eric Boon, and the other contributors — for
developing such an excellent compatible BIOS and releasing it in freely
redistributable form.

Many thanks to Nestor Soriano Vilchez (Konamiman) for creating Nextor and
continuing to improve it, and for releasing the source code in a form that
allows downstream projects like this one to exist.

Many thanks to A to C for creating the "Kanji ROM image file for msx
emulaters" bundled here as `KANJI.rom`, a freely redistributable Kanji
font ROM built from the public-domain jiskan16 font plus hand-drawn
MSX-specific glyphs (see
[`LICENSES/LICENSE-KANJI.txt`](LICENSES/LICENSE-KANJI.txt)).

## Disclaimer

This project and every artifact it produces is **AS-IS** software with
**no warranty** that it will always operate correctly. **Neither the
authors of this project nor the original C-BIOS / Nextor authors and
contributors accept any liability for damages of any kind (including
but not limited to data loss, hardware damage, or financial loss)
arising from the use of this software.**
