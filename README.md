# iperf3 多端口带宽测试脚本集

一套基于 `iperf3` 的批量带宽测试脚本，用于在多个 TCP 端口上同时启动服务端与客户端，并对测试结果进行汇总统计。

| 脚本 | 作用 |
| --- | --- |
| `iperf3_servers.sh` | 批量启动多个 iperf3 服务端（监听多个端口） |
| `iperf3_clients.sh` | 批量启动多个 iperf3 客户端（并发连接多端口） |
| `iperf3_summary.sh` | 汇总客户端日志中的带宽，输出每端口带宽与总带宽 |

---

## 运行环境

- Linux / macOS（依赖 `bash`、`pkill`、`grep -P`、`awk`）
- 已安装 `iperf3`，且可在 `PATH` 中直接调用
- 汇总脚本**不依赖 `bc`**，使用 `awk` 完成累加运算

---

## 使用流程

典型用法为“**先起服务端，再起客户端，最后汇总结果**”，三个脚本通常在两台机器上配合使用：

```
服务端机器：./iperf3_servers.sh
客户端机器：./iperf3_clients.sh <服务端IP> <端口数>
任意机器：  ./iperf3_summary.sh
```

---

## 脚本说明

### 1. iperf3_servers.sh — 批量启动服务端

- 运行后交互式提示输入端口数量。
- 从基础端口 **5201** 开始依次创建端口，例如输入 `5` 则监听 `5201 ~ 5205`。
- 启动前会先清理所有已运行的 iperf3 服务端（`pkill -f "iperf3 -s"`）。
- 每个服务端在后台运行，日志写入 `iperf3_logs/server_<端口>.log`。

**用法：**

```bash
./iperf3_servers.sh
```

**交互示例：**

```
Enter the number of ports to create: 5
```

**停止所有服务端：**

```bash
pkill -f "iperf3 -s"
```

### 2. iperf3_clients.sh — 批量启动客户端

- 需要两个参数：服务端 IP 地址 和 端口数量。
- 端口从 **5201** 开始，与服务端脚本生成的端口一一对应。
- 每个客户端默认测试时长 **1800 秒（30 分钟）**，可在脚本头部 `TEST_DURATION` 变量中修改。
- 启动前会先清理所有已运行的 iperf3 客户端（`pkill -f "iperf3 -c"`）。
- 客户端在后台并发运行，日志写入 `iperf3_logs/client_<端口>.log`。

**用法：**

```bash
./iperf3_clients.sh <服务器IP> <端口数量>
```

**示例：**

```bash
./iperf3_clients.sh 192.168.1.100 5
```

**常用操作：**

```bash
# 停止所有客户端
pkill -f "iperf3 -c"

# 实时查看所有客户端日志
tail -f iperf3_logs/client_*.log
```

### 3. iperf3_summary.sh — 汇总带宽结果

- 扫描指定目录（默认 `iperf3_logs`）下所有 `client_*.log`。
- 从每个日志中提取最后一次出现的 `Gbits/sec` 结果（即测试结束时的带宽），输出每个端口的带宽。
- 使用 `awk` 累加全部端口带宽，输出总带宽。
- 若某个日志无法提取到带宽数据，会输出 `Warning` 提示检查日志格式。

**用法：**

```bash
./iperf3_summary.sh [日志目录]
```

**示例：**

```bash
./iperf3_summary.sh
./iperf3_summary.sh /path/to/iperf3_logs
```

**输出示例：**

```
Analyzing iperf3 logs...
----------------------------------------
Port 5201: 9.41 Gbits/sec
Port 5202: 9.38 Gbits/sec
Port 5203: 9.45 Gbits/sec
----------------------------------------
Total Bandwidth: 28.24 Gbits/sec
----------------------------------------
```

---

## 端口对应关系

客户端与服务端的端口从 **5201** 开始连续分配，数量一致即可一一对应：

| 端口数量 | 端口范围 |
| --- | --- |
| 5 | 5201 ~ 5205 |
| 10 | 5201 ~ 5210 |
| 20 | 5201 ~ 5220 |

> 提示：在客户端机器上请确保待测端口（含 5201）未被系统防火墙拦截。

---

## 日志目录结构

运行后会在脚本所在目录下生成 `iperf3_logs/` 目录：

```
iperf3_logs/
├── server_5201.log
├── server_5202.log
├── ...
├── client_5201.log
├── client_5202.log
└── ...
```

---

## 常见问题

**Q：启动时报 `iperf3: command not found`？**
安装 iperf3，例如 Ubuntu/Debian：`sudo apt install iperf3`；CentOS/RHEL：`sudo yum install iperf3`。

**Q：汇总脚本提示 Warning，无法提取带宽？**
检查 `client_*.log` 是否完整（测试是否已结束）、其中是否包含 `Gbits/sec` 格式的结果行；若客户端仍在测试中，可等待测试结束再运行汇总脚本。

**Q：如何修改测试时长？**
修改 `iperf3_clients.sh` 顶部的 `TEST_DURATION=1800` 为所需秒数。

---

## 作者

lizia102
