#!/bin/bash
# The script will generate new CSR from previously generated CSR or CRT/PEM file

# args:
# -s --source - source CSR or CRT/PEM file
# -c --csr    - new CSR file location
# -k --key    - new KEY file location
# -y --overwrite - overwrite existings files
# -h --help   - this help

function parse_csr (FILE) {
  openssl req -noout -subject -in $FILE
}

function parse_crt (FILE) {
  openssl x509 -noout -subject -in $FILE
}

function get_subject (FILE) {
  TYPE=$(file -b $FILE)
  case $TYPE in
    "PEM certificate")
      parse_crt($FILE)
      exit 0
      ;;
    "PEM certificate request")
      parse_csr($FILE)
      exit 0
      ;;
    *)
      echo "Error parse file: $FILE. Type is not correct: $TYPE"
      exit 1
      return 1
      ;;
  esac
}

function check_dest (FILE) {
  if file exist ask y/n to rewrite
}

function generate_csr (SUBJ, CSR, KEY) {
  openssl req -new\
              -newkey rsa:4096\
              -nodes\
              -sha256\
              -subj "$SUBJ"\
              -keyout $KEY\
              -out $CSR
}

function main (OLD_FILE, CSR, KEY) {
  check_dest(CSR)
  check_dest(KEY)
  SUBJ=$(get_subject($OLD_FILE))
  generate_csr($SUBJ, $CSR, $KEY)
}

main ($1, $2, $3)
