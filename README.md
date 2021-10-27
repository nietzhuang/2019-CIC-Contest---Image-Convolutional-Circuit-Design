# 2019 CIC Contest Preliminary - Image Convolutional Circuit Design

# **1. Introduction**

Design an image convolutional circuit (CONV circuit) which is able to the computations of convolutional layer(layer 0), max-pooling(Layer 1), flattern(layer 2), besides, the input is gray image. The block diagram is demonstrated below.

[Functional block diagram of CONV circuit](https://github.com/nietzhuang/2019-CIC-Contest---Image-Convolutional-Circuit-Design/pics/Figure\ 1.png)

First of all, in Layer 0, the input gray image which size is 64x64 has to be padding with zeros, afterwards, convolves with two different kernels which both size are 3x3. The, the results, two 64x64 size feature maps, are calculated followed by ReLU activation.
Secondly, Layer 1 compute the maximum pooling function where the kernel chooses 2x2 and stride is selected as two. Therefore, the results in this layer produce two 32x32 feature maps.
Last, Layer 2 flatterns the feature maps after max-pooling that the final result will expand to a length of 2048 serial signals in this design and output to memory.
Besides, the results for each layer are writen to the built-in memories in texture.v that are L0_MEM0, L0_MEM1, L1_MEM0, L1_MEM1 and L2_MEM, the testbench verifies results in the memories.


# **2. Specification**
[System block diagram](https://github.com/nietzhuang/2019-CIC-Contest---Image-Convolutional-Circuit-Design/pics/Figure\ 2.1.png)

| Signal Name | I/O | Width | Description 																 |
|-------------|-----|-------|----------------------------------------------------------------------------|
|	  clk	  |  I  |   1   | System clock that all signals are related to rising edge of clk.       	 |	  
|    reset    |  I  |   1   | System reset that actives high asynchronously. 							 | 
|    ready    |  I  |   1   | 																			 |
|	 busy     |  O  |   1   |																			 |
|	 iaddr    |  O  |  12   | 																			 |
|    idata    |  I  |  20   |																			 |
|     crd     |  O  |   1   |																			 |
|   cdata_rd  |  I  |  20   |																			 |
|   caddr_rd  |  O  |  12   |																			 |
|     cwr     |  O  |   1   |																			 |
|	cdata_wr  |  O	|  20   |																		     |		 
|   caddr_wr  |  O  |  12   |                                                                            |
|     csel    |  O  |   3   |                                                                            |





# 2.1 System Block diagram
# 2.2 Signal Description
# 2.3 Functional Description
