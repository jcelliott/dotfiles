function sysinfo
  set_color blue; printf "Uptime:\t "; set_color normal
  echo (_sysinfo_uptime)

  set_color blue; printf "Loadavg: "; set_color normal
  echo (_sysinfo_loadavg)

  set_color blue; printf "Root:\t "; set_color normal
  echo (_sysinfo_root_usage)
end

function _sysinfo_uptime
  set -l SECS_PER_MIN 60
  set -l SECS_PER_HOUR 3600
  set -l SECS_PER_DAY 86400

  set -l total
  if test (uname) = Darwin
    set -l boot_sec (sysctl -n kern.boottime | string match -r 'sec = (\d+)')[2]
    set total (math (date +%s)" - $boot_sec")
  else
    set total (math "floor("(string split ' ' </proc/uptime)[1]")")
  end

  set -l days (math "floor($total / $SECS_PER_DAY)")
  set -l hours (math "floor($total % $SECS_PER_DAY / $SECS_PER_HOUR)")
  set -l mins (math "floor($total % $SECS_PER_HOUR / $SECS_PER_MIN)")
  set -l secs (math "floor($total % $SECS_PER_MIN)")

  if test $days -gt 0
    printf "%d days, %d:%02d:%02d" $days $hours $mins $secs
  else
    printf "%d:%02d:%02d" $hours $mins $secs
  end
end

function _sysinfo_loadavg
  set -l loads
  if test (uname) = Darwin
    set loads (sysctl -n vm.loadavg | string replace -ra '[{}]' '' | string trim | string split ' ')
  else
    set loads (string split ' ' </proc/loadavg)
  end

  printf "%.2f, %.2f, %.2f" $loads[1] $loads[2] $loads[3]
end

function _sysinfo_root_usage
  set -l path
  if test (uname) = Darwin
    set path /System/Volumes/Data
  else
    set path /
  end

  set -l fields (df -Ph $path | tail -1 | string split -n ' ')

  set -l total $fields[2]
  set -l used $fields[3]
  set -l pct $fields[5]

  printf "%s / %s (%s)" $used $total $pct
end
