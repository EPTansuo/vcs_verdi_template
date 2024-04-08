# VCS+Verdi 工程模板

## 使用方法
修改`Makefile`文件，将`TOP_NAME`设置为自己的顶层实例模块名称,`WAVE`设置波形文件，其余请看`Makefile`。

`tb/` 存放`testbench`文件，`vsrc/`存放`Verilog`代码。

## 仿真并启动verdi查看波形：
```
make run
```
## 仅分析和仿真，但是不查看波形：

```
make
```
或
```
make sim 
``` 
或
```
make all
```
## 删除构建的文件和日志文件
```
make clean
```
