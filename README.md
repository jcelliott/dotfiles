# dotfiles

Tracked in place in `$HOME` using a bare repo at `~/.dotfiles`.

## Setup

```bash
git clone --bare git@github.com:jcelliott/dotfiles.git ~/.dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout
```

`checkout` refuses to overwrite existing files. Move or delete any it lists and
run it again. To skip a file on this machine instead, check out everything else
and mark it `skip-worktree` so it doesn't show up as deleted:

```bash
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout HEAD -- . ':!.tmux.conf'
git --git-dir=$HOME/.dotfiles --work-tree=$HOME update-index --skip-worktree .tmux.conf
```

Once checked out, use `dot` (`~/bin/dot`, a wrapper around `git` for this repo;
`~/bin` must be on `PATH`):

```bash
dot config status.showUntrackedFiles no
dot config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'  # bare clones skip this
dot fetch && dot branch -u origin/main
dot submodule update --init
```

## Usage

```bash
dot status
dot add ~/.config/foo    # always add explicit paths, never `dot add .`
dot commit
```
