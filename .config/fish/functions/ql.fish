# Defined in - @ line 1
function ql --wraps='qlmanage -p  >/dev/null 2>/dev/null' --description 'alias ql qlmanage -p  >/dev/null 2>/dev/null'
  qlmanage -p  >/dev/null 2>/dev/null $argv;
end
