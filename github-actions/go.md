# Build e Deploy de aplicativos em GO

Exemplo de um workflow para realizar o build do solução em go e publicar os artefatos na release

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
