import scapy.all as scapy
import requests
import socket
import time
import sys

# CONFIGURAÇÕES
BACKEND_URL = "https://tertulianoshow-terlinet-backend.hf.space/update_devices"
IP_RANGE = "192.168.1.1/24" # <-- AJUSTE AQUI SE NECESSÁRIO

def get_hostname(ip):
    try: return socket.gethostbyaddr(ip)[0]
    except: return "Dispositivo Desconhecido"

def scan(ip):
    print(f"[*] Escaneando rede {ip}...")
    arp_req = scapy.ARP(pdst=ip)
    broadcast = scapy.Ether(dst="ff:ff:ff:ff:ff:ff")
    answered = scapy.srp(broadcast/arp_req, timeout=2, verbose=False)[0]
    return [{"ip": e[1].psrc, "mac": e[1].hwsrc, "name": get_hostname(e[1].psrc)} for e in answered]

def main():
    print("=== TerlineT IT Agente Ativo ===")
    while True:
        try:
            devices = scan(IP_RANGE)
            requests.post(BACKEND_URL, json=devices)
            print(f"[OK] {len(devices)} dispositivos enviados.")
        except Exception as e: print(f"[Erro] {e}")
        time.sleep(300)

if __name__ == "__main__":
    main()