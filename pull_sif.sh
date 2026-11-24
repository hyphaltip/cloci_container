#!/usr/bin/env bash
# Get the cloci Apptainer image.
#   ./pull_sif.sh            pull ghcr.io/hyphaltip/cloci_container:<VERSION> (default)
#   ./pull_sif.sh --build    build from cloci.def (needs --fakeroot; run under SLURM)
# Cache and tmp go to node-local $SCRATCH to protect the NFS home quota.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
VERSION="$(tr -d '[:space:]' < "$HERE/VERSION")"
MODE=pull
[[ "${1:-}" == "--build" ]] && { MODE=build; shift; }
DEST="${1:-$HERE/cloci-${VERSION}.sif}"
module load apptainer 2>/dev/null || true
export APPTAINER_CACHEDIR="${APPTAINER_CACHEDIR:-${SCRATCH:-/tmp}/apptainer_cache}"
export APPTAINER_TMPDIR="${APPTAINER_TMPDIR:-${SCRATCH:-/tmp}/apptainer_tmp}"
mkdir -p "$APPTAINER_CACHEDIR" "$APPTAINER_TMPDIR"
if [[ $MODE == pull ]]; then
    apptainer pull -F "$DEST" "docker://ghcr.io/hyphaltip/cloci_container:${VERSION}"
else
    cd "$HERE"
    apptainer build --fakeroot -F "$DEST" "$HERE/cloci.def"
fi
echo "Wrote $DEST" >&2
