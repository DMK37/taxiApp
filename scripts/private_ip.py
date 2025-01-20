import socket
import psutil
import os
import sys

if len(sys.argv) < 2:
    print("Usage: python3 private_ip.py <local or remote>")
    sys.exit(1)

variable = sys.argv[1]

def get_private_ip():
    for interface, addrs in psutil.net_if_addrs().items():
        for addr in addrs:
            if addr.family == socket.AF_INET and addr.address != '127.0.0.1':
                return addr.address
    return None

def modify_line_in_file(file_path, line_number, new_content):
    # Read all lines from the file
    with open(file_path, 'r') as file:
        lines = file.readlines()

    # Modify the specific line (line_number is 0-indexed)
    if 0 <= line_number < len(lines):
        lines[line_number] = new_content + '\n'

    # Write the modified lines back to the file
    with open(file_path, 'w') as file:
        file.writelines(lines)
remote = "https://backend-deploy-asp-62fbd6e3f3d1.herokuapp.com"
private_ip = "http://" + get_private_ip()
if private_ip:
    print("Private IP address:", private_ip)
    
    parent_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) 
    file_path = parent_path + "/main_server/TaxiServer/Properties/launchSettings.json"
    if os.name == 'nt':
        file_path = parent_directory.replace("/", "\\")
    if variable == "remote":
        modify_line_in_file(file_path, 16, f"      \"applicationUrl\": \"{remote}\",")
    else:
        modify_line_in_file(file_path, 16, f"      \"applicationUrl\": \"{private_ip}:5112\",")

    shared_client_path = parent_path + "/shared/lib/utils/config.dart"
    if os.name == 'nt':
        shared_client_path = shared_client_path.replace("/", "\\")
    
    if variable == "remote":
        modify_line_in_file(shared_client_path, 2, f"const String apiUrlClient = \"{remote}/api/client\";")
    else:
        modify_line_in_file(shared_client_path, 2, f"const String apiUrlClient = \"{private_ip}:5112/api/client\";")

    shared_driver_path = parent_path + "/shared/lib/utils/config.dart"
    if os.name == 'nt':
        shared_driver_path = shared_driver_path.replace("/", "\\")
    if variable == "remote":
        modify_line_in_file(shared_driver_path, 3, f"const String apiUrlDriver = \"{remote}/api/driver\";")
    else:
        modify_line_in_file(shared_driver_path, 3, f"const String apiUrlDriver = \"{private_ip}:5112/api/driver\";")

    init_order_path = parent_path + "/initial_order_server/config/config.go"
    if os.name == 'nt':
        init_order_path = init_order_path.replace("/", "\\")
    if variable == "remote":
        modify_line_in_file(init_order_path, 6, f"	BACKEND_URL         = \"{remote}/api\"")
    else:
        modify_line_in_file(init_order_path, 6, f"	BACKEND_URL         = \"{private_ip}:5112/api\"")

    contract_path = parent_path + "/ride_smart_contract/hardhat.config.js"
    if os.name == 'nt':
        contract_path = contract_path.replace("/", "\\")
    if variable == "remote":
        modify_line_in_file(contract_path, 23, f"      url: \"{private_ip}:8545\",")
    
    flutter_path = parent_path + "/shared/lib/utils/config.dart"
    if os.name == 'nt':
        flutter_path = flutter_path.replace("/", "\\")
    if variable == "remote":
        modify_line_in_file(flutter_path, 8, f"const String rpcUrl = \"http://{private_ip}:8545\";")
else:
    print("Private IP address not found.")