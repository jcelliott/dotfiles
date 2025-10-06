```bash
git init
git remote add origin git@github.com:jcelliott/dotfiles.git
git fetch
git branch master origin/master
git reset --hard origin/master
git submodule init
git submodule update
```

Add this to `.git/info/exclude`:

```
# ignore everything by default
*
```

Putting it there rather than in `.gitignore` prevents other tooling from reading
it while the git repo is disabled, which has caused some issues.

