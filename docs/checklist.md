# Checklist manual das conquistas

Marque conforme for conseguindo. As três primeiras o `speedrun.sh` resolve sozinho.

## Automatizadas pelo script

- [ ] ⚡ **Quickdraw** — abrir uma issue (ou PR) e fechar em menos de 5 minutos.
- [ ] 🦈 **Pull Shark** — 2 pull requests mergeados.
      Níveis: 2 (bronze) · 16 (prata) · 128 (ouro) · 1024 (diamante).
      Para subir de nível: `./speedrun.sh -n 16`.
- [ ] 🤠 **YOLO** — mergear um PR sem nenhuma code review aprovando.

## Semi-manual

- [ ] 👯 **Pair Extraordinaire** — PR mergeado cujo commit tem trailer
      `Co-authored-by: Nome <email>` de **outra conta real** do GitHub.
      Níveis: 1 · 10 · 24 · 48.

      ```
      git commit -m "feat: algo

      Co-authored-by: Fulana <123456+fulana@users.noreply.github.com>"
      ```

      O e-mail precisa estar ligado a uma conta existente. O formato `noreply`
      é o mais seguro — cada pessoa encontra o seu em
      *Settings → Emails → Keep my email addresses private*.

## Manuais (dependem de outras pessoas)

- [ ] 🌟 **Starstruck** — 16 estrelas num repositório seu.
      Níveis: 16 · 128 · 512 · 4096.

      O caminho que funciona:
      1. Faça algo pequeno e **genuinamente útil** — um script que resolve uma dor sua,
         uma lista curada, um template de config, um guia.
      2. README decente: o que é, o print/gif, como instalar, como usar. Sem isso,
         ninguém passa dos 5 segundos.
      3. Adicione *topics* no repo (`gh repo edit --add-topic ...`) — é assim que
         as pessoas acham no GitHub.
      4. Divulgue onde a dor existe: subreddit do assunto, Dev.to, comunidade no
         Discord/Slack, LinkedIn, grupo de dev no Telegram, Hacker News (Show HN).
      5. Responda todo mundo que comentar. Engajamento vira estrela.

      ❌ **Não** compre estrelas nem entre em rede de troca ("star for star").
      É violação dos Termos de Serviço e dá suspensão da conta.

- [ ] 🧠 **Galaxy Brain** — 2 respostas aceitas em GitHub Discussions.
      Níveis: 2 · 8 · 16 · 32.

      - Não vale mais na *GitHub Community* oficial — precisa ser Discussions de
        algum repositório.
      - Ache repos com a aba **Discussions** ativa e perguntas sem resposta:
        busque `is:open is:unanswered` dentro da aba Discussions de projetos que
        você já usa.
      - Responda de verdade e bem. Quem marca como aceita é quem abriu a pergunta.
      - Projetos com muito movimento e comunidade acolhedora funcionam melhor
        (frameworks JS, ferramentas de build, libs Python populares).

- [ ] 💝 **Public Sponsor** — patrocinar alguém em <https://github.com/sponsors>.
      Exige cartão de crédito. Faça você mesmo — nenhum script deve mexer nisso.
      Tem tiers de US$ 1/mês em vários projetos. Marque o patrocínio como **público**,
      senão o badge não aparece.

## Impossíveis hoje (aposentadas)

- 🔒 **Heart On Your Sleeve** — reação ❤️ em conteúdo. Descontinuada.
- 🔒 **Open Sourcerer** — PRs mergeados em múltiplos repos públicos. Descontinuada.
- 🔒 **Mars 2020 Contributor** — contribuição em repo usado na missão Mars 2020.
  Janela fechada em 2021.
- 🔒 **Arctic Code Vault Contributor** — código no snapshot de 02/02/2020 do
  Arctic Code Vault. Janela fechada.

## Depois de rodar tudo

- Os badges levam de alguns minutos até ~24h pra aparecer.
- Confira em `https://github.com/SEU-USUARIO` na coluna da esquerda, seção
  **Achievements**.
- Se não aparecer: confirme que o repositório é **público** e que
  *Settings → Profile → Show Achievements on my profile* está ligado.
