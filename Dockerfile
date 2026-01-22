FROM python:3.13-slim-trixie

WORKDIR "/tortoise-orm"

COPY --from=ghcr.io/astral-sh/uv:0.9.26 /uv /uvx /bin/

COPY pyproject.toml pyproject.toml
COPY uv.lock uv.lock
COPY Makefile Makefile

ARG UV_LINK_MODE=copy
ARG DEBIAN_FRONTEND=noninteractive
ENV UV_PYTHON_CACHE_DIR=/root/.cache/uv/python
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    --mount=type=cache,target=/root/.cache/uv \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt update \
    && apt install curl -y \
    && curl -sSL -O https://packages.microsoft.com/config/debian/$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2)/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt update \
    && ACCEPT_EULA=Y apt install --no-install-recommends -y make gcc build-essential python-is-python3 msodbcsql18 \
    && make deps options='--no-install-project' \
    && apt remove curl -y \
    && apt autoremove -y

COPY . .

ENV PATH="/tortoise-orm/.venv/bin:$PATH"
