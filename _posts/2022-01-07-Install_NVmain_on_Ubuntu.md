---
layout:     post
title:      Install NVmain from Github 2022
subtitle:   How to install NVmain from Github 2022
date:       2022-01-07
author:     xyzzhangfan
header-img: img/post-bg-kuaidi.jpg
catalog: true
tags:
    - NVmain
    - Linux
---

# Install NVmain from Github 2022

## The NVmain github reporsitory is outdated, if you try to compile it by yourself you may encounter errors such as:  ``` ImportError: No module named gem5_scons:```, ``` FlipNWrite.cpp:131:35: error: implicitly-declared ‘constexpr NVM::NVMAddress::NVMAddress(const NVM::NVMAddress&)’ is deprecated [-Werror=deprecated-copy]``` , etc. 

## The following steps are tested on Ubuntu 20.04

1. ```Git clone https://github.com/SEAL-UCSB/NVmain.git```
2. install scons : ```pip install scons```
3. if you are using python3 you need conver both SConstruct and SConscript using command ```2to3 -w ./SConstruct```  and ```2to3 -w ./SConscript``` 
4. Comment out ``` from gem5_scons import Transform``` from 36 lines in ```./SConscript```
5. Add the following CCFLAG in to SConstruct to avoid error: ```env.Append(CCFLAGS='-Wno-error=deprecated-copy')```  I am using fast mode so I add it at 35 line. Ref: (https://stackoverflow.com/questions/51863588/warning-definition-of-implicit-copy-constructor-is-deprecated)
6. Run  ```scons --build-type=fast to build NVmain```
7. Test ```./nvmain.fast Config/PCM_ISSCC_2012_4GB.config ```![Screen Shot 2022-01-07 at 11.09.18 AM](https://raw.githubusercontent.com/xyzzhangfan/pictures/main/img/Screen%20Shot%202022-01-07%20at%2011.09.18%20AM.png)

