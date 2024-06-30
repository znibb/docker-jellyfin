#!/bin/bash
if [ ! -f .env ]; then
  cp ./files/.env.example .env
fi