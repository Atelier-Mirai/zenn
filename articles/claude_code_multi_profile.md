---
title: "Claude Codeをアカウント別に使い分ける環境構築（macOS）"
emoji: "🗂️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["ClaudeCode", "Anthropic", "AI", "macOS", "zsh"]
published: true
---

## はじめに

[Claude Code](https://www.anthropic.com/claude-code) は、Anthropic が提供するターミナル上で動作する AI コーディングエージェントです。チャット形式で指示を出すと、コードの読み書き・実行・Git 操作などをエージェントが自律的に行ってくれるツールで、CLI のほか VS Code / JetBrains 拡張、デスクトップアプリ、Web 版（claude.ai/code）でも利用できます。

業務でサポート対応・情報系のタスクなど、複数の用途に Claude Code を使っていると、「認証しているアカウント」「会話履歴」「設定」が全部ひとまとめになってしまい、用途をまたいで情報が混ざってしまうことがあります。

Claude Code は環境変数 `CLAUDE_CONFIG_DIR` で設定ディレクトリを切り替えられるため、これを利用して **用途別に完全に独立した Claude Code プロファイル** を作る方法を、実際に構築した手順とともにまとめます。

## やりたいこと

- macOS 上で Claude Code を複数の「顔」で使い分けたい
- プロファイルごとに認証情報・会話履歴・設定を完全に分離したい
- ただし、言語別のコーディングルールなど「共有したいスキル」は1箇所で管理して、どのプロファイルからも使えるようにしたい

今回作成したプロファイルは以下の3つです。

| プロファイル名 | 用途（想定） | 設定ディレクトリ |
|---|---|---|
| `claude-support` | サポート業務用 | `~/.claude-profiles/support` |
| `claude-info` | 情報系業務用 | `~/.claude-profiles/info` |
| （デフォルト） | 通常利用 | `~/.claude`（既定のまま） |

## 1. シェルエイリアスの登録

`~/.zshrc` に、それぞれのプロファイル専用ディレクトリを指す `CLAUDE_CONFIG_DIR` を設定したエイリアスを追記します。

```bash
echo 'alias claude-support='"'"'CLAUDE_CONFIG_DIR="$HOME/.claude-profiles/support" claude'"'"'' >> ~/.zshrc
source ~/.zshrc
claude-support
```

```bash
echo 'alias claude-info='"'"'CLAUDE_CONFIG_DIR="$HOME/.claude-profiles/info" claude'"'"'' >> ~/.zshrc
source ~/.zshrc
claude-info
```

`claude-support` と `claude-info` はそれぞれ独立した `CLAUDE_CONFIG_DIR` を持つため、ログイン中のアカウント・会話履歴・設定がプロファイル間で完全に分離されます。各エイリアスは初回起動時にそのプロファイル用の個別ログイン（アカウント選択）が必要です。

:::message
`CLAUDE_CONFIG_DIR` を明示的に指定しない通常の `claude` コマンドは、既定の `~/.claude` を使い続けます。既存の環境を壊さずに、追加のプロファイルを増やせるのがポイントです。
:::

## 2. スキルディレクトリの共有（シンボリックリンク）

言語別のコーディングルールを定義した Skill（Claude Code のカスタム指示・ナレッジの仕組み）は、共通の資産として `~/.claude/skills/` に置いたまま、各プロファイルからはシンボリックリンクで参照するようにしました。

これにより、スキルの実体は1箇所で管理しつつ、どのプロファイルからでも同じ内容を利用できます。更新もリンク元1箇所を編集するだけで完結します。

```bash
mkdir -p ~/.claude-profiles/support/skills ~/.claude-profiles/info/skills

ln -sfn ~/.claude/skills/ruby-coding-rules ~/.claude-profiles/support/skills/ruby-coding-rules
ln -sfn ~/.claude/skills/ruby-coding-rules ~/.claude-profiles/info/skills/ruby-coding-rules

ln -sfn ~/.claude/skills/c-coding-rules ~/.claude-profiles/support/skills/c-coding-rules
ln -sfn ~/.claude/skills/c-coding-rules ~/.claude-profiles/info/skills/c-coding-rules

ln -sfn ~/.claude/skills/rust-coding-rules ~/.claude-profiles/support/skills/rust-coding-rules
ln -sfn ~/.claude/skills/rust-coding-rules ~/.claude-profiles/info/skills/rust-coding-rules
```

対象スキルは `ruby-coding-rules` / `c-coding-rules` / `rust-coding-rules` の3つです。

## 3. ディレクトリ構成（最終形）

```
~/.claude/
└── skills/
    ├── ruby-coding-rules/   ← スキル実体（正）
    ├── c-coding-rules/
    └── rust-coding-rules/

~/.claude-profiles/
├── support/
│   └── skills/
│       ├── ruby-coding-rules -> ~/.claude/skills/ruby-coding-rules (symlink)
│       ├── c-coding-rules    -> ...
│       └── rust-coding-rules -> ...
└── info/
    └── skills/
        ├── ruby-coding-rules -> ~/.claude/skills/ruby-coding-rules (symlink)
        ├── c-coding-rules    -> ...
        └── rust-coding-rules -> ...
```

## おわりに

`CLAUDE_CONFIG_DIR` とシェルエイリアス、シンボリックリンクという枯れた技術の組み合わせだけで、Claude Code を用途別に安全に使い分ける環境を構築できました。

補足として、今後の運用で意識しておくとよい点を挙げておきます。

- 新しいプロファイルを追加する場合は、同様に `CLAUDE_CONFIG_DIR` を変えたエイリアスを追加し、`skills` ディレクトリに同じシンボリックリンクを張れば、既存スキルをそのまま流用できます。
- スキルの内容を更新する際は `~/.claude/skills/` 配下の実体を編集すればよく、各プロファイル側のシンボリックリンクを個別に更新する必要はありません。
- プロファイルごとに認証・会話ログ・設定（`settings.json` など）は独立するため、業務内容の混在を避けたい場合や、異なる組織・契約単位でアカウントを分けたい場合に有効な構成です。
- `ln -sfn` は既存のリンクがあっても上書きされるため、再実行しても安全（冪等）です。

同じような課題を持つ方の参考になれば幸いです。
