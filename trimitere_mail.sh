#!/bin/bash

API_KEY="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"

FROM_EMAIL="contact.dailymusicmix@gmail.com"
FROM_NAME="Proiect SO"
TO_EMAIL="$1"
SUBJECT="Cont creat cu succes"
CONTENT="Salut!\n Contul a fost creat pentru proiectul la SO"

JSON=$(cat <<EOF
{
  "sender": {
    "name": "$FROM_NAME",
    "email": "$FROM_EMAIL"
  },
  "to": [
    {
      "email": "$TO_EMAIL"
    }
  ],
  "subject": "$SUBJECT",
  "textContent": "$CONTENT"
}
EOF
)

RESPONSE=$(curl --silent --write-out "%{http_code}" --output brevo_error.txt \
  --request POST \
  --url https://api.brevo.com/v3/smtp/email \
  --header "api-key: $API_KEY" \
  --header "Content-Type: application/json" \
  --data "$JSON")

if [ "$RESPONSE" -eq 201 ]; then
  echo "Email trimis cu succes $TO_EMAIL"
else
  echo "Eroare la trimiere. Cod eroare: $RESPONSE"
  echo "Detalii: "
  cat brevo_error.txt
fi


