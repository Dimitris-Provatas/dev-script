#!/bin/zsh

EDITOR=hx
VERSION="1.0"
SCRIPT=$(dirname "$0/$1")

declare -A paths
paths[home]=$HOME

exists() {
  eval '[ ${'$3'[$1]+exists} ]'
}

brand() {
  figlet "Dev Script"
  echo ""
  echo "*---------------------------------------------------------------*"
  echo "| A script to load projects fast in your code editor of choice! |"
  echo "*---------------------------------------------------------------*"
  echo ""
}

help() {
  echo "Available arguments:"
  echo "|"
  echo "|-> help:                   Shows this message."
  echo "|"
  echo "|-> info:                   Shows info about the script."
  echo "|"
  echo "|-> editor {name}:          Changes the editor used by the script. Takes in a second argument {name}, which is the command used for the editor (e.g. for NeoVim it should be nvim, for Helix Editor it should be hx etc)."
  echo "|"
  echo "|-> path-add {name} {path}: Add a 'favourite' path to a list to be able to jump in immediately. First provide a name to easily retrieve it and then an absolute path to the location. This option allows you to use the name in order to access your project from anywhere!"
  echo "|"
  echo "|-> path-rm {name}:         Delete a path from 'favourites'. This will remove the entry of the path and you will no longer be able to quicly jump to it."
  echo "|"
  echo "|-> path-ls:                Get a list of all the paths you currently have stored."
  echo "|"
  echo "|-> {path}:                 Relative or absolute path of the project to open. Relative paths work from your current location (using the \`pwd\` command)."
  echo ""
  exit 0
}

brand

case $1 in
  "help")
    help
    ;;
  "info")
    echo "Version:        $VERSION"
    echo "Editor Command: $EDITOR"
    echo "Editor Path:    $(which $EDITOR)"
    ;;
  "editor")
    if [ -z "$2" ]; then
      echo "Please provide the command of the editor you want to use (e.g.·for·NeoVim·it·should·be·nvim,·for·Helix·Editor·it·should·be·hx·etc)!"
      exit 1
    fi
    
    sed -i -e "1,/EDITOR/s/EDITOR=.*/EDITOR=$2/" $SCRIPT
    
    echo "Successfully changed your editor command to $2!"
    ;;
  "path-add")
    sed -i -e "1,/paths\[[^\$]/s#paths\[[^\$]#paths\[$2\]=\"$3\"\n&#" $SCRIPT
    
    echo "Added path '$3' as alias '$2' successfully!"
    ;;
  "path-rm")
    if [ -z "$2" ]; then
      echo "Please provide the name of the path you want to remove (you can use 'path-ls' to see all available paths)!"
      exit 1
    fi
    
    if [ "$2" = "home" ]; then
      echo "Sorry, you can't delete this path. While I am not lazy enough to not create this script, I am lazy enough to not find a better way to implement the paths list, and this is my fallback! ¯\_(ツ)_/¯"
      echo "Since contributions are more than welcome, if you can and want to make this script better, please make a pull request here: https://github.com/Dimitris-Provatas/dev-script"
      exit 1
    fi

    sed -i -e "/^paths\[$2\]/d" $SCRIPT
    echo "Path '$2' deleted from your paths list."
    ;;
  "path-ls")
    for key val in "${(@kv)paths}"; do
      echo "$key: $val"
    done
    ;;
  "")
    echo "No argument provided. Type 'help' to see the available options."
    exit 1
    ;;
  *)  
    if [[ ! -z $paths[$1] ]]; then
      echo "Opening '$paths[$1]' with $EDITOR..."
      sleep 0.5
      $EDITOR $paths[$1]
    else
      echo "Opening '$1' with $EDITOR..."
      sleep 0.5
      $EDITOR $1
    fi
    ;;
esac

exit 0