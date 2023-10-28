---
layout:     post
title:      Docker Insufficient shared memory (shm) Error
subtitle:   
date:       2023-10-27
author:     xyzzhangfan
header-img: img/post-bg-kuaidi.jpg
catalog: true
tags:
    - Pytorch
    - Nvidia
    - Docker
---


When I running a training experiment in docker I got the following error message:
```
ERROR: Unexpected bus error encountered in worker. This might be caused by insufficient shared memory (shm).
```
The solution is adding the argument "--ipc=host" when running the docker container.

References:
- https://docs.docker.com/engine/reference/run/#ipc-settings---ipc
- https://discuss.pytorch.org/t/training-crashes-due-to-insufficient-shared-memory-shm-nn-dataparallel/26396
