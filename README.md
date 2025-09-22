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
lune run detector path/to/your/model.rbxm
```

### Output Formats

Human-readable output (default):
```bash
lune run detector model.rbxm
```

JSON output for external use:
```bash
lune run detector.lua model.rbxm --format=json
```

### Batch Processing

Process multiple files:
```bash
lune run detector.lua *.rbxm --batch
```

## Limitations

- Requires valid .rbxm files (corrupted/invalid files may cause errors)

## Contributing

Contributions are welcome. Please ensure new features include documentation.
