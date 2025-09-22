# workspace-detector

A command-line tool for analyzing Roblox .rbxm model files to identify workspaces and detect hidden places embedded within them.

## Overview

This tool examines Roblox model files and provides detailed analysis of their structure, specifically focusing on workspace detection and identifying potentially hidden game places that may be embedded within model files. It runs on the [Lune](https://github.com/lune-org/lune) runtime environment.

## Installation

### Prerequisites

[Install the Lune runtime](https://lune-org.github.io/docs/getting-started/1-installation/)

### Setup

Clone or download this repository and ensure the main script is executable:

```bash
git clone https://github.com/filoxen/workspace-detector.git
cd workspace-detector
chmod +x detector.luau
```

## Usage

### Basic Usage

```bash
lune run detector path/to/your/model.rbxm(x)
```

### Options

#### Directory scan:

```bash
lune run detector.lua --directory /path/to/your/directory/with/models
```

#### Output list of files containing workspaces:

```bash
lune run detector.lua --output /path/to/your/output/file.txt
```



## Limitations

- Requires valid .rbxm files (corrupted/invalid/different versioned files may cause errors)

## Contributing

Contributions are welcome. Please ensure new features include documentation.
