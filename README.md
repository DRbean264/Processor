# Project - Single Cycle Processor
**Author: Yuzhe Ding (yd160); Aohua Zhang (az147)**
**Date: 10.25.2021**

## Description of the Circuit Diagram
>Below is the circuit diagram of our design:

![image](https://github.com/DRbean264/ECE550-Project2/blob/master/IMG/processor_structure.png)
In order to accomodate the exception requirements which could be introduced by add/sub/addi these three operations, we add a **new control bit** (called **EXP**) and design some **new datapaths**.
For example, consider the instruction **add $1, $2, $3 with r2 = -2147483648 and r3 = -1**.
After processing this instruction, **r1 should store the overflow value 2147483647** while **rstatus should be set to 1**. Thus the RegFile may be written twice in one processor clock cycle.
In order to accommodate this requirement, we use the first half processor clock period to write back the normal data, while leveraging the second half to take care of writing the rstatus.

## Description of the Clock
>Below is the clock of our design.

![image](https://github.com/DRbean264/ECE550-Project2/blob/master/IMG/clock_logic.png)

| Name        | Freqency (Mhz)   |  Trigger  |
| --------   | -----:  | :----:  |
|Processor Clock      | 12.5 |   posedge   |
|RegFile Clock      | 25 |   posedge   |
|Imem Clock        |  12.5 |  posedge   |
|Dmem Clock        | 50 |  posedge  |
