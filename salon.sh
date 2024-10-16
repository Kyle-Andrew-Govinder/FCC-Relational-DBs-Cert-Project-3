#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

function MAIN_MENU () {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to Kyle's Salon.\nWhat service would you like to make an appointment for:\n"

  SERVICES=$($PSQL "SELECT * FROM services")

  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  echo 
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]$ ]]
  then
    
    MAIN_MENU "Invalid selection."
  
  else

    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_ID ]]
    then

      echo -e "\nPlease enter your name:"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    else 

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    fi

    echo -e "\nPlease enter a time for your appointment:"
    read SERVICE_TIME

    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

    if [[ -z $INSERT_APPOINTMENT ]]
    then

      MAIN_MENU "An error has occured."

    else

      SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

      echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."

    fi

  fi

}

MAIN_MENU

