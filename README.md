# Jarvis

Mise en place de [OpenJarvis](https://github.com/open-jarvis/OpenJarvis) — assistant IA personnel qui tourne en local (Stanford Hazy Research, licence Apache 2.0).

Le code d'OpenJarvis est inclus comme **sous-module git** dans `OpenJarvis/`.

## Installation (macOS · Linux · WSL2)

Prérequis : `git`, `curl`. Le script installe le reste (uv, Python 3.12, Ollama, un modèle local).

```bash
git clone --recurse-submodules https://github.com/kurosuba/Jarvis-.git
cd Jarvis-
./setup.sh
```

Options :

| Variable | Effet |
|---|---|
| `MODEL=qwen3.5:4b ./setup.sh` | Autre modèle Ollama (par défaut `qwen3.5:2b`, ~2 Go ; `4b`/`9b` si tu as plus de RAM/GPU) |
| `SKIP_OLLAMA=1 ./setup.sh` | N'installe pas Ollama (moteur distant ou cloud) |

## Utilisation

```bash
jarvis                 # chat dans le terminal
jarvis ask "Bonjour"   # question unique
jarvis gui             # interface web (Node.js 22+ requis)
jarvis doctor          # diagnostic
jarvis init --preset code-assistant --force   # changer de preset
```

Presets disponibles : `chat-simple`, `code-assistant`, `deep-research`, `scheduled-monitor`, `morning-digest-linux` / `-mac` / `-minimal`.

La configuration est dans `~/.openjarvis/config.toml`.

## Mettre à jour OpenJarvis

```bash
git submodule update --remote OpenJarvis
./setup.sh
```

Documentation complète : <https://open-jarvis.github.io/OpenJarvis/>
