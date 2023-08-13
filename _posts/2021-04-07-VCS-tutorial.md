---
layout:     post
title:      Using VCS and DVE to simulate Verilog Code
subtitle:   VCS 
date:       2021-04-07
author:     xyzzhangfan
header-img: img/post-bg-rwd.jpg
catalog: 	 true
tags:
  - VCS
  - Verilog
  - Chip Design
---


## Using VCS and DVE to simulate Verilog Code

1. Writing Verilog with any text editor(i.e. Vim/VS code/Sublime text)

2. Run VCS with the following command:

   ``` bash
   vcs -Mupdate -RPP -v [YOU_Design_files.v] -o demo -full64 -debug_all
   # For example:
   vcs '-Mupdate' '-RPP' '-sverilog' 'stdlib_10lpe_ccs_20210527.v' 'tb_Top_decoder_wo_scan_chain.sv' 'Top_decoder_wo_scan_chain.sv' 'WL_decoder_state_machine.4.0.syn.v' 'SL_decoder_state_machine.4.0.syn.v' 'BL_decoder_no_state_machine.4.0.syn.v' 'Logical_part.syn.v' '-top' 'tb_top_wo_scan_chain' '-o' 'decoder_wo_scan_chain' '-full64' '-debug_all'
   ```

3. A executable demo file now appared in your current folder. Run it with GUI:

   ``` bash
   ./demo -gui
   ```

4. DVE now opened with your design. Select the signals then right click them, choose add waves -> new waves. 
5. From Simulator -> Start to start the simulation, you now should have the waves.
