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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disable node js"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enable nodejs18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "install nodejs"

id roboshop #if roboshop user does not exist, then it is failure

if [ $? -ne 0 ]
then
useradd roboshop 
VALIDATE $? "roboshop user creation"
else
echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "installing catalogue"

cd /app &>> $LOGFILE

VALIDATE $? "change to app"


unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping catalogue"

npm install &>> $LOGFILE

VALIDATE $? "npm installation"

cp /home/centos/Roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copied catalogue.service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "start catalogue"

cp /home/centos/Roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copy mongo.repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "install mongodb client"

mongo --host mongodb.kanakam.top </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "load schema"