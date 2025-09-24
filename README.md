# workspace-detector

<img width="324" height="219" alt="image" src="https://github.com/user-attachments/assets/2dc775c7-bc2b-486c-b6d0-b482f182d472" />


A command-line tool for analyzing Roblox .rbxm(x) model files to identify workspaces and detect hidden places embedded within them.

## Overview

This tool works to detect Roblox workspaces within .rbxm(x) model files, which could potentially contain stolen/lost places. It runs on the [Lune](https://github.com/lune-org/lune) runtime environment.

## Project Structure

- `detector.luau`: Main entrypoint
- `lib/cli.luau`: CLI argument parsing and usage
- `lib/core.luau`: Core detection logic (workspace scanning, file analysis)
- `lib/fileproc.luau`: File and directory processing
- `tests/`: Test models for validation
    - `containsworkspace/`: Models that should be detected as containing workspaces
    - `doesntcontainworkspace/`: Models that should NOT be detected as containing workspaces
    - `zlibCompressed/`: Models compressed with zlib
    - `binaryFiles/`: Binary or extensionless test files

## Installation

### Prerequisites

[Install the Lune runtime using rokit](https://lune-org.github.io/docs/getting-started/1-installation/)

### Setup

Clone or download this repository and ensure all required libraries are installed:

```bash
git clone https://github.com/filoxen/workspace-detector.git
cd workspace-detector
rokit install
```

## Usage

### Basic Usage

```bash
lune run detector path/to/your/model.rbxm(x)
```

### Options

#### Directory scan (recursive):

```bash
lune run detector.lua --directory /path/to/your/directory/with/models
```

#### Output list of files containing workspaces:

```bash
lune run detector.lua --output /path/to/your/output/file.txt
```

#### Process non-extensioned files (i.e no filetype extension / differing extension from .rbxm)

```bash
lune run detector.lua --force-binary-read /path/to/your/model.variantfile
```

#### Print all instance names while scanning:

```bash
lune run detector.lua --print-instance-names /path/to/your/model.rbxm
```

#### Decompress zlib-compressed files before scanning:

```bash
lune run detector.lua --zlib-decompress /path/to/your/model.rbxm
```

## Limitations

- Requires valid .rbxm files (corrupted/invalid/different versioned files may cause errors)

## Contributing

Contributions are welcome. Please ensure new features include documentation.

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

