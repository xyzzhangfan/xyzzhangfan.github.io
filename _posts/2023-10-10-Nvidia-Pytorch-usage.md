---
layout:     post
title:      Nvidia Pytorch Usage
subtitle:   How to use Nvidia Pytorch with docker
date:       2023-10-10
author:     xyzzhangfan
header-img: img/post-bg-kuaidi.jpg
catalog: true
tags:
    - Pytorch
    - Nvidia
---


## Pulling the docker image
    ```bash
    docker pull nvcr.io/nvidia/pytorch:23.09-py3
    ```

## Runing the docker with 
   ```bash
   docker run --gpus all -it --rm -v ./:/data nvcr.io/nvidia/pytorch:23.09-py3
   ```


## Importing ASP to test it
   ```bash
   python
   from apex.contrib.sparsity import ASP
   ```