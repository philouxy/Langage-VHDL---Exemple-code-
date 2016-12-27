# Project 2 - Jungler

PROJECT IN PROGRESS

With an electronics board created by the ETML-ES School and equiped with a FPGA, realization / Simulation of a juggler with the both 7 Segments Display 

* Segments '''A''' / '''E''' / '''F''' of Display A will be used   
* Segments '''A''' / '''B''' / '''C''' of Display B will be used 
* Using of PEC12 to start the juggling  
* Reset to stop the juggling 
* 4 switches used for the mode of juggling   
* PEC12 to use the speed choice of juggling (to 0,5 Hz at 2 Hz) 

Implementation Code 
-------------------
* Realized a cycle counter of 2Hz to do turned the segments in clockwise (Way: F1 -> E1 -> A1 -> A2 -> B2 -> C1... it is continuous [DONE]
* With a push (> 1s) on the S9 Switch, the cycle must stopped if after a new push on this button, the cycle must be the opposite at the first, if a new push again the cylce must stopped and to finish if still a push, the cycle set out again at the start cycle [DONE]
