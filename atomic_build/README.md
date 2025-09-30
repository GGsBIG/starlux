```
Build procedure:

1, modify Dockerfile.lab-atomic_test to use new base image
2, run to build:
    docker build -t brobridgehub/atomic-labdemo:vxxxx-xxxx-xxx -f Dockerfile.lab-atomic_test .
    docker save brobridgehub/atomic-labdemo:vxxxx-xxxx-xxx -o atomic-labdemo_vxxxx-xxxx-xxx.tgz
3, upload image (.tgz) to worker and load(import)

```
