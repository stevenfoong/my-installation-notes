#!/usr/bin/env bash
# webcheck.sh - check a website's HTTP status normally, and optionally
#               against a specific IP (with SSL certificate validation).
#
# Usage: ./webcheck.sh <domain> [ipv4]
#   ./webcheck.sh abc.example.com
#   ./webcheck.sh abc.example.com 8.8.8.8

set -u

TIMEOUT=10   # seconds to connect; total max time is double this

usage() {
  echo "Usage: $0 <domain> [ipv4]" >&2
  exit 2
}

# Domain: labels of letters/digits/hyphens (not starting/ending with hyphen),
# at least one dot, alphabetic TLD, total length <= 253.
is_domain() {
  local d=$1
  (( ${#d} <= 253 )) || return 1
  [[ $d =~ ^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$ ]]
}

# IPv4: four octets, each 0-255.
is_ipv4() {
  local ip=$1 o
  [[ $ip =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]] || return 1
  for o in "${BASH_REMATCH[@]:1}"; do
    (( 10#$o <= 255 )) || return 1
  done
}

# Human-readable reason for common OpenSSL verify codes.
verify_reason() {
  case $1 in
    10) echo "certificate has expired" ;;
    9)  echo "certificate is not yet valid" ;;
    18) echo "self-signed certificate" ;;
    19) echo "self-signed certificate in chain" ;;
    20) echo "unable to get local issuer certificate (incomplete chain?)" ;;
    21) echo "unable to verify the first certificate (incomplete chain?)" ;;
    62) echo "hostname mismatch" ;;
    *)  echo "verify code $1" ;;
  esac
}

# ---- argument checks -------------------------------------------------------
[[ $# -ge 1 && $# -le 2 ]] || usage

DOMAIN=${1,,}        # lowercase
DOMAIN=${DOMAIN%.}   # drop trailing dot if any
IP=${2:-}

is_domain "$DOMAIN" || { echo "Error: '$1' is not a valid domain name" >&2; exit 2; }
if [[ -n $IP ]] && ! is_ipv4 "$IP"; then
  echo "Error: '$IP' is not a valid IPv4 address" >&2
  exit 2
fi

URL="https://$DOMAIN/"
CURL_OPTS=(-s -o /dev/null --connect-timeout "$TIMEOUT" --max-time $((TIMEOUT * 2)))

# ---- 1) normal check (public DNS) -----------------------------------------
code=$(curl "${CURL_OPTS[@]}" -w "%{http_code}" "$URL"); rc=$?
echo "[1] $URL (DNS)"
echo "    HTTP status : $code"
(( rc != 0 )) && echo "    curl error  : exit code $rc"

[[ -z $IP ]] && exit 0

# ---- 2) check against given IP: status + cert in one call -----------------
# Strict call (no -k): success means the cert is valid for this hostname.
RESOLVE=(--resolve "$DOMAIN:443:$IP")
code=$(curl "${CURL_OPTS[@]}" "${RESOLVE[@]}" -w "%{http_code}" "$URL"); rc=$?

echo "[2] $URL -> $IP"
if (( rc == 0 )); then
  echo "    HTTP status : $code"
  echo "    SSL cert    : VALID"
elif (( rc == 60 || rc == 51 )); then
  # Cert failed: repeat with -k to still get the status and the reason.
  out=$(curl "${CURL_OPTS[@]}" -k "${RESOLVE[@]}" \
        -w "%{http_code} %{ssl_verify_result}" "$URL")
  read -r code verify <<< "$out"
  echo "    HTTP status : $code"
  echo "    SSL cert    : INVALID ($(verify_reason "${verify:-?}"))"
  exit 1
else
  echo "    HTTP status : $code"
  echo "    SSL cert    : UNKNOWN (connection failed, curl exit code $rc)"
  exit 1
fi
