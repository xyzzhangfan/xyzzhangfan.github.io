---
layout:     post
title:      How to measure the power in Cadence Virtuoso
subtitle:   Solving with Adobe acrobat
date:       2021-08-13
author:     xyzzhangfan
header-img: img/post-bg-rwd.jpg
catalog: 	 true
tags:
  - Candence Virtuoso
  - Power Measurement
---

## How to measure the power in Cadence Virtuoso

1\. In ADE-L choose Outputs --> Save All

![Screen Shot 2021-08-13 at 7.37.49 PM](https://raw.githubusercontent.com/xyzzhangfan/pictures/main/img/20210813194158.png)

2\. Select the pwr in output. 

![Screen Shot 2021-08-13 at 7.36.53 PM](https://raw.githubusercontent.com/xyzzhangfan/pictures/main/img/20210813194211.png){: width="100%" }

3\. Run the simulation, in the wave window select Browser --> Results --> Opern Results,. Then select the pdf file.



![Screen Shot 2021-08-13 at 7.38.22 PM](https://raw.githubusercontent.com/xyzzhangfan/pictures/main/img/20210813194225.png)

4\. In the resule browse windows, select tran to see the total power(pwr) or instance power(@[instance name] pwr)

![Screen Shot 2021-08-13 at 7.38.38 PM](https://raw.githubusercontent.com/xyzzhangfan/pictures/main/img/20210813194234.png)

5\. Right click pwr to open calculator for average/peak power expression. 
