import socket
import psutil
import os


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

private_ip = get_private_ip()
if private_ip:
    print("Private IP address:", private_ip)
    
    parent_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) 
    file_path = parent_path + "/main_server/TaxiServer/Properties/launchSettings.json"
    if os.name == 'nt':
        file_path = parent_directory.replace("/", "\\")
    
    modify_line_in_file(file_path, 16, f"      \"applicationUrl\": \"http://{private_ip}:5112\",")

    shared_client_path = parent_path + "/shared/lib/repositories/client/client_repository.dart"
    if os.name == 'nt':
        shared_client_path = shared_client_path.replace("/", "\\")
    modify_line_in_file(shared_client_path, 9, f"  final String apiUrl = \"http://{private_ip}:5112/api/client\";")

    shared_driver_path = parent_path + "/shared/lib/repositories/driver/driver_repository.dart"
    if os.name == 'nt':
        shared_driver_path = shared_driver_path.replace("/", "\\")
    modify_line_in_file(shared_driver_path, 8, f"  final String apiUrl = \"http://{private_ip}:5112/api/driver\";")

    init_order_path = parent_path + "/initial_order_server/config/config.go"
    if os.name == 'nt':
        init_order_path = init_order_path.replace("/", "\\")
    modify_line_in_file(init_order_path, 6, f"	BACKEND_URL         = \"http://{private_ip}:5112/api\"")

    contract_path = parent_path + "/ride_smart_contract/hardhat.config.js"
    if os.name == 'nt':
        contract_path = contract_path.replace("/", "\\")
    modify_line_in_file(contract_path, 23, f"      url: \"http://{private_ip}:8545\",")
else:
    print("Private IP address not found.")