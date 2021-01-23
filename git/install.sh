info () {
	printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
	printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
	printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
	echo ''
	exit
}
setup_gitconfig () {
  if ! [ -f git/gitconfig.symlink ]
  then
    info 'setup gitconfig'

    git_credential='cache'
    if [ "$(uname -s)" == "Darwin" ]
    then
      git_credential='osxkeychain'
    fi

    user ' - What is your github author name?'
    read -e git_authorname
    user ' - What is your github author email?'
    read -e git_authoremail
    user ' - What is your github username?'
    read -e git_authorhandle
    user ' - What is your GPG signing key? (Run `gpg --list-keys`)'
    read -e gpg_signing_key

    sed -e "s/AUTHOR_NAME/$git_authorname/g" -e "s/AUTHOR_EMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" -e "s/AUTHOR_HANDLE/$git_authorhandle/g" -e "s/GPG_SIGNING_KEY/$gpg_signing_key/g" git/gitconfig.symlink.example > git/gitconfig.symlink

    success 'gitconfig'
  fi
}

setup_gitconfig
ln -s -b ~/.dotfiles/git/gitconfig.symlink ~/.gitconfig
ln -s -b ~/.dotfiles/git/gitignore.symlink ~/.gitignore
echo "export GPG_TTY=$(tty)" >> ~/.zshrc
