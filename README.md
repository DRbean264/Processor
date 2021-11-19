# Project - Single Cycle Processor
**Author: Yuzhe Ding (yd160); Aohua Zhang (az147)**
**Date: 11.18.2021**

## Description of the Circuit Diagram
>Below is the circuit diagram of our design:

![image](https://github.com/DRbean264/Processor/blob/master/IMG/processor_structure.png)
In order to accomodate the exception requirements which could be introduced by add/sub/addi these three operations, we add a **new control bit** (called **EXP**) and design some **new datapaths**.
For example, consider the instruction **add $1, $2, $3 with r2 = -2147483648 and r3 = -1**.
After processing this instruction, **r1 should store the overflow value 2147483647** while **rstatus should be set to 1**. Thus the RegFile may be written twice in one processor clock cycle.
In order to accommodate this requirement, we use the first half processor clock period to write back the normal data, while leveraging the second half to take care of writing the rstatus.

## Description of the Clock
>Below is the clock of our design.

![image](https://github.com/DRbean264/Processor/blob/master/IMG/clock_logic.png)

| Name        | Normal Freqency (Mhz)   | Max Frequency (Mhz) |  Trigger  |
| --------   | :-----:  | :-----:  | :----:  |
|Processor Clock      | 6.25 | 11.36 |  posedge   |
|RegFile Clock      | 12.5 | 22.73 |  posedge   |
|Imem Clock        |  25 | 45.45 | posedge   |
|Dmem Clock        | 25 | 45.45 | posedge  |

## Experiment result
>Below are the screenshots of our results using the grade mif file at the maximum clock frequency (we set the original clock frequency to **90.91Mhz**, thus the processor clock is 8 times slower, the RegFile clock 4 times slower, and the two memory clock 2 times slower).

### Functional Simulation
![image](https://github.com/DRbean264/Processor/blob/master/IMG/results_final_88ns_nolatency.png)
### Timing Simulation
![image](https://github.com/DRbean264/Processor/blob/master/IMG/results_final_88ns.jpg)
