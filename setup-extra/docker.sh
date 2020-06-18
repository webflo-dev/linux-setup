#!/bin/bash

groupadd docker;
usermod -aG docker $USER;
systemctl enable docker;
