#!/bin/bash

cd ../terraform
terraform init
terraform apply -auto-approve

# Obtém os IPs públicos das instâncias diretamente do output do Terraform
buscar_ip=$(terraform output -raw buscar_public_ip)
pitstop_ip=$(terraform output -raw pitstop_public_ip)
motion_ip=$(terraform output -raw motion_public_ip)

# Lista de IPs das VMs obtida do Terraform
vms=("$buscar_ip" "$pitstop_ip" "$motion_ip")

cd ../scripts

# Função para copiar arquivos
copy_files() {
    local ip=$1
    scp -i ../motion_key.pem -o StrictHostKeyChecking=no \
        ../motion_key.pem ../docker-compose-buscar.yml ../docker-compose-pitstop.yml ./install-docker-vms.sh \
        ubuntu@$ip:/tmp/motion/
}

# Função de instalação e configuração do Docker
deploy_server() {
    local ip=$1
    ssh -i ../motion_key.pem -o StrictHostKeyChecking=no ubuntu@$ip bash << EOF

        sudo apt-get update && sudo apt-get install -y docker.io
        sudo systemctl start docker && sudo systemctl enable docker
        docker --version

        sudo mv /tmp/motion/* . && chmod 400 motion_key.pem && chmod +x install-docker-vms.sh

        case "$ip" in
            "$buscar_ip")
                ./install-docker-vms.sh
                sudo docker pull kauajuhrs/buscar-web:latest
                sudo docker run -d --name buscar-web --restart=always -p 80:80 kauajuhrs/buscar-web:latest
                ;;
            "$pitstop_ip")
                sudo docker pull kauajuhrs/pitstop-web:latest
                sudo docker run -d --name pitstop-web --restart=always -p 80:80 kauajuhrs/pitstop-web:latest
                ;;
            "$motion_ip")
                sudo docker pull kauajuhrs/motion-web:v1
                sudo docker run -d --name motion-web --restart=always -p 80:80 kauajuhrs/motion-web:v1
                ;;
        esac
EOF
}

# Copiar arquivos e deploy para todas as VMs
for ip in "${vms[@]}"; do
    copy_files "$ip" &
    deploy_server "$ip" &
done

# Espera todos os processos paralelos terminarem
wait