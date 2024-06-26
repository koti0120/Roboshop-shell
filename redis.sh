#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/$0-$TIMESTAMP.log

exec &>LOGFILE

echo "script start executing  $TIMESTAMP " &>> $LOGFILE

VALIDATE() {

if [ $1 -ne 0]
then
echo -e " $2... $R FAILED $N "
else
echo -e " $2 .. $G success $N "
fi

}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

VALIDATE $? "installing remi release"

dnf module enable redis:remi-6.2 -y

VALIDATE $? "enabling redis6.2"

dnf install redis -y

VALIDATE $? "install redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf

VALIDATE $? "remote access"

systemctl enable redis

VALIDATE $? "enable redis"

systemctl start redis

VALIDATE $? "start redis"