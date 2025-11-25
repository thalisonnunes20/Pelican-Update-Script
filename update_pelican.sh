#!/usr/bin/env bash
# update_pelican.sh
# Script simples para atualizar Pelican Panel e Wings.
# Ajuste os caminhos, usuário e grupo conforme seu ambiente antes de usar.

set -euo pipefail

PANEL_PATH="/var/www/pelican"   # <-- ajuste para o caminho real do seu Panel
PANEL_USER="www-data"           # <-- ajuste para o usuário do webserver (www-data/nginx)
PANEL_GROUP="www-data"          # <-- ajuste para o grupo

# Função para perguntar sim/não (respostas: s/S ou n/N)
ask_yes_no() {
  local prompt="$1"
  local answer
  while true; do
    read -rp "$prompt [s/n]: " answer
    case "${answer,,}" in
      s|sim) return 0 ;;
      n|nao|não) return 1 ;;
      *) echo "Responda com 's' para sim ou 'n' para não." ;;
    esac
  done
}

echo "=== Script de atualização Pelican (Panel + Wings) ==="
echo "ATENÇÃO: Faça backup de arquivos e banco de dados antes de rodar este script."
echo

# ---------------- Atualizar Panel ----------------
if ask_yes_no "Deseja atualizar o Painel (Panel) do Pelican?"; then
  if [ ! -d "$PANEL_PATH" ]; then
    echo "Erro: diretório do painel não encontrado em $PANEL_PATH"
    echo "Saindo..."
    exit 1
  fi

  echo
  echo "-> Atualizando Panel em $PANEL_PATH"
  cd "$PANEL_PATH"

  echo "Entrando em modo de manutenção..."
  sudo php artisan down || echo "Aviso: php artisan down falhou (talvez não seja Laravel). Continuando..."

  echo "Baixando e extraindo release mais recente do Panel (substitui arquivos públicos)..."
  # nota: ajustável para usar releases específicas em vez de 'latest'
  sudo curl -L https://github.com/pelican-dev/panel/releases/latest/download/panel.tar.gz | sudo tar -xzv --strip-components=1 -C "$PANEL_PATH" || {
    echo "Falha ao baixar/extrair o pacote do Panel. Verifique a URL ou conexão."
  }

  echo "Instalando dependências (Composer)..."
  if command -v composer >/dev/null 2>&1; then
    sudo COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader || {
      echo "composer install falhou. Verifique os logs."
    }
  else
    echo "Aviso: composer não encontrado. Instale o Composer antes de prosseguir."
  fi

  echo "Criando storage:link (se aplicável)..."
  sudo php artisan storage:link || echo "storage:link falhou ou já existe."

  echo "Limpando e otimizando caches..."
  sudo php artisan optimize:clear || true
  sudo php artisan optimize || true

  echo "Aplicando migrações (force)..."
  sudo php artisan migrate --force || echo "Migração falhou ou não necessária."

  echo "Ajustando permissões..."
  sudo chown -R "${PANEL_USER}:${PANEL_GROUP}" "$PANEL_PATH"
  sudo find "$PANEL_PATH/storage" -type d -exec chmod 775 {} \; || true
  sudo find "$PANEL_PATH/storage" -type f -exec chmod 664 {} \; || true
  sudo chmod -R 755 "$PANEL_PATH/bootstrap/cache" || true

  echo "Reiniciando filas (se houver)..."
  sudo php artisan queue:restart || true

  echo "Saindo do modo de manutenção..."
  sudo php artisan up || true

  echo "Panel: atualização concluída."
else
  echo "Pulando atualização do Panel."
fi

# ---------------- Atualizar Wings ----------------
if ask_yes_no "Deseja atualizar o Wings do Pelican (daemon)?"; then
  echo
  echo "-> Atualizando Wings"

  if ! command -v systemctl >/dev/null 2>&1; then
    echo "systemctl não encontrado. Gerencie o serviço Wings manualmente."
  else
    echo "Parando serviço wings..."
    sudo systemctl stop wings || echo "Falha ao parar wings (talvez não exista o serviço). Continuando..."
  fi

  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64|amd64) BIN_ARCH="amd64" ;;
    aarch64|arm64) BIN_ARCH="arm64" ;;
    *) BIN_ARCH="amd64" ;; # fallback
  esac

  echo "Baixando binário do Wings (${BIN_ARCH}) para /usr/local/bin/wings"
  sudo curl -L -o /usr/local/bin/wings "https://github.com/pelican-dev/wings/releases/latest/download/wings_linux_${BIN_ARCH}" || {
    echo "Falha ao baixar wings. Verifique a URL."
  }

  echo "Definindo permissão de execução..."
  sudo chmod +x /usr/local/bin/wings

  if command -v systemctl >/dev/null 2>&1; then
    echo "Recarregando daemon e iniciando wings..."
    sudo systemctl daemon-reload || true
    sudo systemctl restart wings || sudo systemctl start wings || echo "Falha ao iniciar ou reiniciar wings."
  else
    echo "systemctl não disponível. Inicie o wings manualmente conforme sua configuração."
  fi

  echo "Wings: atualização concluída."
else
  echo "Pulando atualização do Wings."
fi

echo
echo "=== Script finalizado ==="
