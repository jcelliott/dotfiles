function os_detect --description "detect and print the current platform and distribution"
  # Check OS
  set -g _platform 'unknown'
  switch (uname)
    case Darwin
      set -g _platform 'darwin'
    case Linux
      set -g _platform 'linux'
  end

  # Determine the specific linux distro
  set -g _distro ''
  if test $_platform = 'linux'
    if test -f /etc/debian_version
      set -g _distro 'debian'
    else if test -f /etc/arch-release
      set -g _distro 'arch'
    else
      set -g _distro 'unknown'
    end
  end

  # pinfo "Operating System: $_platform $_distro"
end
