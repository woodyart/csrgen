#!/bin/bash
# The script will generate new CSR from previously generated CSR or CRT/PEM file

function help {
  echo -n "The script will generate new CSR from previously generated CSR or CRT/PEM file
  SCRIPT ARGS:
  $0 -s <source_file> -k <new_key_file> -c <new_csr_file> -y

  -s - path to CSR or CRT/PEM file you want to update (Required)
  -k - path to export new KEY file (Required)
  -c - path to export new CSR file (Required)
  -y - overwrite new KEY and CSR file if exists
  -h - this help

  EXAMPLE:
  $0 -s example.com.crt -k example.com_1.key -c example.com_1.csr"
  echo -e '\n'
}

function parse_csr {
  local CSR="$1"
  openssl req -noout -subject -in $CSR | sed -e 's/^subject=\ *//g'
}

function parse_crt {
  local CERT="$1"
  openssl x509 -noout -subject -in $CERT | sed -e 's/^subject=\ *//g'
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
  if [[ $(echo "$TYPE" | grep -q "PEM certificate") ]]; then {
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
  if [[ -z $REWRITE ]]; then {
    check_dest "$NEW_CSR"
    check_dest "$NEW_KEY"
  }
  fi

  SUBJ=$(get_subject "$OLD_CRT" )
  generate_csr "$SUBJ" "$NEW_KEY" "$NEW_CSR"
}

################################################################################
while getopts ":s:k:c:yh" arg; do
  case "${arg}" in
    s) OLD_CRT=${OPTARG};;
    k) NEW_KEY=${OPTARG};;
    c) NEW_CSR=${OPTARG};;
    y) REWRITE="true";;
    h)
      help
      exit 0
      ;;
    *)
      echo -e "ERROR: Unknown argument: ${OPTARG}. Read the HELP first\n"
      help
      exit 1
      ;;
  esac
done

if [[ -z $OLD_CRT || -z $NEW_KEY || -z $NEW_CSR ]]; then
  echo -e "ERROR: One or more required parameters undefined\n"
  help
  exit 1
else
  main "$OLD_CRT" "$NEW_KEY" "$NEW_CSR" "$REWRITE"
fi
