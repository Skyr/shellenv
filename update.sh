#!/bin/bash

function binaryInPath {
	while [ $# -gt 0 ] ; do
		if ! which "$1" >/dev/null 2>&1 ; then
			return 1
		fi
		shift
	done
	return 0
}

ABSOLUTE_LINKS=0
if [ "$1" == "-a" ] ; then
  ABSOLUTE_LINKS=1
fi

if ! binaryInPath python ; then
  ABSOLUTE_LINKS=1
fi

function absoluteLink {
  if [ -f "$1" ] ; then
    pushd `dirname "$1"` > /dev/null
  else
    pushd "$1" > /dev/null
  fi
  ABSOLUTE_LINK=`pwd`
  popd > /dev/null
}

function relativeToHome {
  if [ "$ABSOLUTE_LINKS" == "1" ] ; then
    absoluteLink "$1"
    RELATIVE_TO_HOME=$ABSOLUTE_LINK
  else
    RELATIVE_TO_HOME=`python -c "import os.path; print os.path.relpath('$HOME', '$1')"`
  fi
}

function relativeFromHome {
  if [ "$ABSOLUTE_LINKS" == "1" ] ; then
    absoluteLink "$1"
    RELATIVE_FROM_HOME=$ABSOLUTE_LINK
  else
    RELATIVE_FROM_HOME=`python -c "import os.path; print os.path.relpath('$1', '$HOME')"`
  fi
}

# Path to shellenv, relative to $HOME
relativeFromHome "`dirname $0`"
SHELLENV_HOME="$RELATIVE_FROM_HOME"
BACKUPEXT=`date +%y%m%d%H%M`.bak

# Create an empty file (if not exists); relative to $HOME
function createFile {
	FILENAME="$HOME/$1"
	if [ ! -f "$FILENAME" ] ; then
		touch "$FILENAME"
		echo "--- Created empty file $1"
	fi
}

# Returns true if parameter is a symbolic link and links to shellenv directory; relative to $HOME
function isLinkToShellenv {
	FILENAME="$HOME/$1"
	if [ -L "$FILENAME" ] ; then
		LINKDEST="`readlink -f $FILENAME`"
		relativeFromHome "$LINKDEST"
		[[ "$RELATIVE_FROM_HOME" == *${SHELLENV_HOME}/* ]] || [[ "$RELATIVE_FROM_HOME" == "$SHELLENV_HOME" ]]
	else
		return 1
	fi
}

# Removes given file; if not a link to shellenv, a backup is created; relative to $HOME
function backupAndRemove {
	FILENAME="$HOME/$1"
	if [ -e "$FILENAME" ] ; then
		if isLinkToShellenv "$1" ; then
			rm "$FILENAME"
		else
			mv "$FILENAME" "$FILENAME.$BACKUPEXT"
			echo "--- Backed up $1 as $1.$BACKUPEXT"
		fi
	fi
}

# Check if param 1 is a link to shellenv (relative to $HOME). If not, create a link to shellenv/$2
function checkLinkToShellenv {
	FILENAME="$HOME/$1"
	if ! isLinkToShellenv "$1" ; then
		backupAndRemove "$1"
		relativeToHome "`dirname $FILENAME`"
    if [ "$ABSOLUTE_LINKS" == "1" ] ; then
      ln -s "$SHELLENV_HOME/$2" "$FILENAME"
    else
      ln -s "$RELATIVE_TO_HOME/$SHELLENV_HOME/$2" "$FILENAME"
    fi
	fi
}


### Main stuff ###

cd "$HOME"
cd "$SHELLENV_HOME"

### Symlink from $HOME/bin to all shell scripts in bin
mkdir -p "$HOME/bin"
for i in bin/* ; do
	checkLinkToShellenv "$i" "$i"
done

### Set up Oh my zsh
if binaryInPath zsh git ; then
	checkLinkToShellenv .zshrc zshrc
	createFile .zshrc.local
	if [ ! -d "$HOME/.oh-my-zsh" ] ; then
		git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
	fi
  chsh -s `which zsh`
fi

### Set up Janus
if binaryInPath vi git rake ; then
	checkLinkToShellenv .vimrc.before janus/vimrc.before
	checkLinkToShellenv .vimrc.after janus/vimrc.after
	for i in .vimrc.before.local .vimrc.after.local ; do
		createFile $i
	done
	if [ ! -h "$HOME/.janus" ] ; then
		for i in .vim .vimrc .gvimrc; do
			backupAndRemove "$i"
		done
		git clone https://github.com/carlhuda/janus.git $HOME/.vim
		pushd "$HOME/.vim" > /dev/null
		rake
		popd > /dev/null
		checkLinkToShellenv .janus janus
	else
		pushd "$HOME/.vim" > /dev/null
		rake > /dev/null
		popd > /dev/null
	fi
fi

