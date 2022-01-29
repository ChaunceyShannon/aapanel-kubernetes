# aapanel-kubernetes
Run AAPanel inside kubernets. 在kubernetes里面运行宝塔面板（英文版本）。

# English 

Please visit: https://shareitnote.com/page/run-aapanel-inside-k8s

# Chinese

**docker**

初始化

```bash
cd [数据目录]
docker run --rm -v `pwd`:/data chaunceyshannon/aapanel
```

启动面板

```
cd [数据目录]
docker run \
    --rm \
    -d \
    -p 80:80 \
    -p 443:443 \
    -p 888:888 \
    -p 7800:7800 \
    -p 23:22 \
    -v `pwd`/www:/www \
    -v `pwd`/etc:/etc \
    -v `pwd`/root:/root \
    -v `pwd`/usr:/usr \
    -v `pwd`/var:/var \
    chaunceyshannon/aapanel
```

登录信息在容器的`/root/bt.install.log`里面

**k8s**

先定义一个pvc, 然后给deployment使用, 再定义一个service以暴露服务, 我用的EKS, 所以你需要根据你的情况修改一下.

镜像里面就一个脚本, 如果有`/data` 目录, 就安装一个基本系统到里面, 如果没有, 就开始检查是否有面板, 没有就安装面板, 然后启动服务, 如果已经安装面板, 就启动服务. 

现在能自动启动的服务有php-fpm, nginx, mysql, redis, openssh, 其他服务需要手动写入/etc/rc.local 

登录信息在容器的`/root/bt.install.log`里面
