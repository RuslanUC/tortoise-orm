FROM python:3.13-slim-trixie

WORKDIR "/tortoise-orm"

COPY --from=ghcr.io/astral-sh/uv:0.9.26 /uv /uvx /bin/

COPY --from=tortoise pyproject.toml pyproject.toml
COPY --from=tortoise uv.lock uv.lock
COPY --from=tortoise Makefile Makefile

ARG UV_LINK_MODE=copy
ARG DEBIAN_FRONTEND=noninteractive
ENV UV_PYTHON_CACHE_DIR=/root/.cache/uv/python
RUN --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/root/.cache/uv \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt update \
    && apt install curl -y \
    && curl -sSL -O https://packages.microsoft.com/config/debian/$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2)/packages-microsoft-prod.deb \
    && curl -sSL -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 \
    && dpkg -i packages-microsoft-prod.deb \
    && apt update \
    && ACCEPT_EULA=Y apt install --no-install-recommends -y make gcc build-essential python-is-python3 msodbcsql18 \
    && make deps options='--no-install-project' \
    && rm .venv/bin/python3 \
    && ln -s $(readlink .venv/bin/python) .venv/bin/python3 \
    && apt remove curl -y \
    && apt autoremove -y

RUN chmod +x /usr/local/bin/dumb-init

COPY --from=tortoise tortoise tortoise
COPY --from=tortoise tests tests
COPY --from=tortoise examples examples
COPY --from=tortoise conftest.py conftest.py
COPY --from=tortoise README.rst README.rst

ENV PATH="/tortoise-orm/.venv/bin:$PATH"
