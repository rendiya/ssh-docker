how to use

build it
```
docker build -t ssh_ubuntu
```

run
```
docker run -d -p 8888:80 -p 2222:22 -p 8080:8080 --name ssh_ubuntu ssh_ubuntu
```

stop and delete
```
docker stop ssh_ubuntu
docker rm ssh_ubuntu
docker rmi ssh_ubuntu

```
