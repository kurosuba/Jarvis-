#!/usr/bin/env bash
# Installe et configure OpenJarvis (https://github.com/open-jarvis/OpenJarvis)
# à partir du sous-module ./OpenJarvis de ce dépôt.
#
# Usage :
#   git clone --recurse-submodules https://github.com/kurosuba/Jarvis-.git
#   cd Jarvis- && ./setup.sh            # modèle par défaut : qwen3.5:2b
#   MODEL=qwen3.5:4b ./setup.sh         # autre modèle Ollama
#   SKIP_OLLAMA=1 ./setup.sh            # sans Ollama (moteur distant / cloud)
set -euo pipefail

MODEL="${MODEL:-qwen3.5:2b}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/OpenJarvis"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

say "Sous-module OpenJarvis"
git -C "$ROOT" submodule update --init --recursive

say "uv (gestionnaire Python)"
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

say "Environnement Python + OpenJarvis (mode éditable)"
cd "$SRC"
[ -d .venv ] || uv venv --python 3.12 .venv
uv pip install --python .venv/bin/python -e .

if [ "${SKIP_OLLAMA:-0}" != "1" ]; then
    say "Ollama"
    command -v ollama >/dev/null 2>&1 || curl -fsSL https://ollama.com/install.sh | sh
    if ! ollama list >/dev/null 2>&1; then
        mkdir -p "$HOME/.openjarvis"
        nohup ollama serve >"$HOME/.openjarvis/ollama.log" 2>&1 &
        for _ in $(seq 1 30); do ollama list >/dev/null 2>&1 && break; sleep 2; done
    fi
    say "Téléchargement du modèle $MODEL"
    ollama pull "$MODEL"
fi

say "Configuration (~/.openjarvis/config.toml)"
if [ ! -f "$HOME/.openjarvis/config.toml" ]; then
    .venv/bin/jarvis _bootstrap --write-config --engine ollama --model "$MODEL"
    printf '\n[security]\nprofile = "personal"\n' >>"$HOME/.openjarvis/config.toml"
else
    echo "    config existante conservée (jarvis init --force pour la régénérer)"
fi

say "Commande 'jarvis' dans ~/.local/bin"
mkdir -p "$HOME/.local/bin"
ln -sf "$SRC/.venv/bin/jarvis" "$HOME/.local/bin/jarvis"
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *)
    echo "    Ajoute à ton shell : export PATH=\"\$HOME/.local/bin:\$PATH\"" ;; esac

say "Diagnostic"
.venv/bin/jarvis doctor || true

say "Terminé. Lance : jarvis   (ou : jarvis gui)"
