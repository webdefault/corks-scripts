#!/system/bin/sh
cd ~

proot=usr/bin/proot
if [ -d "$proot" ]; then
    first=1
fi

if [ "$first" != 1 ];then
    if [ ! -f "proot.tar.gz" ]; then
        echo "Downloading proot."
        if [ "$(getprop ro.product.cpu.abi)" = "arm64-v8a" ];then
            curl https://webdefault.com.br/corks/proot-aarch64.tar --output proot.tar
        elif [ "$(getprop ro.product.cpu.abi)" = "armeabi-v7a" ];then
            curl https://webdefault.com.br/corks/proot-arm.tar --output proot.tar
        elif [ "$(getprop ro.product.cpu.abi)" = "x86_64" ];then
            curl https://webdefault.com.br/corks/proot-x86_64.tar --output proot.tar
        elif [ "$(getprop ro.product.cpu.abi)" = "x86" ];then
            curl https://webdefault.com.br/corks/proot-i686.tar --output proot.tar
        else
            echo "Error: Unknown architecture."
            exit 1
        fi
    fi
    
    tar -xf proot.tar --no-same-owner
    chmod -R 755 usr/bin usr/lib usr/share
    
    mkdir tmp
    mkdir proot_tmp
fi

echo "Done."
