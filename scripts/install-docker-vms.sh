#!/bin/bash

# Lista de IPs das VMs
vms=("10.0.0.21" "10.0.0.22" "10.0.0.23" "10.0.0.24")

# Função para instalar o Docker na VM
install_docker() {
    local ip=$1
    echo "Instalando Docker na VM: $ip"
    
    # Copia os arquivos docker-compose para a VM
    scp -i ./motion_key.pem -o StrictHostKeyChecking=no ./docker-compose-pitstop.yml ubuntu@$ip:/home/ubuntu/ &
    scp -i ./motion_key.pem -o StrictHostKeyChecking=no ./docker-compose-buscar.yml ubuntu@$ip:/home/ubuntu/ &

    # Executa os comandos via SSH, passando a variável 'ip' explicitamente
    ssh -i ./motion_key.pem -o StrictHostKeyChecking=no ubuntu@$ip bash << EOF &
        # Atualiza o sistema
        sudo apt-get update

        # Instala o Docker e Docker Compose
        sudo apt-get install -y docker.io
        sudo apt-get install -y docker-compose

        # Inicia o Docker
        sudo systemctl start docker

        # Habilita o Docker para iniciar com o sistema
        sudo systemctl enable docker

        # Verifica se a instalação foi bem-sucedida
        docker --version

        # Verifica o IP e executa o comando docker-compose apropriado
        if [[ "$ip" == "$ip" ]]; then
            if [[ "$ip" == "10.0.0.21" || "$ip" == "10.0.0.22" ]]; then
                echo "Executando docker-compose para pitstop em $ip"
                sudo docker-compose -f /home/ubuntu/docker-compose-pitstop.yml up -d
            elif [[ "$ip" == "10.0.0.23" || "$ip" == "10.0.0.24" ]]; then
                echo "Executando docker-compose para buscar em $ip"
                sudo docker-compose -f /home/ubuntu/docker-compose-buscar.yml up -d
            fi
        fi
EOF
}

# Itera sobre cada IP e chama a função de instalação
for ip in "${vms[@]}"; do
    install_docker "$ip"
done

# Aguarda todos os processos em segundo plano terminarem
wait
