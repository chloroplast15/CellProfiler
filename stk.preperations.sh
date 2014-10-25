# ubuntu installatie cellprofiler
mkdir -p ~/git && cd ~/git
git clone https://github.com/CellProfiler/CellProfiler.git || \
cd CellProfiler && git pull https://github.com/CellProfiler/CellProfiler.git

# we need ssh for remote acces and aptitude for libgtk2.0 isntallation
sudo apt-get install ssh build-essential aptitude

# set locals
sudo locale-gen en_US en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales

# the Makefile suggests the following
sudo aptitude install libgtk2.0-dev

