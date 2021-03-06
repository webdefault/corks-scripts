#!/system/bin/sh

# This shell script is based on https://github.com/Neo-Oli/termux-ubuntu/blob/master/ubuntu.sh

if [ ! -d "dist" ]; then
    mkdir dist
fi

cd dist
folder=ubuntu
if [ -d "$folder" ]; then
    first=1
    echo "skipping downloading"
fi
if [ "$first" != 1 ];then
    if [ ! -f "ubuntu.tar.gz" ]; then
        echo "downloading ubuntu-image"
        if [ "$(getprop ro.product.cpu.abi)" = "arm64-v8a" ];then
            curl https://partner-images.canonical.com/core/artful/current/ubuntu-artful-core-cloudimg-arm64-root.tar.gz --output ubuntu.tar.gz
        elif [ "$(getprop ro.product.cpu.abi)" = "armeabi-v7a" ];then
            curl https://partner-images.canonical.com/core/artful/current/ubuntu-artful-core-cloudimg-armhf-root.tar.gz --output ubuntu.tar.gz
        elif [ "$(getprop ro.product.cpu.abi)" = "x86" ];then
            curl https://partner-images.canonical.com/core/artful/current/ubuntu-artful-core-cloudimg-i386-root.tar.gz --output ubuntu.tar.gz
        elif [ "$(getprop ro.product.cpu.abi)" = "x86_64" ];then
            curl https://partner-images.canonical.com/core/artful/current/ubuntu-artful-core-cloudimg-amd64-root.tar.gz --output ubuntu.tar.gz
        else
            echo "Error: Unknown architecture."
            exit 1
        fi
    fi
    cur=`pwd`
    mkdir -p $folder
    cd $folder
    echo "Decompressing ubuntu image"
    proot --link2symlink tar -xf $cur/ubuntu.tar.gz --exclude='dev'||:
    echo "fixing nameserver, otherwise it can't connect to the internet"
    echo "nameserver 8.8.8.8" > etc/resolv.conf
    
    stubs=()
    stubs+=('usr/sbin/groupadd')
    stubs+=('usr/sbin/groupdel')
    stubs+=('usr/bin/groups')
    stubs+=('usr/sbin/useradd')
    stubs+=('usr/sbin/usermod')
    stubs+=('usr/sbin/userdel')
    stubs+=('usr/bin/chage')
    stubs+=('usr/bin/mesg')
    for f in ${stubs[@]};do
        echo "Writing stub: $f"
        echo -e "#!/bin/sh\nexit" > "$f"
    done
    cd $cur
fi
mkdir -p binds
bin=ubuntu-start.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/system/bin/sh
cd \$(dirname \$0)
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A binds)" ]; then
    for f in binds/* ;do
        . \$f
    done
fi
command+=" -b /system"
command+=" -b /dev/"
command+=" -b /sys/"
command+=" -b /proc/"
#uncomment the following line to have access to the home directory of termux
command+=" -b /data/data/com.webdefault.corks/files/home"
if [ -d "/storage/emulated/0" ]; then
    command+=" -b /storage/emulated/0"
fi
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=\$LANG"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM
echo "Making $bin executable"
chmod +x $bin
echo "You can now launch Ubuntu with the ./start.sh script"
