## 基于ROS的四足机器人仿真和步态控制


# dependencies
## install LUA
1. curl -R -O http://www.lua.org/ftp/lua-5.3.0.tar.gz
2. tar zxf lua-5.3.0.tar.gz
3.  cd lua-5.3.0
4.  make linux test
5.  sudo make install
## install src_dog
1. `cd catkin_ws/src`
2. `git clone https://github.com/sqrt81/src_dog`
***

# build
1. `cd catkin_ws/src`  
2. change to melodic branch 
3. `catkin_make_isolate`
4. 'source ./devel_isolated/setup.bash'

***