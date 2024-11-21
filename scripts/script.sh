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

# Copia os arquivos necessários para a VM
scp -i ../motion_key.pem -o StrictHostKeyChecking=no ../motion_key.pem ubuntu@$buscar_ip:/tmp/
scp -i ../motion_key.pem -o StrictHostKeyChecking=no ../docker-compose-buscar.yml ubuntu@$buscar_ip:/tmp/
scp -i ../motion_key.pem -o StrictHostKeyChecking=no ../docker-compose-pitstop.yml ubuntu@$buscar_ip:/tmp/
scp -i ../motion_key.pem -o StrictHostKeyChecking=no ./install-docker-vms.sh ubuntu@$buscar_ip:/tmp/

deploy_server() {
    local ip=$1
    echo "Instalando Docker na VM: $ip"
    ssh -i ../motion_key.pem -o StrictHostKeyChecking=no ubuntu@$ip bash << EOF

        # Atualiza o sistema
        sudo apt-get update

        # Instala o Docker
        sudo apt-get install -y docker.io

        # Inicia o Docker
        sudo systemctl start docker

        # Habilita o Docker para iniciar com o sistema
        sudo systemctl enable docker

        # Verifica se a instalação foi bem-sucedida
        docker --version

        if [[ "$ip" == "$buscar_ip" ]]; then
            sudo mv /tmp/motion_key.pem . 
            sudo mv /tmp/docker-compose-buscar.yml .
            sudo mv /tmp/docker-compose-pitstop.yml .
            sudo mv /tmp/install-docker-vms.sh .

            sudo chmod 400 ./motion_key.pem
            sudo chmod +x ./install-docker-vms.sh

            ./install-docker-vms.sh

            sudo docker pull kauajuhrs/buscar-web:latest
            sudo docker run -d --name buscar-web --restart=always -p 80:80 -p 443:443 kauajuhrs/buscar-web:latest

        elif [[ "$ip" == "$pitstop_ip" ]]; then
            sudo docker pull kauajuhrs/pitstop-web:latest
            sudo docker run -d --name pitstop-web --restart=always -p 80:80 -p 443:443 kauajuhrs/pitstop-web:latest
        
        elif [[ "$ip" == "$motion_ip" ]]; then
            sudo docker pull kauajuhrs/motion-web:v1
            sudo docker run -d --name motion-web --restart=always -p 80:80 -p 443:443 kauajuhrs/motion-web:v1
        
        fi
EOF
}

# Itera sobre cada IP e chama a função de instalação
for ip in "${vms[@]}"; do
    deploy_server "$ip"
done