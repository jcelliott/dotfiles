function nowrap --description 'Trim output to terminal width per-line'
  # expand tabs first so character counts map to screen rows correctly
  expand -t4 | cut -c1-$COLUMNS -
end
