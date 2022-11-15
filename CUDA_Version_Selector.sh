#!/bin/sh

echo '===================================='
old_LD_LIBRARY_PATH=`echo $LD_LIBRARY_PATH | grep cuda`
old_PATH=`echo $PATH | grep cuda`

echo 'LD_LIBRARY_PATH = '$old_LD_LIBRARY_PATH
echo 'PATH = '$old_PATH
echo '===================================='

if [[ -z $old_LD_LIBRARY_PATH || -z $old_PATH ]]
then
    echo 'CUDA Configuration in Environment Variables is ERROR'
fi

#env | grep cuda
nvcc --version
echo '********************'
echo 'Find Some CUDA packages installed under /usr/local/'
echo '********************'
ls /usr/local -l | grep cuda
echo '===================='
cudaInstalledList=$(ls /usr/local | grep cuda)
if [ -z "$cudaInstalledList" ]
then
    echo 'Please install multiple versions of CUDA First. https://developer.nvidia.com/cuda-downloads'
    echo 'This script is only a selector.'
    exit
fi
echo '===================================='
cudaListNum=0
for loop in `ls /usr/local | grep cuda`
do
    echo $cudaListNum. $loop
    cudaList[$cudaListNum]=$loop
    #echo ${cudaList[$cudaListNum]}
    let cudaListNum+=1
done

echo '===================================='
read -r -p "Input cudaList Number: " input
if [ $input -lt $cudaListNum ]
then
    echo ${cudaList[$input]} is selected.
    if [ -z $old_LD_LIBRARY_PATH ]
    then
        new_LD_LIBRARY_PATH=`echo $old_LD_LIBRARY_PATH:/usr/local/${cudaList[$input]}/lib64`
    else
        new_LD_LIBRARY_PATH=`echo $old_LD_LIBRARY_PATH | awk -vo="${cudaList[$input]}/" '{gsub(/cuda(-[0-9]*\.?[0-9]*)?\//,o); print $0}'`
    fi
    unset LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=$new_LD_LIBRARY_PATH

    if [ -z $old_PATH ]
    then
        new_PATH=`echo $old_PATH:/usr/local/${cudaList[$input]}/bin`
    else
        new_PATH=`echo $old_PATH | awk -vo="${cudaList[$input]}/" '{gsub(/cuda(-[0-9]*\.?[0-9]*)?\//,o); print $0}'`
    fi
    unset PATH
    export PATH=$new_PATH

    env | grep cuda

else
    echo "Invalid input..."
fi