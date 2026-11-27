# =============================================================================
# cloci + mycotools, built from source checkouts (not conda builds of the
# project code). Third-party dependencies and external binaries (mmseqs2,
# diamond, hmmer, mafft, clipkit, iqtree, fasttree, mcl, blast) come from
# conda-forge/bioconda through pixi.
#
# Build:
#   docker build -t cloci:0.4.0 .
#   docker build --build-arg CLOCI_REF=<sha-or-tag> --build-arg MYCOTOOLS_REF=<sha-or-tag> .
# Run:
#   docker run --rm -v "$PWD:/data" ghcr.io/hyphaltip/cloci_container cloci --help
# =============================================================================
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG CLOCI_VERSION=0.4.0
ARG PIXI_VERSION=0.71.3
ARG CLOCI_REPO=https://github.com/hyphaltip/cloci.git
ARG MYCOTOOLS_REPO=https://github.com/hyphaltip/mycotools.git
# Pinned commits of the checkouts. Bump deliberately.
ARG CLOCI_REF=2ca41914792abe64e87e38f3cb9dca63763f2f71
ARG MYCOTOOLS_REF=3b0bac55e2e15b44d3753ed130c4776ef4b463d7

LABEL org.opencontainers.image.title="cloci_container" \
      org.opencontainers.image.description="CLOCI (Co-occurrence Locus and Orthologous Cluster Identifier) and Mycotools, built from source" \
      org.opencontainers.image.source="https://github.com/hyphaltip/cloci_container" \
      org.opencontainers.image.licenses="LGPL-3.0-or-later" \
      org.opencontainers.image.version="${CLOCI_VERSION}" \
      cloci.ref="${CLOCI_REF}" \
      mycotools.ref="${MYCOTOOLS_REF}"

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl git build-essential procps \
    && rm -rf /var/lib/apt/lists/*

ENV PIXI_HOME=/opt/pixi
RUN curl -fsSL https://pixi.sh/install.sh | PIXI_VERSION=v${PIXI_VERSION} PIXI_NO_PATH_UPDATE=1 bash
ENV PATH="/opt/pixi/bin:${PATH}"

WORKDIR /opt/cloci
RUN mkdir src \
    && git clone "${MYCOTOOLS_REPO}" src/mycotools \
    && git -C src/mycotools checkout "${MYCOTOOLS_REF}" \
    && git clone "${CLOCI_REPO}" src/cloci \
    && git -C src/cloci checkout "${CLOCI_REF}"
COPY pixi.toml /opt/cloci/pixi.toml

RUN pixi install && pixi clean cache -y && rm -rf /root/.cache

ENV PATH="/opt/cloci/.pixi/envs/default/bin:${PATH}" \
    CONDA_PREFIX=/opt/cloci/.pixi/envs/default \
    LC_ALL=C.UTF-8 \
    MPLCONFIGDIR=/tmp/matplotlib

# Smoke test at build time
RUN cloci --help >/dev/null && mtdb --help >/dev/null \
    && python -c "import cloci, mycotools, graph_tool, cogent3" \
    && which mmseqs diamond hmmsearch mafft clipkit iqtree fasttree mcl

WORKDIR /data
CMD ["cloci", "--help"]
