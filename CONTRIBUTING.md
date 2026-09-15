# Contribuindo

Contribuição aqui é bem-vinda — e serve de treino pros próprios achievements
que o projeto ensina.

## Fluxo

1. Faça fork e crie um branch: `git checkout -b feat/minha-ideia`
2. Faça a mudança.
3. Abra o PR descrevendo o que mudou e por quê.

## Pair Extraordinaire para os dois lados

Se você quer o badge **Pair Extraordinaire**, faça o commit com o trailer
`Co-authored-by:` apontando pra quem revisou/parou pra pensar com você:

```
git commit -m "feat: adiciona suporte a X

Co-authored-by: Fulana <123456+fulana@users.noreply.github.com>"
```

Regras que costumam derrubar o badge:

- O e-mail **precisa** pertencer a uma conta real do GitHub.
- O trailer vai no **corpo** do commit, separado do título por uma linha em branco.
- Duas linhas em branco antes do trailer quebram o parsing — use exatamente uma.
- O PR precisa ser **mergeado**, não só aberto.
- Se você usa squash merge, confira que o trailer sobreviveu na mensagem final:
  o GitHub preserva `Co-authored-by` no squash, mas edições manuais na caixa de
  mensagem podem apagar.

## Estilo

- Scripts em bash e PowerShell devem continuar em paridade de funcionalidade.
- Antes de abrir o PR:

  ```bash
  bash -n speedrun.sh
  ./speedrun.sh --dry-run
  ```

  ```powershell
  .\speedrun.ps1 -DryRun
  ```
