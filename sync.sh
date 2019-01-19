#!/bin/bash

zephyr_root=$1
if [ -z $zephyr_root ]; then
	echo "need to specify zephyr root."
	exit 1
fi
arches="x86 arm"
boards="x86/qemu_x86 arm/mps2_an385"
socs="arm/arm x86/ia32"
subsys="logging random debug cpp power testsuite"

find ${zephyr_root} -maxdepth 1 -type f -exec cp {} . \;
cp -a ${zephyr_root}/{cmake,scripts,dts,include,kernel,misc} .

#sed  -i "s/add_subdirectory(ext)/#add_subdirectory(ext)/" CMakeLists.txt
sed  -i "s/add_subdirectory(samples)/#add_subdirectory(samples)/" CMakeLists.txt
sed  -i "s/add_subdirectory(tests)/#add_subdirectory(tests)/" CMakeLists.txt

#sed -i 's@source "ext/Kconfig"@#source "ext/Kconfig"@' Kconfig.zephyr
sed -i 's@source "tests/Kconfig"@#source "tets/Kconfig"@' Kconfig.zephyr

mkdir -p arch/common
cp -a ${zephyr_root}/arch/common arch/
cp ${zephyr_root}/arch/Kconfig arch/
cp ${zephyr_root}/arch/CMakeLists.txt arch/
cp -a ${zephyr_root}/modules .

for arch in ${arches}; do
	mkdir -p boards/${arch}
	mkdir -p soc/${arch}
	find ${zephyr_root}/boards -maxdepth 1 -type f -exec cp {} boards  \;
	find ${zephyr_root}/soc -maxdepth 1 -type f -exec cp {} soc  \;
	cp -a ${zephyr_root}/arch/${arch} arch/
done
sed -i '/.*shields.*/d' Kconfig.zephyr
sed -i '/.*shields.*/d' boards/Kconfig

rm -rf include/arch/{arc,nios2,xtensa,riscv32,posix}
rm -rf include/{bluetooth,audio,net,cmsis_rtos_v1,cmsis_rtos_v2,posix,nvs,mgmt,shell,usb,settings}

# Boards
for board in $boards; do
	cp -a ${zephyr_root}/boards/${board} boards/${board}
done

#cleanup boards

#sed -i '/SIMULATOR/d' boards/x86/qemu_x86/Kconfig.defconfig

# SoC
for soc in $socs; do
	cp -a ${zephyr_root}/soc/${soc} soc/${soc}
done

# Subsys
mkdir -p subsys
rm -f subsys/{CMakeLists.txt,Kconfig}
for sub in $subsys; do
	cp -a ${zephyr_root}/subsys/${sub} subsys/${sub}
	grep $sub ${zephyr_root}/subsys/CMakeLists.txt >> subsys/CMakeLists.txt
	grep $sub ${zephyr_root}/subsys/Kconfig >> subsys/Kconfig
done


#drivers

drivers="timer serial console interrupt_controller entropy flash"
mkdir -p drivers
rm -rf drivers/{CMakeLists.txt,Kconfig}
for drv in $drivers; do
	cp -a ${zephyr_root}/drivers/${drv} drivers/${drv}
	grep $drv ${zephyr_root}/drivers/CMakeLists.txt >> drivers/CMakeLists.txt
	grep $drv ${zephyr_root}/drivers/Kconfig >> drivers/Kconfig
done

# lib

mkdir -p lib
cp -a ${zephyr_root}/lib/os lib
sed -i '/fdtable/d' lib/os/CMakeLists.txt
cp -a ${zephyr_root}/lib/libc lib
