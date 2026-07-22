#!/usr/bin/env bash
set -euo pipefail

TABLE="${1:-prefix}"
SOCK="_keycheck_defaults"

# Reduce a `list-keys` dump to "key<TAB>[flags ]command", one line per binding.
parse() {
  awk -v tbl="$1" '
  {
    rep=""
    for (i=1;i<=NF;i++) if ($i=="-r") rep="-r "
    for (i=1;i<=NF;i++) {
      if ($i=="-T" && $(i+1)==tbl) {
        key=$(i+2); cmd=""
        for (j=i+3;j<=NF;j++) cmd = cmd (j>i+3?" ":"") $j
        print key "\t" rep cmd
        break
      }
    }
  }'
}

# Defaults: a fresh server with no config, same tmux binary/version.
tmux -L "$SOCK" -f /dev/null start-server \; list-keys -T "$TABLE" 2>/dev/null \
  | parse "$TABLE" | sort > /tmp/_tmux_default.tsv
tmux -L "$SOCK" kill-server 2>/dev/null || true

# Mine: the live, attached server (reflects config + any runtime binds).
tmux list-keys -T "$TABLE" | parse "$TABLE" | sort > /tmp/_tmux_mine.tsv

# Normalize the tmux-escaped key names (\" \; \{ ...) back to the bare char so
# they line up with how you'd type them in a bind command.
denorm() { sed -E 's/^\\(.)$/\1/'; }

cut -f1 /tmp/_tmux_mine.tsv    | denorm | sort -u > /tmp/_mine_keys
cut -f1 /tmp/_tmux_default.tsv | denorm | sort -u > /tmp/_def_keys

echo "### CUSTOMIZED — differs from default, or you added it"
# Lines present in mine but not verbatim in defaults = changed or added.
comm -23 /tmp/_tmux_mine.tsv /tmp/_tmux_default.tsv | while IFS=$'\t' read -r key cmd; do
  def=$(awk -F'\t' -v k="$key" '$1==k{print $2; exit}' /tmp/_tmux_default.tsv)
  short=$(printf '%s' "$cmd" | cut -c1-46)
  if [ -z "$def" ]; then
    printf '  %-8s %-48s %s\n' "$key" "$short" "(added; not a default key)"
  else
    printf '  %-8s %-48s [default: %s]\n' "$key" "$short" "$(printf '%s' "$def" | cut -c1-30)"
  fi
done

echo
echo "### DEFAULT KEYS YOU UNBOUND (default had it, you don't)"
comm -23 /tmp/_def_keys /tmp/_mine_keys | sed 's/^/  /'

echo
echo "### UNUSED single keys (free to bind in the $TABLE table)"
# Candidate universe: letters, digits, common punctuation, and C-<letter>.
{
  for c in {a..z} {A..Z} {0..9}; do echo "$c"; done
  for c in '!' '"' '#' '$' '%' '&' "'" '(' ')' '*' '+' ',' '-' '.' '/' \
           ':' ';' '<' '=' '>' '?' '@' '[' '\' ']' '^' '_' '`' \
           '{' '|' '}' '~' 'Space'; do echo "$c"; done
  for c in {a..z}; do echo "C-$c"; done
} | sort -u > /tmp/_candidates

comm -23 /tmp/_candidates /tmp/_mine_keys | paste -sd' ' - | fold -s -w 72 | sed 's/^/  /'

echo
printf 'Counts: %s bound, %s default-unchanged, %s customized/added\n' \
  "$(wc -l < /tmp/_tmux_mine.tsv | tr -d ' ')" \
  "$(comm -12 <(sort /tmp/_tmux_mine.tsv) <(sort /tmp/_tmux_default.tsv) | wc -l | tr -d ' ')" \
  "$(comm -23 <(sort /tmp/_tmux_mine.tsv) <(sort /tmp/_tmux_default.tsv) | wc -l | tr -d ' ')"
