---
layout:     post
title:      Some Usefull Commands in Cadence
subtitle:   Commands in Cadence
date:       2021-03-31
author:     xyzzhangfan
header-img: img/post-bg-rwd.jpg
catalog: 	 true
tags:
  - Cadence
  - Linux
  - bash
---

### Unlock file in cadence

```bash
find . -name '*.cdslck' -exec rm {} \;
```

***

### Source ic617.cshrc  

``` bash
echo "alias cadence_tool 'source /usr/local/cadence/IC617.cshrc; cd ~/cadence617;virtuoso&'" >> ~/.tcshrc
```

***
### Change default simulator to spectre:

In .cdsenv:
```
asimenv.startup       simulator       string  "spectre"
```
In .cdsini:
```
	    (if (isFile "./.cdsenv")
		(envLoadVals 
		 ?envFile "./.cdsenv"
		 ?tool "ALL"))
```

***

### add models in default:

In .cdsini:

    asiSetEnvOptionVal(asiGetTool('spectre) "modelFiles"
    	list(
    	list("/usr/local/cadence/NCSU/ncsu-cdk-1.5.1/models/spectre/standalone/tsmc25N.m")
    	list("/usr/local/cadence/NCSU/ncsu-cdk-1.5.1/models/spectre/standalone/tsmc25P.m")
    	)
         )

***

### Check the VNC session number:
```bash
ps -ef | grep `whoami` | grep vnc | grep Xorg
```

***
