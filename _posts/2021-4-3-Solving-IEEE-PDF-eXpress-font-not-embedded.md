---
layout:     post
title:      How to solve the error "Errors Font Helvetica, Times-Roman is not embedded" in IEEE PDF eXpress
subtitle:   Solving with Adobe acrobat
date:       2021-04-03
author:     xyzzhangfan
header-img: img/post-bg-rwd.jpg
catalog: 	 true
tags:
  - PDF
  - Adobe acrobat
  - IEEE PDF eXpress
---

## How to solve the error "Errors: Font Helvetica,  Times-Roman is not embedded " in IEEE PDF eXpress



This error is due to some fonts in your uploaded PDF is not embedded. In my case, I have some figures saved as pdf format. Those figures contain the un-embedded fonts. So what I need to do is finding which figure contains the un-embedded fonts then convert it to embedded fonds. This step can be easily done by using Adobe acrobat with the following steps.

1. First, check the document properties by right clicking on the image then choose "Document Properties". In the font tag you will see if there is any font is not embedded. 

   ![Properties](https://raw.githubusercontent.com/xyzzhangfan/pictures/main/img/20210403005922.png)

   ![before_conversion](https://raw.githubusercontent.com/xyzzhangfan/pictures/main/img/20210403005935.png)

2. Clicking the File ==> Save as Other ==> Optimized PDF...

   ![save_as](https://raw.githubusercontent.com/xyzzhangfan/pictures/main/img/20210403005917.png)

3. In the poped out new window change the marked region to "Acrobat 4.0 and later". Then click "OK" and save it.

   ![Screen Shot 2021-04-03 at 12.25.34 AM](https://raw.githubusercontent.com/xyzzhangfan/pictures/main/img/20210403005912.png)

4. Open the file you just saved, and check the "Document Properties" again. You should see all fonts are embedded now.

   ![after_conversion](https://raw.githubusercontent.com/xyzzhangfan/pictures/main/img/20210403005906.png)

5. Re-compile your manuscript and upload to IEEE-PDF-eXpress again, you should not have this error anymore. 



