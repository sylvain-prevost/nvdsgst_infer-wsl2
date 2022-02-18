################################################################################
# Copyright (c) 2017-2021, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA Corporation and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA Corporation is strictly prohibited.
#################################################################################

################################################################################
# SP: minor mondifications to enable compile/link against WSL2
################################################################################

CUDA_VER?=
ifeq ($(CUDA_VER),)
  $(error "CUDA_VER is not set")
endif

ENABLE_WSL2?=0

CXX:= g++
SRCS:= gstnvinfer.cpp  gstnvinfer_allocator.cpp gstnvinfer_property_parser.cpp \
       gstnvinfer_meta_utils.cpp gstnvinfer_impl.cpp
INCS:= $(wildcard *.h)
LIB:=libnvdsgst_infer.so

NVDS_VERSION:=6.0

CFLAGS+= -fPIC -std=c++11 -DDS_VERSION=\"6.0.0\" \
	 -I /usr/local/cuda-$(CUDA_VER)/include \
	 -I includes \
	 -DNDEBUG

GST_INSTALL_DIR?=/opt/nvidia/deepstream/deepstream-$(NVDS_VERSION)/lib/gst-plugins/
LIB_INSTALL_DIR?=/opt/nvidia/deepstream/deepstream-$(NVDS_VERSION)/lib/

LIBS := -shared -Wl,-no-undefined \
	-L/usr/local/cuda-$(CUDA_VER)/lib64/ -lcudart

ifeq ($(ENABLE_WSL2),1)

CFLAGS+= -Wno-deprecated-declarations
CFLAGS+= -DENABLE_WSL2

# final library is not located as the same place as the rest on WSL2
LIBS+= -L/usr/lib/wsl/lib -lcuda

LIBS+= -L$(LIB_INSTALL_DIR) -lnvdsgst_helper -lnvdsgst_meta -lnvds_meta \
	-lnvds_infer -lnvbufsurface -lnvbufsurftransform -ldl -lpthread \
	-Wl,-rpath,$(LIB_INSTALL_DIR)

else

CFLAGS+= -Wno-deprecated-declarations

LIBS+= -L$(LIB_INSTALL_DIR) -lnvdsgst_helper -lnvdsgst_meta -lnvds_meta \
	-lnvds_infer -lnvbufsurface -lnvbufsurftransform -ldl -lpthread \
	-lcuda -Wl,-rpath,$(LIB_INSTALL_DIR)

endif

OBJS:= $(SRCS:.cpp=.o)

PKGS:= gstreamer-1.0 gstreamer-base-1.0 gstreamer-video-1.0
CFLAGS+=$(shell pkg-config --cflags $(PKGS))
LIBS+=$(shell pkg-config --libs $(PKGS))

all: $(LIB)

%.o: %.cpp $(INCS) Makefile
	$(CXX) -c -o $@ $(CFLAGS) $<

$(LIB): $(OBJS) $(DEP) Makefile
	$(CXX) -o $@ $(OBJS) $(LIBS)

install: $(LIB)
	cp -rv $(LIB) $(GST_INSTALL_DIR)

clean:
	rm -rf $(OBJS) $(LIB)
