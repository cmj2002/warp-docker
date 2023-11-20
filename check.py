import os
import random
import subprocess
import requests
import platform
import csv
import operator

# 定义颜色函数
def print_colored(text, color):
    colors = {"red": "\033[31m\033[01m", "green": "\033[32m\033[01m", "yellow": "\033[33m\033[01m"}
    print(f"{colors[color]}{text}\033[0m")

# 选择客户端 CPU 架构
def archAffix():
    arch = platform.machine()
    arch_map = {
        "i386": '386',
        "i686": '386',
        "x86_64": 'amd64',
        "amd64": 'amd64',
        "armv8": 'arm64',
        "arm64": 'arm64',
        "aarch64": 'arm64',
        "s390x": 's390x'
    }
    return arch_map.get(arch, None)

# 下载优选工具软件，感谢某匿名网友的分享的优选工具
def download_tool():
    url = f"https://gitlab.com/Misaka-blog/warp-script/-/raw/main/files/warp-yxip/warp-linux-{archAffix()}"
    r = requests.get(url)
    with open('warp', 'wb') as f:
        f.write(r.content)
    os.chmod('warp', 0o755)

# 启动 WARP Endpoint IP 优选工具
def start_tool():
    subprocess.run(["./warp"], stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)

# 显示前十个优选 Endpoint IP 及使用方法
def show_results():
    print_colored("当前最优 Endpoint IP 结果如下，并已保存至 result.csv中：", "green")
    with open('result.csv', 'r') as f:
        reader = csv.reader(f)
        sorted_list = sorted(reader, key=operator.itemgetter(1, 2))
        for row in sorted_list[:10]:
            print(f"端点 {row[0]} 丢包率 {row[1]} 平均延迟 {row[2]}")
    print_colored("使用方法如下：", "yellow")
    print_colored("1. 将 WireGuard 节点的默认的 Endpoint IP：engage.cloudflareclient.com:2408 替换成本地网络最优的 Endpoint IP", "yellow")

# 删除 WARP Endpoint IP 优选工具及其附属文件
def cleanup():
    os.remove('ip.txt')

# 生成优选 WARP IPv4 Endpoint IP 段列表
def generate_ip_list(ipv6=False):
    ip_list = []
    for _ in range(100):
        if ipv6:
            ip_list.append(f"[2606:4700:d0::{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}]")
            ip_list.append(f"[2606:4700:d1::{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}]")
        else:
            ip_list.append(f"162.159.192.{random.randint(0, 255)}")
            ip_list.append(f"162.159.193.{random.randint(0, 255)}")
            ip_list.append(f"162.159.195.{random.randint(0, 255)}")
            ip_list.append(f"162.159.204.{random.randint(0, 255)}")
            ip_list.append(f"188.114.96.{random.randint(0, 255)}")
            ip_list.append(f"188.114.97.{random.randint(0, 255)}")
            ip_list.append(f"188.114.98.{random.randint(0, 255)}")
            ip_list.append(f"188.114.99.{random.randint(0, 255)}")
    with open('ip.txt', 'w') as f:
        f.write('\n'.join(ip_list))

def get_first_ip_and_port():
    with open('result.csv', 'r') as f:
        reader = csv.reader(f)
        next(reader)  # Skip the first row
        first_row = next(reader)
        ip_and_port = first_row[0]
        return ip_and_port

def set_custom_endpoint():
    ip_and_port = get_first_ip_and_port()
    command = f"warp-cli set-custom-endpoint {ip_and_port}"
    subprocess.run(command, shell=True)

def self_check():
    command = "curl --socks5 127.0.0.1:1080 https://cloudflare.com/cdn-cgi/trace"
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        if 'warp=on' in result.stdout:
            print("Check is warp.")
        else:
            print("Check is not warp.")
            menu()
    except subprocess.CalledProcessError:
        menu()

# 显示菜单，让用户选择要执行的操作
def menu():
    generate_ip_list()
    download_tool()
    start_tool()
    show_results()
    cleanup()
    set_custom_endpoint()

# 主函数
def main():
    self_check()

if __name__ == "__main__":
    main()