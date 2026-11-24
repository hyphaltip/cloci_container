# cloci_container

Container for [CLOCI](https://github.com/xonq/cloci) (Co-occurrence Locus and
Orthologous Cluster Identifier) and [Mycotools](https://github.com/xonq/mycotools).
Published to `ghcr.io/hyphaltip/cloci_container`.

The image builds `cloci` and `mycotools` **from source checkouts** (the
`hyphaltip` forks, at the commits pinned in the `Dockerfile`), not from the conda
packages. `pixi` provides the third-party Python packages and external binaries:
mmseqs2, diamond, blast, hmmer, mafft, clipkit, iqtree, fasttree, mcl, graph-tool.

## Versions

- `VERSION` holds the cloci version (default tag for `main` builds).
- Release tags are `v<version>`, for example `v0.4.0`. They publish `:<version>` and `:latest`.
- `CLOCI_REF` and `MYCOTOOLS_REF` (build args in `Dockerfile`, arguments in `cloci.def`) pin the source commits. Change them on purpose.

## Use

Docker:

    docker run --rm -v "$PWD:/data" ghcr.io/hyphaltip/cloci_container:latest cloci --help

Apptainer on HPCC:

    ./pull_sif.sh                 # pulls the CI image to cloci-<VERSION>.sif
    apptainer exec cloci-0.4.0.sif cloci --help
    sbatch build_slurm.sh         # or build locally from cloci.def

## CI

`.github/workflows/build.yml` builds and pushes the image on pushes to `main`
and on `v*` tags, signs it with Cosign, and attaches a SLSA provenance
attestation. `container-cleanup.yml` deletes untagged images older than 2 weeks.

## Notes

- No `pixi.lock` is committed, so dependency versions float between builds. Only the cogent3 pin (`2025.5.8a10`) and the source commits are fixed.
- `cloci.def` and the `Dockerfile` must stay in sync with each other and with `pixi.toml`.
- Dev environment with editable checkouts: see `pixi.toml` in the parent `cloci_tools` directory.
