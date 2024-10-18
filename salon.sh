#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  echo -e "Welcome to My Salon, how can I help you?\n"

  SERVICES_MENU
}


SERVICES_MENU(){
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done 
  read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]*$ ]]
  then
    # send to services menu 
    SERVICES_MENU "Please enter a number."
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # if service_name doesnt exist 
    if [[ -z $SERVICE_NAME ]]
    then
      # send to services menu
      SERVICES_MENU "Please select a valid service."
    else
      # input phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      
      # check if they are a customer
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if they are not a customer
      if [[ -z $CUSTOMER_NAME ]]
      then
        # ask for their name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # insert customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # ask for time
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME"
      read SERVICE_TIME

    fi
  fi

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
