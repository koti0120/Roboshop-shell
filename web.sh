#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

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

dnf install nginx -y &>> $LOGFILE

VALIDATE $? "install nginx"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "enable nginx"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*  &>> $LOGFILE

VALIDATE $? "removing default one"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "web download"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "change directory"

unzip -o /tmp/web.zip &>> $LOGFILE

VALIDATE $? "unzipping"

cp /home/centos/Roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf  &>> $LOGFILE

VALIDATE $? "copied roboshop conf"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "restart nginx"