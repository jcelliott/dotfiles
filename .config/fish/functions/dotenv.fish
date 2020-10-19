function dotenv --description "source .env file in current directory"
  # bass seems to choke on environment variables with newlines
  # if available bass
  #   bass 'set -a; [ -f .env ] && source .env'
  # else
  #   perror "bass is not installed"
  #   exit 1
  # end

  if test -f ".env"
    for var in (cat .env)
      # don't try to export comments or empty lines
      if string match --quiet --entire --regex '^\s*#|^\s*$' $var > /dev/null
	# --quiet doesn't seem to work
	continue
      end
      # pinfo "would export: $var"
      bass export (string unescape $var)
    end
    return 0
  else
    perror "no .env file found"
    return 1
  end
end
