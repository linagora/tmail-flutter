#!/bin/sh
set -e
# report-uri is the reporting form this image can express with one header.
# report-to would also need a Reporting-Endpoints header. Empty means no directive.
uri=${CSP_REPORT_URI:-}
if [ -z "$uri" ]; then
  exit 0
fi
# One http(s) URL. A space, quote or semicolon would break the header or add a directive.
if ! printf '%s\n' "$uri" | grep -Eq '^https?://[A-Za-z0-9._~:/?#@!$&()*+,=%-]+$'; then
  echo "CSP_REPORT_URI must be a single http or https URL" >&2
  exit 1
fi

conf=/etc/nginx/csp-headers.conf
if [ ! -f "$conf" ]; then
  echo "missing $conf" >&2
  exit 1
fi
tmp=$(mktemp)
found=0
marker='add_header Content-Security-Policy-Report-Only "'
suffix='" always;'
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    "$marker"*)
      case "$line" in
        *"$suffix")
          prefix=${line%"$suffix"}
          printf '%s report-uri %s%s\n' "$prefix" "$uri" "$suffix"
          found=$((found + 1))
          ;;
        *)
          echo "report-only header is not in the expected shape" >&2
          exit 1
          ;;
      esac
      ;;
    *)
      printf '%s\n' "$line"
      ;;
  esac
done < "$conf" > "$tmp"
if [ "$found" -ne 1 ]; then
  echo "report-only header was not updated" >&2
  exit 1
fi
mv "$tmp" "$conf"
