complete -p "*dms*build.sh" -s d -l debug -d 'Enable debug build (default: false)' -f
complete -p "*dms*build.sh" -s s -l sanitize -d 'Enable sanitize (default: false)' -f
complete -p "*dms*build.sh" -s a -l arch -d 'Set target arch: x64Linux, armv8Linux, armv8Qnx, armv8Qcs610, armv8Android (default: x64Linux)' -r -f -a "{x64Linux	'Linux with x86_64 architecture (Laptop, Desktop)',armv8Linux	'Linux with armv8 architecture (Xavier, Quanta board)',armv8Qnx	'QNX with armv8 architecture (Xavier, Quanta board)',armv8Qcs610	'Linux with armv8 architecture (Qualcomm QCS610 board)',armv8Android	'Android with armv8 architecture (VF MHU board)'}"
complete -p "*dms*build.sh" -s p -l path -d 'Cross compile toolchain path (default: ~/middleware/DATA/SDK_NVIDIA (x64Linux, armv8Linux), ~/QCS610_standalone_sdk (armv8Qcs610), ~/middleware/DATA/QNX (armv8Qnx), ~/Android/Sdk/ (armv8Android))' -r -F
complete -p "*dms*build.sh" -s n -l ndk_path -d 'Path to the Android NDK (default: ~/Android/Sdk/ndk/23.1.7779620)' -r -F
complete -p "*dms*build.sh" -s i -l inference_engine -d 'Set inference engine: tensorrt, snpe (armv8Qcs610), tflite (x64Linux, armv8Qnx, armv8Linux, armv8Android) (default: tensorrt)' -f -r -a "{tensorrt	'TensorRT inference engine (x64Linux, armv8Linux)',snpe	'Qualcomm SNPE inference engine (armv8Qcs610)',tflite	'Tensorflow Lite (x64Linux, armv8Qnx, armv8Linux, armv8Android)'}"
complete -p "*dms*build.sh" -s l -l logger -d 'Set logger type: spd, dlt, all (default: spd)' -f -r -a "{spd	'The default Speed(SPD) Logger',dlt	'The DLT logger',all	'Support both SPD and DLT Logger'}"
complete -p "*dms*build.sh" -s b -l backtrace_disable -d 'Disable backtrace (default: false (enable backtrace))' -f
complete -p "*dms*build.sh" -s c -l cpptest_project -d 'Enable build cpptest project Parasoft (default: false)' -f
complete -p "*dms*build.sh" -s m -l make_file_cpptest_project -d 'Cpptest path (default: /<home>/cpptest/). Used for Cpptest Parasoft only' -r -F
complete -p "*dms*build.sh" -s o -l deployment_pkg -d 'Build deployment package (default: false)' -f
complete -p "*dms*build.sh" -s g -l config -d 'Set default or yaml (default: yaml)' -f
complete -p "*dms*build.sh" -s r -l release_sdk -d 'Build release SDK package (default: false)' -f
complete -p "*dms*build.sh" -s R -l Recording -d 'Enable MonRecService for Recording events and videos (default: false)' -f
complete -p "*dms*build.sh" -s k -l package_for_qc -d 'Build release Package for QC(default: false)' -f
complete -p "*dms*build.sh" -s h -l help -d 'Show help content' -f
