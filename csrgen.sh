#!/bin/bash
# The script will generate new CSR from previously generated CSR or CRT/PEM file

# args:
# -s --source - source CSR or CRT/PEM file
# -c --csr    - new CSR file location
# -k --key    - new KEY file location
# -y --overwrite - overwrite existings files
# -h --help   - this help

function parse_csr {
  local CSR="$1"
  openssl req -noout -subject -in $CSR | sed -e 's/^subject=\ *//g'
}

function parse_crt {
  local cert="$1"
  openssl x509 -noout -subject -in $CERT | sed -e 's/^subject=\ *\///g'
}

function get_subject {
  local FILE="$1"

  TYPE=$(file -b "$FILE")
  case $TYPE in
    "PEM certificate")
      parse_crt "$FILE"
      exit 0
      ;;
    "PEM certificate request")
      parse_csr "$FILE"
      exit 0
      ;;
  esac
}

function check_src {
  local FILE="$1"

  # Check 1
  if [[ ! -f $FILE ]]; then {
    echo "ERROR: File $FILE doesn't exist"
    exit 1
  }
  fi

  #Check 2
  TYPE=$(file -b "$FILE")
  if [[ $("$TYPE" | grep -q "PEM certificate") ]]; then {
    echo "Error parse file: $FILE. File type incorrect: $TYPE"
    exit 1
  }
  fi
}

function check_dest {
  local FILE="$1" REWRITE="$2"
  if [[ -f $FILE ]]; then {
    while true; do
      echo "File $FILE exist"
      read -p "Do you wish to rewrite it? " yn
      case $yn in
        [Yy]* )
          echo "Ok, I'll rewrite it"
          return 0
          ;;
        [Nn]* )
          echo "Exitting now. Bye-Bye!"
          exit;;
        * )
          echo "Please answer yes or no.";;
      esac
    done
  }
  fi
  #if file exist ask y/n to rewrite
  echo "dummy $FILE rewrite $REWRITE"
}

function generate_csr {
  local SUBJ="$1" NEW_KEY="$2" NEW_CSR="$3"
#  echo "openssl req -new -newkey rsa:4096 -nodes -sha256 -subj \"$1\" -keyout $2 -out $3"
  openssl req -new\
              -newkey rsa:4096\
              -nodes\
              -sha256\
              -subj "$SUBJ"\
              -keyout $NEW_KEY\
              -out $NEW_CSR
}

function main {
  local OLD_CRT="$1" NEW_KEY="$2" NEW_CSR="$3" REWRITE="$4"
  check_src  "$OLD_CRT"
  check_dest "$NEW_CSR"
  check_dest "$NEW_KEY"
  SUBJ=$(get_subject "$OLD_CRT" )
  generate_csr "$SUBJ" "$NEW_KEY" "$NEW_CSR"
}

################################################################################
OLD_CRT="$1"
NEW_KEY="$2"
NEW_CSR="$3"
REWRITE="$4"

main "$OLD_CRT" "$NEW_KEY" "$NEW_CSR" "$REWRITE"
