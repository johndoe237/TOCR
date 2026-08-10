set -Eeuo pipefail

log() {
  printf '[entrypoint] %s\n' "$*"
}

fail() {
  printf '[entrypoint] ERROR: %s\n' "$*" >&2
  exit 1
}

: "${OPENCODE_DATA_ROOT:=/data}"
: "${WORKSPACE_DIR:=${OPENCODE_DATA_ROOT}/workspace}"
: "${PORT:=4096}"
export HOME="${OPENCODE_HOME:-${OPENCODE_DATA_ROOT}/home}"
: "${OPENCODE_SERVER_USERNAME:=opencode}"
: "${GIT_USER_NAME:=Workspace User}"
: "${GIT_USER_EMAIL:=opencode@local.invalid}"

: "${DEFAULT_PROJECT_NAME:=projet1}"

export PORT
export OPENCODE_SERVER_USERNAME
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export OPENCODE_CONFIG_DIR="${OPENCODE_CONFIG_DIR:-${XDG_CONFIG_HOME}/opencode}"
export OPENCODE_CONFIG="${OPENCODE_CONFIG:-${OPENCODE_CONFIG_DIR}/opencode.json}"
export GH_CONFIG_DIR="${GH_CONFIG_DIR:-${XDG_CONFIG_HOME}/gh}"
export GH_PAGER=cat
export PAGER=cat
export BUNDLED_OPENCODE_CONFIG="${BUNDLED_OPENCODE_CONFIG:-/app/opencode.json}"

mkdir -p \
  "${WORKSPACE_DIR}" \
  "${OPENCODE_CONFIG_DIR}" \
  "${XDG_DATA_HOME}/opencode" \
  "${XDG_CACHE_HOME}/opencode" \
  "${GH_CONFIG_DIR}"

if ln -sfn "${WORKSPACE_DIR}" /workspace 2>/dev/null; then
  log "Created /workspace symlink -> ${WORKSPACE_DIR}."
else
  log "Could not create /workspace symlink; use ${WORKSPACE_DIR} directly if needed."
fi

if [[ -z "$(find "${WORKSPACE_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)" ]]; then
  DEFAULT_PROJECT_DIR="${WORKSPACE_DIR}/${DEFAULT_PROJECT_NAME}"
  mkdir -p "${DEFAULT_PROJECT_DIR}"
  if [[ ! -d "${DEFAULT_PROJECT_DIR}/.git" ]]; then
    git init "${DEFAULT_PROJECT_DIR}" >/dev/null 2>&1 || true
  fi
  if [[ ! -f "${DEFAULT_PROJECT_DIR}/README.md" ]]; then
    printf '# %s\n\nProjet créé automatiquement au premier démarrage.\n' "${DEFAULT_PROJECT_NAME}" > "${DEFAULT_PROJECT_DIR}/README.md"
  fi
  log "Workspace vide détecté ; projet par défaut créé : ${DEFAULT_PROJECT_DIR}"
else
  log "Workspace déjà peuplé ; aucun projet par défaut créé."
fi

if [[ -z "${OPENCODE_SERVER_PASSWORD:-}" ]]; then
  fail "OPENCODE_SERVER_PASSWORD is required."
fi

if [[ ! -f "${OPENCODE_CONFIG}" || "${FORCE_SYNC_OPENCODE_CONFIG:-0}" == "1" ]]; then
  cp "${BUNDLED_OPENCODE_CONFIG}" "${OPENCODE_CONFIG}"
  log "Seeded ${OPENCODE_CONFIG} from bundled config."
fi

if [[ -z "${GITHUB_TOKEN:-}" && -z "${GH_TOKEN:-}" ]]; then
  fail "GITHUB_TOKEN is required for GitHub CLI authentication."
fi

export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
export GITHUB_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN}}"

log "Configuring git identity."
git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"
git config --global init.defaultBranch main
git config --global pull.rebase false

log "Checking GitHub CLI authentication."
if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  log "No active GH CLI session detected; attempting token login."
  if ! printf '%s' "${GH_TOKEN}" | gh auth login --hostname github.com --git-protocol https --with-token >/dev/null 2>&1; then
    fail "GitHub authentication failed. Check that GITHUB_TOKEN is valid and has the scopes your workflow needs."
  fi
fi

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  fail "GitHub CLI is still not authenticated after login attempt."
fi

if gh auth setup-git --hostname github.com >/dev/null 2>&1; then
  log "Git is configured to use GitHub CLI as credential helper."
else
  log "Proceeding without gh auth setup-git; gh commands remain available with the provided token."
fi

cd "${WORKSPACE_DIR}"

log "Starting opencode serve on 0.0.0.0:${PORT}."
exec opencode serve --hostname 0.0.0.0 --port "${PORT}"
