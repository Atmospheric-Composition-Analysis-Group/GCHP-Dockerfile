FROM liambindle/penelope:0.1.0-ubuntu16.04-openmpi3.1.4-esmf8.0.0

# Make bash the default shell
SHELL ["/bin/bash", "-c"]

RUN apt-get install bc

# Install a CMake version > 3.15
RUN cd /opt \
&&  wget -q https://github.com/Kitware/CMake/releases/download/v3.15.5/cmake-3.15.5-Linux-x86_64.tar.gz \
&&  tar -xf cmake-*.tar.gz \
&&  rm *.tar.gz \
&&  mv cmake-* cmake
ENV PATH=/opt/cmake/bin:$PATH

# Install gFTL
RUN cd / \
&&  git clone https://github.com/Goddard-Fortran-Ecosystem/gFTL.git \
&&  cd gFTL \
&&  git checkout v1.2.2 \
&&  mkdir build \
&&  cd build \
&&  cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gFTL \
&&  make -j install \
&&  cd / && rm -rf /gFTL

# Install GCHP
RUN source /spack/share/spack/setup-env.sh \
&&  spack load openmpi \
&&  spack load hdf5 \
&&  spack load netcdf \
&&  spack load netcdf-fortran \
&&  spack load esmf \
&&  mkdir /opt/gchp && mkdir /opt/gchp/bin \
&&  cd / \
&&  git clone https://github.com/geoschem/gchp_ctm.git \
&&  cd gchp_ctm \
&&  git submodule update --init --recursive \
&&  mkdir build \
&&  cd build \
&&  cmake .. -DCMAKE_PREFIX_PATH=/opt/gFTL/GFTL-1.2/include/ \
&&  make -j geos \
&&  cp src/geos /opt/gchp/bin/geos \
&&  cd / \
&&  rm -rf gchp_ctm

# Configure environment on load
RUN echo "spack load netcdf" >> /init.rc \
&&  echo "spack load netcdf-fortran" >> /init.rc \ 
&&  echo "spack load openmpi" >> /init.rc \ 
&&  echo "export PATH=$PATH:/opt/gchp/bin" >> /init.rc \ 
&&  echo "source /init.rc" >> /etc/bash.bashrc