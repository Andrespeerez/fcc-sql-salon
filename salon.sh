#!/bin/bash
# Salon servicies and appointments
PSQL="psql --username=freecodecamp --dbname=salon -t -c"
RED='\033[0;31m'
NC='\033[0m'

MAIN_MENU() {
  # Return to MAIN_MENU argument
  echo -e $1
  # list all services
  echo -e "How can I help you?"
  echo -e "0) EXIT"
  echo -e "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  # if selection is not valid number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]*$ ]]
  then
    # main menu
    MAIN_MENU "\nYour selection is not valid.\n${RED}Try to write a number.${NC}\n"
  # exit option
  elif [[ $SERVICE_ID_SELECTED = 0 ]]
  then
    EXIT
  else
    # get service
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    # if service is not found
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then
      # main menu
      MAIN_MENU "\nWe don't have that service.\n${RED}Try with a number on the list.${NC}\n"
    else
      # get phone
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      # if phone is empty
      if [[ -z $CUSTOMER_PHONE ]]
      then
        # main menu
        MAIN_MENU "${RED}You must introduce a phone\n.${NC}"
      else      
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        # if customer is not found
        if [[ -z $CUSTOMER_NAME ]]
        then
          # add customer name
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          # get customer info
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          if [[ -z $CUSTOMER_ID ]]
          then
            MAIN_MENU "\n${RED}You must introduce a unique, not empty, phone and name.${NC}\n"
          fi
        fi
        # ask for an hour
        echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
        read SERVICE_TIME
        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  fi

}

EXIT() {
  echo -e "\n ~~~ See you! ~~~ \n"
}

MAIN_MENU "\n~~~ SALON SERVICES ~~~\n"