# Github Release


## Semantic Release

```yaml

name: Release

on:
  workflow_dispatch:
  push:
    branches:
      - main

jobs:
  create-release:
    name: Release
    runs-on: ubuntu-latest
    outputs:
      new_release_version: ${{ steps.get-version.outputs.new_release_version }}
      new_release_published: ${{ steps.get-version.outputs.new_release_published }}
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          persist-credentials: false
          fetch-depth: 0
      - name: Release
        uses: cycjimmy/semantic-release-action@v3
        id: get-version
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
