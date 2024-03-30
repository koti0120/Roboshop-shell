#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo " Script started executing at $TIMESTAMP " &>> $LOGFILE

VALIDATE() {
    if [ $1 -ne 0 ]
    then
    echo -e " ERROR:: $2 $R FAILED $N "
    exit 1
    else
    echo -e " $2 is $G SUCESS $N "
    fi
}

if [ $ID -ne 0 ]
then
echo -e " $R ERROR:: THIS SCRIPT CAN BE RUN ONLY ROOT USER $N "
exit 1 #we can give other than 0
else
echo -e " $G This is root user $N "
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "COPIED MONGO REPO"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "installing mongodb"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enable the mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "start the mongodb"

sed -i '/s/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "remote access for mongodb"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "restarting the mongodb"
