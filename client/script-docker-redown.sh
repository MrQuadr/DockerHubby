#!/bin/bash

sudo docker compose --profile network down
sudo docker compose --profile media down

sudo docker compose --profile network up -d --build --pull=always
sudo docker compose --profile media up -d --build --pull=always
