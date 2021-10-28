# 2019 CIC Contest Preliminary - Image Convolutional Circuit Design

# **1. Introduction**

Design an image convolutional circuit (CONV circuit) which is able to the computations of convolutional layer(layer 0), max-pooling(Layer 1), flattern(layer 2), besides, the input is gray image. The block diagram is demonstrated below.

![Functional block diagram of CONV circuit](https://github.com/nietzhuang/2019-CIC-Contest---Image-Convolutional-Circuit-Design/blob/master/pics/Figure1.png)

First of all, in Layer 0, the input gray image which size is 64x64 has to be padding with zeros, afterwards, convolves with two different kernels which both size are 3x3. The, the results, two 64x64 size feature maps, are calculated followed by ReLU activation.
Secondly, Layer 1 compute the maximum pooling function where the kernel chooses 2x2 and stride is selected as two. Therefore, the results in this layer produce two 32x32 feature maps.
Last, Layer 2 flatterns the feature maps after max-pooling that the final result will expand to a length of 2048 serial signals in this design and output to memory.
Besides, the results for each layer are writen to the built-in memories in texture.v that are L0_MEM0, L0_MEM1, L1_MEM0, L1_MEM1 and L2_MEM, the testbench verifies results in the memories.


# **2. Specification**
# 2.1 System Block diagram
![System block diagram](https://github.com/nietzhuang/2019-CIC-Contest---Image-Convolutional-Circuit-Design/blob/master/pics/Figure2.1.png)

# 2.2 Signal Description
| Signal Name | I/O | Width | Description 																 |
|-------------|-----|-------|----------------------------------------------------------------------------|
|	  clk	  |  I  |   1   | System clock that all signals are related to rising edge of clk.       	 |	  
|    reset    |  I  |   1   | System reset that actives high asynchronously. 							 | 
|    ready    |  I  |   1   | Ready signal indicates the input gray image is already provided. When ready is asserted, CONV circuit can start requesting image data via sending address. |
|	 busy     |  O  |   1   | Busy signal is asserted while CONV circuit recives ready as HIGH and prepares to work. It disassertes after all the related computations are done. |
|	 iaddr    |  O  |  12   | Address to request input gray image. 										 |
|    idata    |  I  |  20   | A sign input pixel data of gray image that constitutes 4-bit MSB as integer and 16-bit LSB as fraction. |
|     crd     |  O  |   1   | Read enable signal indicates that the CONV circuit starts reading data from the memory when it is asserted. |
|   cdata_rd  |  I  |  20   | Pixel data formed as 4-bit MSB integer and 16-bit LSB fraction inputs from the memory. |
|   caddr_rd  |  O  |  12   | Memory address associates the pixel data in the memory. |
|     cwr     |  O  |   1   | Write enable signal indicates that the CONV circuit starts writing the results to the memory when it is asserted. |
|	cdata_wr  |  O	|  20   | Result data formed as 4-bit MSB integer and 16-bit LSB fraction outputs to the memory. |		 
|   caddr_wr  |  O  |  12   | Memory address associates the results to be written and stored in the memory. |
|     csel    |  O  |   3   | Memory selection signal that CONV circuit chooses which memory to read/write according to it.
|			  |     |       | 3'b000: no selection.
|             |     |       | 3'b001: read/write the layer 0 results convolved with kernel 0.
|             |     |       | 3'b010: read/write the layer 0 results convolved with kernel 1.
|             |     |       | 3'b011: read/write the layer 1 results convolved with kernel 0.
|             |     |       | 3'b100: read/write the layer 1 results convolved with kernel 1 and computed max-pooling afterwards.
|             |     |       | 3'b101: read/write the layer 3 results which is flatterned. |

# 2.3 Functional Description
After reset, testfixture asserts ready signal to indicate that data with repect to the gray images and kernels are already prepared. CONV circuit has to assert busy signal (shown at t1) so that the testfixture disasserts ready after detects bust as HIGH in order to wait for CONV circuit execution (shown at t2).
Furthermore, CONV circuit restores busy as LOW either while all tasks have done or the excution of desired layer is done (shown at t3), meanwhile, testfixture is going to prepare next image and assert ready signal. Besides, testfixture starts verification when detects the busy signal setting to LOW again; CONV circuit is only admitted to assert busy signal once with respect to each one input image, and the CONV circuit only disasserts busy once in the end of computation. In addition, during the process when busy is asserted HIGH, CONV circuit is permitted to read/write all the memories without times limitation.
![System procedure](https://github.com/nietzhuang/2019-CIC-Contest---Image-Convolutional-Circuit-Design/blob/master/pics/Figure2.3.png)


