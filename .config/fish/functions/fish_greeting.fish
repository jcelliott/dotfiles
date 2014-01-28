function fish_greeting

  # colorized output
  function cinfo
    echo -e "\x1b[34m$argv\x1b[0m" # blue
    #echo -e "\x1b[32m$argv\x1b[0m" # green
  end

  function cwarn
    echo -e "\x1b[33m$argv\x1b[0m" # yellow
  end

  function cerror
    echo -e "\x1b[31m$argv\x1b[0m" # red
  end

  ### Check OS ###
  set platform 'unknown'
  switch (uname)
    case Darwin
      set platform 'darwin'
    case Linux
      set platform 'linux'
  end

  # Determine the specific linux distro
  set distro ''
  if test $platform = 'linux'
    if test -f /etc/debian_version
      set distro 'debian'
    else if test -f /etc/arch-release
      set distro 'arch'
    else
      set distro 'unknown'
    end
  end

  cinfo "Operating System: $platform $distro"
  cinfo "Shell: fish"
  date

end
