#!/bin/bash

OUTPUT="/home/motopp/uptime-report/index.html"
TIMESTAMP=$(date -Iseconds)

# ----------------------------
# HTML HEADER + STYLES
# ----------------------------
cat > $OUTPUT <<EOF
<html>
<head>
<meta http-equiv="refresh" content="5">
<title>Uptime Dashboard</title>

<style>
body {
  font-family: Arial;
  background: #111;
  color: #eee;
}

table {
  border-collapse: collapse;
  width: 60%;
}

th, td {
  padding: 10px;
  border: 1px solid #333;
}

.up {
  color: #00ff6a;
  font-weight: bold;
}
.down {
  color: #ff3b3b;
  font-weight: bold;
}
</style>

</head>
<body>

<h2>Uptime Dashboard</h2>
<p>Last update: $TIMESTAMP</p>

<table>
<tr><th>Service</th><th>Status</th></tr>
EOF

# ----------------------------
# FRONTEND CHECK
# ----------------------------
# ----------------------------
# FRONTEND CHECK
# ----------------------------
check_frontend () {
  NAME=$1
  URL=$2
  EXPECTED_TEXT=$3

  HTTP_CODE=$(curl -o /tmp/body.html -s -w "%{http_code}" --max-time 10 "$URL")
  BODY=$(cat /tmp/body.html)

  # treat redirects as healthy
  if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 301 ] || [ "$HTTP_CODE" -eq 302 ] || [ "$HTTP_CODE" -eq 308 ]; then

    # only check content if it's a real page (200)
    if [ "$HTTP_CODE" -eq 200 ]; then
      if echo "$BODY" | grep -q "$EXPECTED_TEXT"; then
        STATUS="<span class='up'>UP</span>"
      else
        STATUS="<span class='down'>DOWN (content mismatch)</span>"
      fi
    else
      STATUS="<span class='up'>UP</span>"
    fi

  else
    STATUS="<span class='down'>DOWN ($HTTP_CODE)</span>"
  fi

  echo "<tr><td>$NAME (frontend)</td><td>$STATUS</td></tr>" >> $OUTPUT
}

# ----------------------------
# BACKEND CHECK
# ----------------------------

check_backend () {
  NAME=$1
  URL=$2

  STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}" --max-time 10 "$URL")

  if [ "$STATUS_CODE" -eq 200 ]; then
    STATUS="<span class='up'>UP</span>"
  else
    STATUS="<span class='down'>DOWN ($STATUS_CODE)</span>"
  fi

  echo "<tr><td>$NAME (backend)</td><td>$STATUS</td></tr>" >> $OUTPUT
}

# ----------------------------
# SERVICES
# ----------------------------
check_frontend "dev" "https://eap-it33.motoppdemo.nl/dev" "html"
check_frontend "test" "https://eap-it33.motoppdemo.nl/test" "html"
check_frontend "prod" "https://eap-it33.motoppdemo.nl" "html"

check_backend "api-dev" "https://eap-it33.motoppdemo.nl/api-dev/health"
check_backend "api-test" "https://eap-it33.motoppdemo.nl/api-test/health"
check_backend "api-prod" "https://eap-it33.motoppdemo.nl/api/health"

# ----------------------------
# FOOTER
# ----------------------------
cat >> $OUTPUT <<EOF
</table>
</body>
</html>
EOF
