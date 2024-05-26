#!/bin/bash

# Clona os repositórios
git clone https://github.com/jeffev/investlink_backend.git
git clone https://github.com/jeffev/investlink_frontend.git
git clone https://github.com/jeffev/investlink_data_science_pipeline.git

# Inicia o docker-compose
docker-compose -f ../docker-compose.yml up --build