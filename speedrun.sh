#!/usr/bin/env bash
#
# speedrun.sh - desbloqueia Pull Shark, YOLO, Quickdraw (e opcionalmente
# Pair Extraordinaire) abrindo, mergeando e fechando coisas de verdade
# no seu proprio repositorio publico.
#
# Requisitos: git, gh (GitHub CLI) autenticado com `gh auth login`.

set -euo pipefail

REPO=""
ROUNDS=2
COAUTHOR=""
SKIP_QUICKDRAW=0
DRY_RUN=0

usage() {
  cat <<'USAGE'
Uso: ./speedrun.sh [opcoes]

  -r, --repo owner/nome    Repositorio alvo (padrao: o repo do diretorio atual)
  -n, --rounds N           Quantos PRs criar+mergear (padrao: 2, o minimo do Pull Shark)
      --coauthor "Nome <email>"
                           Adiciona trailer Co-authored-by -> Pair Extraordinaire
                           (precisa ser outra conta REAL do GitHub)
      --skip-quickdraw     Nao abre/fecha a issue do Quickdraw
      --dry-run            Mostra o que faria, sem escrever nada
  -h, --help               Esta ajuda

Exemplos:
  ./speedrun.sh
  ./speedrun.sh -r meu-user/meu-repo -n 3
  ./speedrun.sh --coauthor "Fulana <123456+fulana@users.noreply.github.com>"
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--repo)        REPO="$2"; shift 2 ;;
    -n|--rounds)      ROUNDS="$2"; shift 2 ;;
    --coauthor)       COAUTHOR="$2"; shift 2 ;;
    --skip-quickdraw) SKIP_QUICKDRAW=1; shift ;;
    --dry-run)        DRY_RUN=1; shift ;;
    -h|--help)        usage; exit 0 ;;
    *) echo "Opcao desconhecida: $1" >&2; usage; exit 1 ;;
  esac
done

log()  { printf '\033[36m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m  ok\033[0m %s\n' "$*"; }
warn() { printf '\033[33m  !!\033[0m %s\n' "$*"; }
die()  { printf '\033[31merro:\033[0m %s\n' "$*" >&2; exit 1; }

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '\033[90m  (dry-run) %s\033[0m\n' "$*"
  else
    "$@"
  fi
}

# --- pre-flight ------------------------------------------------------------

command -v git >/dev/null || die "git nao encontrado no PATH."
command -v gh  >/dev/null || die "gh (GitHub CLI) nao encontrado. Instale: https://cli.github.com"
gh auth status >/dev/null 2>&1 || die "gh nao autenticado. Rode: gh auth login"

if [[ -z "$REPO" ]]; then
  REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) \
    || die "Nao consegui detectar o repo. Rode dentro de um clone ou passe --repo owner/nome."
fi

VISIBILITY=$(gh repo view "$REPO" --json visibility -q .visibility)
BASE=$(gh repo view "$REPO" --json defaultBranchRef -q .defaultBranchRef.name)

log "Repo:     $REPO ($VISIBILITY)"
log "Base:     $BASE"
log "Rodadas:  $ROUNDS"
[[ -n "$COAUTHOR" ]] && log "Co-autor: $COAUTHOR"

if [[ "$VISIBILITY" != "PUBLIC" ]]; then
  warn "Repo NAO e publico. Achievements so contam em repositorio publico."
  warn "Torne publico: gh repo edit $REPO --visibility public --accept-visibility-change-consequences"
  read -r -p "Continuar mesmo assim? [s/N] " yn
  [[ "$yn" =~ ^[SsYy]$ ]] || exit 1
fi

# --- garante um clone de trabalho -----------------------------------------

if git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
   && [[ "$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)" == "$REPO" ]]; then
  WORKDIR="$(git rev-parse --show-toplevel)"
  CLONED=0
else
  WORKDIR="$(mktemp -d)/repo"
  log "Clonando $REPO em $WORKDIR"
  run gh repo clone "$REPO" "$WORKDIR" -- --quiet
  CLONED=1
fi
cd "$WORKDIR"

run git checkout "$BASE" --quiet
run git pull --quiet --ff-only || true

# --- Pull Shark + YOLO -----------------------------------------------------

LOGFILE="ACHIEVEMENTS.md"
MERGED=0

for ((i = 1; i <= ROUNDS; i++)); do
  BRANCH="achievement/run-$(date +%s)-$i"
  log "[$i/$ROUNDS] branch $BRANCH"

  run git checkout -b "$BRANCH" --quiet

  if [[ $DRY_RUN -eq 0 ]]; then
    [[ -f "$LOGFILE" ]] || printf '# Achievements log\n\nCada linha abaixo e um PR mergeado por `speedrun.sh`.\n\n' > "$LOGFILE"
    printf -- '- run %s -- PR %s/%s -- %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$i" "$ROUNDS" "$BRANCH" >> "$LOGFILE"
  fi
  run git add "$LOGFILE"

  MSG="chore: registra rodada $i do speedrun de achievements"
  if [[ -n "$COAUTHOR" ]]; then
    MSG="$MSG

Co-authored-by: $COAUTHOR"
  fi
  run git commit -m "$MSG" --quiet
  run git push -u origin "$BRANCH" --quiet

  run gh pr create \
      --repo "$REPO" \
      --base "$BASE" \
      --head "$BRANCH" \
      --title "Rodada $i: registra progresso dos achievements" \
      --body "PR gerado por \`speedrun.sh\`.

- Merge direto, sem code review -> conta para **YOLO**
- PR mergeado -> conta para **Pull Shark** (precisa de 2)"

  # merge sem review nenhum = YOLO; merge = Pull Shark
  run gh pr merge "$BRANCH" --repo "$REPO" --squash --delete-branch
  ok "PR $i mergeado sem review"
  MERGED=$((MERGED + 1))

  run git checkout "$BASE" --quiet
  run git pull --quiet --ff-only || true
done

# --- Quickdraw -------------------------------------------------------------

if [[ $SKIP_QUICKDRAW -eq 0 ]]; then
  log "Quickdraw: abrindo issue e fechando em menos de 5 minutos"
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '\033[90m  (dry-run) gh issue create + gh issue close\033[0m\n'
  else
    URL=$(gh issue create \
        --repo "$REPO" \
        --title "Quickdraw: issue de teste" \
        --body "Issue aberta e fechada em seguida para desbloquear o achievement **Quickdraw**.")
    NUM="${URL##*/}"
    sleep 15
    gh issue close "$NUM" --repo "$REPO" --comment "Fechando rapido. Quickdraw unlocked."
    ok "issue #$NUM aberta e fechada"
  fi
fi

# --- resumo ----------------------------------------------------------------

printf '\n'
log "Resumo"
printf '  Pull Shark         %s (%s de 2 PRs mergeados nesta execucao)\n' "$([[ $MERGED -ge 2 ]] && echo 'ok' || echo 'parcial')" "$MERGED"
printf '  YOLO               ok (merge sem review)\n'
printf '  Quickdraw          %s\n' "$([[ $SKIP_QUICKDRAW -eq 0 ]] && echo 'ok' || echo 'pulado')"
printf '  Pair Extraordinaire %s\n' "$([[ -n "$COAUTHOR" ]] && echo 'ok (trailer Co-authored-by)' || echo 'pulado (use --coauthor)')"
printf '  Starstruck         manual - 16 estrelas, veja docs/checklist.md\n'
printf '  Galaxy Brain       manual - 2 respostas aceitas em Discussions\n'
printf '  Public Sponsor     manual - exige cartao de credito, faca voce mesmo\n'
printf '\nOs badges aparecem no perfil em ate ~24h: https://github.com/%s\n' "$(gh api user -q .login)"

if [[ ${CLONED:-0} -eq 1 ]]; then
  warn "Clone temporario em $WORKDIR (pode apagar)."
fi
exit 0
