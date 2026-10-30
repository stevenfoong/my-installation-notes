# webcheck.sh

Checks a website's HTTPS status, and optionally checks it against a specific
server IP (bypassing DNS) while validating the SSL certificate.

Useful for testing an origin server directly, verifying a new server before a
DNS cutover, or confirming a certificate is installed correctly on one IP.

## Requirements

- `bash` 4+
- `curl`

## Installation

```bash
chmod +x webcheck.sh
```

## Usage

```bash
./webcheck.sh <domain> [ipv4]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `domain` | Yes | Domain name, e.g. `abc.example.com` |
| `ipv4`   | No  | IPv4 address to send the request to instead of the DNS result |

### Domain only

Runs a normal request using public DNS:

```bash
./webcheck.sh abc.example.com
```

```
[1] https://abc.example.com/ (DNS)
    HTTP status : 200
```

Equivalent to:

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://abc.example.com/
```

### Domain and IP

Runs the normal request, then sends the request to the given IP with
`--resolve`, returning the HTTP status and SSL certificate validity:

```bash
./webcheck.sh abc.example.com 203.0.113.10
```

```
[1] https://abc.example.com/ (DNS)
    HTTP status : 200
[2] https://abc.example.com/ -> 203.0.113.10
    HTTP status : 200
    SSL cert    : VALID
```

Equivalent to:

```bash
curl -s -o /dev/null -w "%{http_code}\n" --resolve abc.example.com:443:203.0.113.10 https://abc.example.com/
```

## SSL certificate results

| Result | Meaning |
|--------|---------|
| `VALID` | Certificate is trusted and matches the domain |
| `INVALID (<reason>)` | Certificate failed verification; the HTTP status is still shown (fetched with `-k`) |
| `UNKNOWN` | Could not connect (timeout, refused, TLS handshake failure); the curl exit code is shown |

Common `INVALID` reasons:

- certificate has expired
- certificate is not yet valid
- self-signed certificate / self-signed certificate in chain
- unable to get local issuer certificate (incomplete chain?)
- hostname mismatch

An HTTP status of `000` means no HTTP response was received.

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | Checks completed; certificate valid (when an IP was given) |
| `1` | Certificate invalid, or connection to the IP failed |
| `2` | Invalid input (bad domain, bad IP, wrong number of arguments) |

## Input validation

- **Domain**: letters, digits and hyphens per label (no leading/trailing
  hyphen), at least one dot, alphabetic TLD, max 253 characters. Converted to
  lowercase; a trailing dot is removed.
- **IP**: IPv4 only, four octets of 0–255.

## Notes

- Port 443 (HTTPS) only.
- Connect timeout is 10 seconds and total timeout 20 seconds; change
  `TIMEOUT` at the top of the script to adjust.
