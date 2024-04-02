#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/etc/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y  &>> $LOGFILE

VALIDATE $? "disable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enable nodejs18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "install nodejs"

id roboshop
if [ $? -ne 0 ]
then
useradd roboshop
VALIDATE $? "useradd creation"
else
echo -e "already existing user $Y SKIPPING $N "

fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloading user file"

cd /app &>> $LOGFILE

VALIDATE $? "change the directory"

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user file"

npm install &>> $LOGFILE

VALIDATE $? "install npm"

cp /home/centos/Roboshop-shell/user.service /etc/systemd/system/user.service  &>> $LOGFILE

VALIDATE $? "COPIED USER.SERVICE"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "ENABLE USER"

systemctl start user &>> $LOGFILE

VALIDATE $? "START USER"

cp /home/centos/Roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "install mongodb-org-shell"

mongo --host mongodb.kanakam.top </app/schema/user.js &>> $LOGFILE

VALIDATE $? "load the schema"