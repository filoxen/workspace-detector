# workspace-detector

<img width="324" height="219" alt="image" src="https://github.com/user-attachments/assets/2dc775c7-bc2b-486c-b6d0-b482f182d472" />


A command-line tool for analyzing Roblox .rbxm(x) model files to identify workspaces and detect hidden places embedded within them.

## Overview

This tool works to detect Roblox workspaces within .rbxm(x) model files, which could potentially contain stolen/lost places. It runs on the [Lune](https://github.com/lune-org/lune) runtime environment.

## Project Structure

```
lib/
├─ fileproc.luau           : File and directory processing
├─ cli.luau                : CLI argument parsing and usage
├─ core.luau               : Core detection logic (workspace scanning, etc)
tests/
├─ containsworkspace/      : Test cases that should contain workspaces
├─ doesntcontainworkspace/ : Test cases that shouldn't contain workspaces
├─ zlibCompressed/         : Zlib compressed test casees
├─ binaryFiles/            : Extensionless/binary test cases
├─ tests.luau              : Test runner for CI
detector.luau              : Main entrypoint
```

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
lune run detector --directory /path/to/your/directory/with/models
```

#### Output list of files containing workspaces:

```bash
lune run detector --output /path/to/your/output/file.txt
```

#### Process non-extensioned files (i.e no filetype extension / differing extension from .rbxm)

```bash
lune run detector --force-binary-read /path/to/your/model.variantfile
```

#### Print all instance names while scanning:

```bash
lune run detector --print-instance-names /path/to/your/model.rbxm
```

#### Decompress zlib-compressed files before scanning:

```bash
lune run detector --zlib-decompress /path/to/your/model.rbxm
```

##### Recursively decompress zlib
```bash
lune run detector --zlib-decompress-recursive /path/to/your/model.rbxm
```

## Limitations

- Requires valid .rbxm files (corrupted/invalid/different versioned files may cause errors)

## Contributing

Contributions are welcome. Please ensure new features include documentation. Follow existing code style to the best of your ability and try not to make breaking changes.

When adding new core functions that operate on files, please follow the existing convention:

```luau
(fileContents: string, opts: types.opts) -> string | boolean
```

This is for writing working tests. To write a new test, follow the example in `tests.luau`:

```luau
-- folderName should be the name of a folder of .rbxm(x) files in ./tests
local yourTest = testFolder(yourFunction: (fileContents: string, opts: types.opts) -> string | boolean, yourFunctionsOpt: types.opts, folderName: string)

for fileName, result in pairs(yourTest) do
    if result then
        print(`Test failed: {fileName} yourReason`)
        process.exit(1)
    end
end
print("All tests passed for files in yourFolderName.")
```

When you add a new option (via a command line flag), add it to `./lib/types.luau`, following the existing conventions.
When you add a new function to any library, add it to the function's type. If you add a new library, define a type for it and type cast the module to it:
```luau
export type YourModule = {
    yourFunction: (...) -> unknown,
}
-- note the camel case vs pascal case
local yourModule = {} :: YourModule
```

## License

Copyright (C) 2025 Filoxen Labs

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

