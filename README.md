# 🏆 GitHub Achievements Speedrun

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20powershell-1f425f.svg)](speedrun.sh)
[![gh CLI](https://img.shields.io/badge/requires-gh%20CLI-000?logo=github)](https://cli.github.com)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Um script (bash **e** PowerShell) que desbloqueia as conquistas automatizáveis do
perfil do GitHub abrindo, mergeando e fechando coisas **de verdade** no seu próprio
repositório público — sem gambiarra, sem bot de terceiro, sem token estranho.

```bash
gh auth login
./speedrun.sh
```

Em ~1 minuto: **Pull Shark**, **YOLO** e **Quickdraw**.

---

## O que dá pra automatizar (e o que não dá)

| Conquista | Critério | Automatizado? |
|---|---|---|
| 🦈 **Pull Shark** | 2 pull requests mergeados | ✅ `speedrun.sh` |
| 🤠 **YOLO** | mergear um PR sem code review | ✅ `speedrun.sh` |
| ⚡ **Quickdraw** | fechar uma issue/PR em menos de 5 min | ✅ `speedrun.sh` |
| 👯 **Pair Extraordinaire** | PR mergeado com `Co-authored-by:` | ⚠️ `--coauthor` (precisa de outra conta real) |
| 🌟 **Starstruck** | 16 estrelas num repositório seu | ❌ manual — [checklist](docs/checklist.md) |
| 🧠 **Galaxy Brain** | 2 respostas aceitas em Discussions | ❌ manual — [checklist](docs/checklist.md) |
| 💝 **Public Sponsor** | patrocinar alguém no GitHub Sponsors | ❌ manual, exige cartão de crédito |
| 💜 Heart On Your Sleeve · 🌐 Open Sourcerer · 🚀 Mars 2020 · 🧊 Arctic Code Vault | — | 🔒 aposentadas, não dá mais |

> ⚠️ **Só conta em repositório público.** Atividade em repo privado não gera badge.
> E os badges aparecem no perfil com atraso — de alguns minutos até ~24h.

---

## Uso

### Pré-requisitos

- `git`
- [`gh` (GitHub CLI)](https://cli.github.com) autenticado: `gh auth login`
  - Windows: `winget install GitHub.cli`
  - macOS: `brew install gh`
  - Linux: veja o [manual de instalação](https://github.com/cli/cli#installation)

### Passo 1 — tenha um repositório público

Pode ser este mesmo, depois de subir pro GitHub:

```bash
gh repo create github-achievements-speedrun --public --source=. --remote=origin --push
```

### Passo 2 — rode o script

Linux / macOS / Git Bash:

```bash
./speedrun.sh
```

Windows PowerShell:

```powershell
.\speedrun.ps1
```

### Opções

| Flag (bash) | Flag (PowerShell) | O que faz |
|---|---|---|
| `-r, --repo owner/nome` | `-Repo owner/nome` | Repo alvo (padrão: o do diretório atual) |
| `-n, --rounds N` | `-Rounds N` | Quantos PRs criar+mergear (padrão: `2`) |
| `--coauthor "Nome <email>"` | `-CoAuthor "Nome <email>"` | Adiciona `Co-authored-by:` → Pair Extraordinaire |
| `--skip-quickdraw` | `-SkipQuickdraw` | Não abre/fecha a issue do Quickdraw |
| `--dry-run` | `-DryRun` | Só mostra o que faria |

**Sempre rode com `--dry-run` primeiro** se quiser ver o plano antes de escrever qualquer coisa.

```bash
./speedrun.sh --dry-run
```

---

## O que o script faz exatamente

Nenhuma mágica — são comandos que você poderia digitar na mão:

1. Confere que `git` e `gh` existem e que você está autenticado.
2. Descobre o repositório alvo, sua visibilidade e o branch padrão.
   Avisa (e pede confirmação) se o repo não for público.
3. Para cada rodada:
   - cria o branch `achievement/run-<timestamp>-<n>`
   - acrescenta uma linha em `ACHIEVEMENTS.md` e commita
     (com trailer `Co-authored-by:` se você passou `--coauthor`)
   - `gh pr create` → `gh pr merge --squash --delete-branch`
   - merge **sem nenhuma review** → é isso que dá o **YOLO**
   - 2 merges → **Pull Shark**
4. Abre uma issue e fecha 15 segundos depois → **Quickdraw**.
5. Imprime um resumo do que foi desbloqueado e do que sobrou pra fazer na mão.

---

## Pair Extraordinaire

Precisa de uma **segunda pessoa real** no commit — o GitHub valida o e-mail contra
uma conta existente. Use o e-mail `noreply` da pessoa (ela acha em
*Settings → Emails → Keep my email addresses private*):

```bash
./speedrun.sh --coauthor "Fulana <123456+fulana@users.noreply.github.com>"
```

Combine com alguém: você faz o dela, ela faz o seu, os dois ganham.
Detalhes em [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Starstruck e Galaxy Brain

Essas duas **não** dá pra scriptar de forma honesta — dependem de outras pessoas.
Comprar estrelas ou usar rede de troca é violação dos
[Termos de Serviço do GitHub](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
e rende suspensão da conta. O [checklist](docs/checklist.md) traz o caminho legítimo
pra conseguir as 16 estrelas e as 2 respostas aceitas.

---

## Licença

[MIT](LICENSE)

Guia de referência das conquistas: [githubachievements.com](https://githubachievements.com/)
