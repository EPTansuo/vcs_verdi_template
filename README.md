# VCS+Verdi 工程模板

## 使用方法
修改`Makefile`文件，将`TOP_NAME`设置为自己的顶层实例模块名称。

`tb/` 存放`testbench`文件，`vsrc/`存放`Verilog`代码。

## 仅分析和编译，不查看波形
```
make 
```
或
```
make all
```

## 编译、仿真并启动verdi：
```
make sim
```

## 删除构建的文件和日志文件
```
make clean
```

## 组合使用：重新分析和编译
```
make clean all
```

## 组合使用：重新分析、编译、仿真并启动verdi
```
make clean sim
```

