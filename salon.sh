#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

DISPLAY_SERVICES() {
  $PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id" | while read -r SERVICE_ROW
  do
    echo "$SERVICE_ROW" | xargs | tr -d '\r'
  done
}

DISPLAY_SERVICES

read SERVICE_ID_SELECTED

SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED" | xargs | tr -d '\r')

while [ -z "$SERVICE_ID_RESULT" ]
do
  echo -e "\nI could not find that service. What would you like today?"
  DISPLAY_SERVICES
  read SERVICE_ID_SELECTED
  SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED" | xargs | tr -d '\r')
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | xargs | tr -d '\r')

if [ -z "$CUSTOMER_NAME" ]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | xargs | tr -d '\r')
  $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" > /dev/null
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'" | xargs | tr -d '\r')
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | xargs | tr -d '\r')
CLEAN_SERVICE_NAME=$(echo "$SERVICE_NAME" | xargs | tr -d '\r')
CLEAN_CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | xargs | tr -d '\r')

echo -e "\nWhat time would you like your $CLEAN_SERVICE_NAME,$CLEAN_CUSTOMER_NAME?"
read SERVICE_TIME
CLEAN_SERVICE_TIME=$(echo "$SERVICE_TIME" | xargs | tr -d '\r')

$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$CLEAN_SERVICE_TIME')" > /dev/null

printf "I have put you down for a %s at %s, %s.\n" "$CLEAN_SERVICE_NAME" "$CLEAN_SERVICE_TIME" "$CLEAN_CUSTOMER_NAME"
