# Should probably use [bazel release 0.15.0]]
#
# If Bazel complain "util/hash not found blah blah blah", just remove the
# corresponding line in bazel's BUILD file and try again.
#
# Ref: https://docs.bazel.build/versions/master/query-how-to.html
set -x
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

cat > .bazelrc << EOF
build --action_env PYTHON_BIN_PATH="/usr/bin/python3"
build --action_env PYTHON_LIB_PATH="/usr/lib/python3/dist-packages"
build --python_path="/usr/bin/python3"
build --define with_jemalloc=true
build --define with_gcp_support=true
build --define with_hdfs_support=true
build --define with_aws_support=true
build --define with_kafka_support=true
build:xla --define with_xla_support=true
build:gdr --define with_gdr_support=true
build:verbs --define with_verbs_support=true
build --action_env TF_NEED_OPENCL_SYCL="0"
build --action_env TF_NEED_CUDA="0"
build --action_env TF_DOWNLOAD_CLANG="0"
build --define grpc_no_ares=true
build:opt --copt=-march=native
build:opt --host_copt=-march=native
build:opt --define with_default_optimizations=true
build --strip=always
EOF

# Following queries are arranged in Dependency order.

bazel query 'kind("source file", deps(//tensorflow/tools/proto_text:gen_proto_text_functions))' \
	| sort \
	> debian/ninja/tf_tool_proto_text.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow/tools/proto_text:gen_proto_text_functions))' \
	| sort \
	> debian/ninja/tf_tool_proto_text.generated_file.txt

bazel query 'kind("source file", deps(//tensorflow/core:proto_text))' \
	| sort \
	> debian/ninja/tf_core_proto_text.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow/core:proto_text))' \
	| sort \
	> debian/ninja/tf_core_proto_text.generated_file.txt

bazel query 'kind("source file", deps(//tensorflow:libtensorflow_framework.so))' \
	| sort \
	> debian/ninja/tf_libtensorflow_framework_so.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow:libtensorflow_framework.so))' \
	| sort \
	> debian/ninja/tf_libtensorflow_framework_so.generated_file.txt

bazel query 'kind("source file", deps(//tensorflow/core:android_tensorflow_lib))' \
	| sort \
	> debian/ninja/tf_core_android_tflib.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow/core:android_tensorflow_lib))' \
	| sort \
	> debian/ninja/tf_core_android_tflib.generated_file.txt

# diff commands are used for correctness check
bazel query 'kind("source file", deps(//tensorflow/cc:ops/math_ops_gen_cc))' \
	| sort \
	> debian/ninja/tf_cc_ops_XXX_gen_cc.source_file.txt
bazel query 'kind("source file", deps(//tensorflow/cc:ops/array_ops_gen_cc))' | sort > _tmp1.txt
diff -ru _tmp1.txt debian/ninja/tf_cc_ops_XXX_gen_cc.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow/cc:ops/math_ops_gen_cc))' \
	| sort \
	> debian/ninja/tf_cc_ops_XXX_gen_cc.generated_file.txt
bazel query 'kind("generated file", deps(//tensorflow/cc:ops/array_ops_gen_cc))' | sort > _tmp2.txt
diff -ru _tmp2.txt debian/ninja/tf_cc_ops_XXX_gen_cc.generated_file.txt

bazel query 'kind("source file", deps(//tensorflow/tools/lib_package:libtensorflow_test))' \
	| sort \
	> debian/ninja/tf_libtensorflow_test.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow/tools/lib_package:libtensorflow_test))' \
	| sort \
	> debian/ninja/tf_libtensorflow_test.generated_file.txt

bazel query 'kind("source file", deps(//tensorflow:libtensorflow.so))' \
	| sort \
	> debian/ninja/tf_libtensorflow_so.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow:libtensorflow.so))' \
	| sort \
	> debian/ninja/tf_libtensorflow_so.generated_file.txt

bazel query 'kind("source file", deps(//tensorflow/python:pywrap_tensorflow))' \
	| sort \
	> debian/ninja/tf_python_pywrap_tensorflow.source_file.txt
bazel query 'kind("generated file", deps(//tensorflow/python:pywrap_tensorflow))' \
	| sort \
	> debian/ninja/tf_python_pywrap_tensorflow.generated_file.txt
