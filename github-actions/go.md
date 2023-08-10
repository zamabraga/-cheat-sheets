# Build e Deploy de aplicativos em GO

Exemplo de um workflow para realizar o build do solução em go e publicar os artefatos na release, utilizando semantic release e gerando artefador para diferentes OS


.releaserc.json
```json 
{
  "branches": [
    "main"
  ],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/github"
  ]
}
```


```yaml
# This workflow will build a golang project
# For more information see: https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-go

name: Build

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
  build:
    if: needs.create-release.outputs.new_release_published == 'true'
    needs:
      - create-release
    name: Build for ${{ matrix.goos }}_${{ matrix.goarch }}
    uses: ./.github/workflows/build-dist.yml
    with:
      goarch: ${{ matrix.goarch }}
      goos: ${{ matrix.goos }}
      go-version: "1.20"
      package-name: "dscan"
      product-version: "${{needs.create-release.outputs.new_release_version}}"
      ld-flags: "-X 'main.Version=v${{needs.create-release.outputs.new_release_version}}'"
      cgo-enabled: ${{ matrix.cgo-enabled }}
      runson: ${{ matrix.runson }}
    secrets: inherit
    strategy:
      matrix:
        include:
          - {
              goos: "freebsd",
              goarch: "386",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "freebsd",
              goarch: "amd64",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "freebsd",
              goarch: "arm",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "linux",
              goarch: "386",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "linux",
              goarch: "amd64",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "linux",
              goarch: "arm",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "linux",
              goarch: "arm64",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "openbsd",
              goarch: "386",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "openbsd",
              goarch: "amd64",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "solaris",
              goarch: "amd64",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "windows",
              goarch: "386",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "windows",
              goarch: "amd64",
              runson: "ubuntu-latest",
              cgo-enabled: "0",
            }
          - {
              goos: "darwin",
              goarch: "amd64",
              runson: "macos-latest",
              cgo-enabled: "1",
            }
          - {
              goos: "darwin",
              goarch: "arm64",
              runson: "macos-latest",
              cgo-enabled: "1",
            }
      fail-fast: false

```



```yaml 
name: build_go

# This workflow is intended to be called by the build workflow. The crt make
# targets that are utilized automatically determine build metadata and
# handle building and packing Terraform.

on:
  workflow_call:
    inputs:
      cgo-enabled:
        type: string
        default: 0
        required: true
      goos:
        required: true
        type: string
      goarch:
        required: true
        type: string
      go-version:
        type: string
      package-name:
        type: string
        default: terraform
      product-version:
        type: string
        required: true
      ld-flags:
        type: string
        required: true
      runson:
        type: string
        required: true

jobs:
  build:
    runs-on: ${{ inputs.runson }}
    name: Build ${{ inputs.goos }} ${{ inputs.goarch }} v${{ inputs.product-version }}
    steps:
      - uses: actions/checkout@v3

      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: ${{inputs.go-version}}
      - name: Determine artifact basename
        run: echo "ARTIFACT_BASENAME=${{ inputs.package-name }}_${{ inputs.product-version }}_${{ inputs.goos }}_${{ inputs.goarch }}.zip" >> $GITHUB_ENV

      - name: Build
        run: |
          mkdir dist out
          set -x
          go build -ldflags "${{ inputs.ld-flags }}" -o dist/ ./cmd/dscan
          zip -r -j out/${{ env.ARTIFACT_BASENAME }} dist/

      - uses: actions/upload-artifact@v3
        with:
          name: ${{ env.ARTIFACT_BASENAME }}
          path: out/${{ env.ARTIFACT_BASENAME }}
          if-no-files-found: error
      - name: Upload binaries to release
        uses: svenstaro/upload-release-action@v2
        with:
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          file: out/${{ env.ARTIFACT_BASENAME }}
          asset_name: ${{ env.ARTIFACT_BASENAME }}
          tag: v${{ inputs.product-version }}


```
