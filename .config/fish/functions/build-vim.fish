function build-vim --description 'Build vim from source'
  pinfo "~~~ building vim from source"
  if test ! -d "$HOME/builds"
    mkdir -p "$HOME/builds"
  end

  set _vimdir "$HOME/builds/vim"
  if test ! -d $_vimdir
    pinfo "~~~ cloning vim repository"
    git clone https://github.com/b4winckler/vim.git $_vimdir 
  end
  pushd $_vimdir/src

  set _vim_base_version "v7-4-"
  pinfo "~~~ git fetch"
  git fetch
  set _vim_version ( git tag | grep $_vim_base_version | sort | tail -1 )
  pinfo "~~~ git checkout $_vim_version"
  git checkout $_vim_version
  
  pinfo "~~~ clean"
  make distclean

  pinfo "~~~ configure"
  ./configure \
    --with-compiledby=jelliott \
    --with-features=huge \
    --with-x=no \
    --disable-gui \
    --enable-clipboard \
    --enable-rubyinterp \
    --enable-pythoninterp \
    --enable-luainterp \

  pinfo "~~~ make"
  make
  pinfo "~~~ make install"
  sudo make install
  popd
  psuccess "~~~ done"
end
