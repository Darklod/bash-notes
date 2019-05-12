#!/bin/bash

VERSION=v1.0.1
EDITOR="vim"
EXT="note"
FOLDER=~/Notes
NOTES=($FOLDER/*.$EXT)

# TODO: configuration file command
# TODO: folder/editor/order options

# ---------------------------------------------- #

create () {
  case "$1" in
    -h | --help)
      createUsage
      exit
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag \"$1\"" >&2
      exit 1
      ;;
    *)
      NOTE_TITLE=$1
      NOTE_TITLE=$(echo "$NOTE_TITLE" | tr '[:upper:]' '[:lower:]')

      if [[ -z $NOTE_TITLE ]]; then
        echo "Error: Invalid Title \"$NOTE_TITLE\"" >&2
        exit 1
      fi

      if [[ ! -f "$FOLDER/$NOTE_TITLE.$EXT" ]]; then
        touch "$FOLDER/$NOTE_TITLE.$EXT"
      else
        read -p "Warning: Note exists yet. Overwrite it? (y/n) " input
        if [[ $input != "y" ]]; then
          exit 1
        else 
          echo "" > "$FOLDER/$NOTE_TITLE.$EXT"
        fi
      fi

      $EDITOR "$FOLDER/$NOTE_TITLE.$EXT"
      shift 1
      ;;
  esac

  # echo "$@" ignore other params
}

delete () {
  case "$1" in
    -h | --help)
      deleteUsage
      exit
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag \"$1\"" >&2
      exit 1
      ;;
    *)
      while (( "$#" )); do
        INDEX=$1

        if [[ ! $INDEX =~ ^[0-9]+$ ]] || [[ $INDEX -ge ${#NOTES[@]} ]] || [[ $INDEX -lt 0 ]]; then
          echo "Error: Invalid index \"$INDEX\"" >&2
          exit 1
        fi

        # confirm message
        rm "${NOTES[$INDEX]}"
        filename=$(basename "${NOTES[$INDEX]}")
        echo "${filename%.*} has been deleted"

        shift 1
      done
      ;;
  esac
}

show () {
  if [[ $1 != '' ]]; then
    while [[ $1 != '' ]]; do
      case "$1" in
        -h | --help)
          showUsage
          exit
          ;;
        --order) # TODO: process the order before show
          echo "order by $2"
          shift 2
          ;;
        all | notes)
          for i in "${!NOTES[@]}"; do
            filename=$(basename "${NOTES[$i]}")
            filename="$(tr '[:lower:]' '[:upper:]' <<< ${filename:0:1})${filename:1}"

            if hash stat 2>/dev/null; then
              birth=$(stat -c %w ${NOTES[$i]})
              if [[ $birth == "-" ]]; then
                birth="????-??-??"
              fi
              printf "(%s) [%s] %s\n" "$i" "${birth%% *}" "${filename%.*}"
            else
              printf "(%s) %s\n" "$i" "${filename%.*}"
            fi
          done
          shift 1
          ;;
        note)
          INDEX=$2

          if [[ ! $INDEX =~ ^[0-9]+$ ]] || [[ $INDEX -ge ${#NOTES[@]} ]] || [[ $INDEX -lt 0 ]]; then
            echo "Error: Invalid index \"$INDEX\"" >&2
            exit 1
          fi

          $EDITOR "${NOTES[$INDEX]}"

          shift 2
          ;;
        -*|--*=) # unsupported flags
          echo "Error: Unsupported flag \"$1\"" >&2
          exit 1
          ;;
        *)
          echo "Error: Invalid command \"$1\"" >&2
          exit 1
          ;;
      esac
    done
  else
    echo "Error: Invalid command \"$1\"" >&2
    exit 1
  fi
}

# ---------------------------------------------- #

globalUsage () {
  echo "Usage: notes <command> [options]"
  echo ""
  echo "Options:"
  printf "  -h, --help	           \toutput usage information\n"
  printf "  -v, --version	         \toutput the version number\n"
  printf "  -e, --editor <editor>  \tuse a different editor\n"
  printf "  -f, --folder <folder>  \tuse a different folder\n"
  echo ""
  echo "Commands:"
  printf "  add <filename>	      \tcreate new note\n"
  printf "  delete <index(es)>	  \tdelete a note\n"
  printf "  show <command>        \tshow and open notes\n"
  echo ""
  echo "Run notes <command> --help for detailed usage of given command."
}

createUsage () {
  echo "Usage: add [options] <filename>"
  echo ""
  echo "create new note"
  echo ""
  echo "Options:"
  printf "  -h, --help	           \toutput usage information\n"
  printf "  -e, --editor <editor>  \tuse a different editor\n"
  printf "  -f, --folder <folder>  \tuse a different folder\n"
}

deleteUsage () {
  echo "Usage: delete [options] <index(es)>"
  echo ""
  echo "delete a note"
  echo ""
  echo "Options:"
  printf "  -h, --help	           \toutput usage information\n"
  printf "  -e, --editor <editor>  \tuse a different editor\n"
  printf "  -f, --folder <folder>  \tuse a different folder\n"
}

showUsage () {
  echo "Usage: show <command> [options]"
  echo ""
  echo "show and open notes"
  echo ""
  echo "Options:"
  printf "  -h, --help	           \toutput usage information\n"
  printf "  -e, --editor <editor>  \tuse a different editor\n"
  printf "  -f, --folder <folder>  \tuse a different folder\n"  
  echo ""
  echo "Commands:"
  printf "  notes, all             \tshow notes list\n"
  printf "  note <index>           \topen a note\n"
}

# ---------------------------------------------- #

while (( "$#" )); do
  case "$1" in
    -h | --help)
      globalUsage
      exit
      ;;
    -v | --version)
      echo "$VERSION"
      exit
      ;;
    add)
      shift 1
      create "$@" # pass remaining args
      exit
      ;;
    delete)
      shift 1
      delete "$@" # pass remaining args
      exit
      ;;
    show)
      shift 1
      show "$@" # pass remaining args
      exit
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) 
      echo "Error: Invalid command $1" >&2
      exit 1
      ;;
  esac
done

# show all notes by default
if [[ $# == 0 ]]; then
  notes show all
fi
