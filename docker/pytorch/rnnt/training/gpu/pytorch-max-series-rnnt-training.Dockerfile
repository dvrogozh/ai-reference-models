# Copyright (c) 2023 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG PYT_BASE_IMAGE="intel/intel-extension-for-pytorch"
ARG PYT_BASE_TAG="2.1.10-xpu-pip-base"

FROM ${PYT_BASE_IMAGE}:${PYT_BASE_TAG}

WORKDIR /workspace/pytorch-max-series-rnnt-training/models

ENV DEBIAN_FRONTEND=noninteractive

RUN wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
    gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        intel-oneapi-mpi-devel \
        intel-oneapi-ccl && \
    rm -rf /var/lib/apt/lists/*
    
COPY models_v2/pytorch/rnnt/training/gpu .
COPY models_v2/common common

RUN python -m pip install -r requirements.txt 

RUN python -m pip install --no-cache-dir --upgrade pip

ENV LD_LIBRARY_PATH=/opt/intel/oneapi/ccl/2021.11/lib/:/opt/intel/oneapi/mpi/2021.11/opt/mpi/libfabric/lib:/opt/intel/oneapi/mpi/2021.11/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=/opt/intel/oneapi/mpi/2021.11/lib:/opt/intel/oneapi/ccl/2021.11/lib/
ENV PATH=/opt/intel/oneapi/mpi/2021.11/opt/mpi/libfabric/bin:/opt/intel/oneapi/mpi/2021.11/bin:$PATH
ENV CCL_ROOT=/opt/intel/oneapi/ccl/2021.11
ENV I_MPI_ROOT=/opt/intel/oneapi/mpi/2021.11
ENV FI_PROVIDER_PATH=/opt/intel/oneapi/mpi/2021.11/opt/mpi/libfabric/lib/prov:/usr/lib/x86_64-linux-gnu/libfabric

COPY LICENSE license/LICENSE
COPY third_party license/third_party
