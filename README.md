# 🚀 Pelican Update Script
Atualização automática do Pelican Panel + Pelican Wings em um único comando 💙

Este repositório contém um script simples, seguro e automatizado para atualizar o Painel (Panel) e o Daemon (Wings) do projeto Pelican.

Ideal para quem deseja manter o servidor sempre atualizado, sem perder tempo com comandos manuais repetitivos.

# ✨ Recursos

✔ Atualiza o Pelican Panel com:

  🔹Modo manutenção
  
  🔹Download e extração da nova versão
  
  🔹Composer
  
  🔹Migrations
  
  🔹Limpeza e otimização
  
  🔹Reinício de filas
  
  🔹Ajuste de permissões

✔ Atualiza o Pelican Wings com:

  🔹Identificação automática de arquitetura (amd64 / arm64)
  
  🔹Download da última versão
  
  🔹Substituição segura do binário
  
  🔹Reinício automático do serviço

✔ Sistema interativo com perguntas:

  🔹 Deseja atualizar o Painel? [s/n]
  
  🔹 Deseja atualizar o Wings? [s/n]

✔ Compatível com Ubuntu 22.04 / 24.04

✔ Código limpo, comentado e fácil de editar

✔ Seguro (usa set -euo pipefail)

# 📦 Como usar

📥 1. Baixar o repositório

Via Git (recomendado):

```bash
git clone https://github.com/thalisonnunes20/Pelican-Update-Script
cd Pelican-Update-Script
```

🔐 2. Tornar o script executável

```bash
chmod +x update_pelican.sh
```

🚀 3. Rodar o script

```bash
sudo ./update_pelican.sh
```

Você verá as perguntas:

  🔹Deseja atualizar o Painel (Panel)? [s/n]
  
  🔹Deseja atualizar o Wings? [s/n]


Responda conforme quiser.

# ⚙️ Configurações importantes

Antes de usar, edite no script estes valores (se necessário):

  🔹PANEL_PATH="/var/www/pelican"   # caminho do painel
  
  🔹PANEL_USER="www-data"           # usuário do webserver
  
  🔹PANEL_GROUP="www-data"          # grupo do webserver

# 🛡️ Antes de atualizar — FAÇA BACKUP!

✔ Banco de dados

```bash
mysqldump -u root -p SEU_BANCO > backup_panel.sql
```

✔ Arquivos do painel
```bash
tar -czvf backup_panel.tar.gz /var/www/pelican
```

✔ Arquivo wings.yml (se existir)
```bash
cp /etc/pelican/wings.yml wings_backup.yml
```

# 📝 Pré-requisitos

🔹Ubuntu / Debian

🔹curl instalado

🔹php e composer funcionando

🔹Permissão sudo

🔹Wings configurado como serviço systemd

# 🎯 Objetivo do projeto

Este script foi criado para:

✔ Evitar erros repetitivos ao atualizar manualmente

✔ Acelerar manutenção do servidor

✔ Simplificar a vida de administradores e hosters

✔ Garantir atualizações seguras e consistentes
