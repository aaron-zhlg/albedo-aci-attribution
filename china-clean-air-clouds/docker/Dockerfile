FROM mambaorg/micromamba:1.5.10

COPY --chown=$MAMBA_USER:$MAMBA_USER docker/environment.yml /tmp/environment.yml
RUN micromamba install -y -n base -f /tmp/environment.yml && micromamba clean --all --yes

# Run as root so bind-mounted data folders are writable on both Windows and Linux hosts.
USER root
ARG MAMBA_DOCKERFILE_ACTIVATE=1
WORKDIR /work
COPY scripts /work/scripts

ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]
CMD ["bash", "scripts/prepare_data.sh", "--list"]
