
# nVidia DeepStream on WSL2: nvdsgst_infer plugin adjustments



nvdsgst_infer plugin adjustments to further augment Deepstream support (debugging/execution) under WSL2 when the host possess an nVidia dGPU.
See  nVidia driver 511.79 release note for list of compatible devices (https://developer.nvidia.com/cuda/wsl).
  
This is a work-around for lack of EGL symbols in the cuda for WSL2 library - it is extremelly basic as it consist in recompiling without the EGL calls (which can be safely excluded as they relate solely to Jetson devices).
  
#

Per SOFTWARE LICENSE AGREEMENT FOR NVIDIA SOFTWARE DEVELOPMENT KITS, 1.2 (iii):
```
This software contains source code provided by NVIDIA Corporation.
```

#

How to build the plugin (Within WSL2)  

You need to follow nVidia DEEPSTREAM SDK v6.0 instructions for dGPU  
  
CUDA_VER, GST_INSTALL_DIR & LIB_INSTALL_DIR are environment variables that are expected by the makefile.  
  
Typical values would be:  
  
```
CUDA_VER=11.4  
GST_INSTALL_DIR=/opt/nvidia/deepstream/deepstream-$(NVDS_VERSION)/lib/gst-plugins/  
LIB_INSTALL_DIR=/opt/nvidia/deepstream/deepstream-$(NVDS_VERSION)/lib/  
```
  
Execute the following within WSL2  
  

```
git clone https://github.com/sylvain-prevost/nvdsgst_infer-wsl2.git
cd nvdsgst_infer-wsl2
make clean
make ENABLE_WSL2=1
sudo make install
```

This will install the updated plugin at the GST_INSTALL_DIR location.  
  
Due to problems with 'nvv4l2decoder' (not-yet-understood) and 'nveglglessink' (somewhat expected)  under WSL2,  
the deepstream-test1 has been modified with the following flow:  
  
```
- filesource  
- h264parse  
- avdec_h264 [instead of nvv4l2decoder]  
- nvvideoconvert (*addition to compensate absence of nvv4l2decoder)  
- nvstreammux  
- nvinfer  
- nvvideoconvert  
- nvdsosd  
- nvvideoconvert (*addition to compensate absence of nveglglessink)  
- autovideosink [instead of nveglglessink]
```
  
</br>
</br>

![Alt text](images/example_output.jpg?raw=true "Title")

</br>
</br>

  
PS:  
Do not forget to set DISPLAY environment variable in WSL2 to be able to visualize on Windows Host. :)  
  
</br>
</br>
  
This has been tested on the following system:  
  
* Host:  
  * WIN10 21H2 (OS Build 19044.1526)  
  * VcXsrv v1.20.9.0 (XLaunch)  
  * [optional] Debug config:  
    * Visual Studio 2022 v17.2 Preview 1 (with CMakePresets)  
    * vcpkg  
  
* NVIDIA  
  * GeForce GTX 1080  
  * Driver v511.79  
  
* WSL2:  
  * Kernel version: 5.10.60 (5.10.60.1-microsoft-standard-WSL2)  
  * Ubuntu 20.04  
  * TensorRT 8.2.3.0-ga-20220113  
  * DeepStream SDK v6  
  * gstreamer 1.19.2 (compiled from sources)  
  * gcc Ubuntu 9.3.0-17ubuntu1~20.04  
  










