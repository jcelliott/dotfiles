# Defined in - @ line 1
function ql --wraps='qlmanage -p  >/dev/null ^/dev/null' --description 'alias ql qlmanage -p  >/dev/null ^/dev/null'
  qlmanage -p  >/dev/null ^/dev/null $argv;
end
