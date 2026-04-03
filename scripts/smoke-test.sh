#!/bin/bash

# Configuración
URL="http://localhost:8081"
CONTAINER_NAME="workshop3-iac_default" # Ajusta si el nombre cambia

echo "🔍 Iniciando Smoke Test SRE..."

# 1. Validar si el contenedor está corriendo
if [ $(docker ps -f name=$CONTAINER_NAME --format "{{.Names}}" | grep -c "$CONTAINER_NAME") -eq 1 ]; then
    echo "✅ [DOCKER]: Contenedor operativo."
else
    echo "❌ [DOCKER]: Contenedor NO encontrado o apagado."
    exit 1
fi

# 2. Validar respuesta HTTP 200
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ [HTTP]: El servidor responde con 200 OK."
else
    echo "❌ [HTTP]: El servidor responde con error $HTTP_STATUS."
    exit 1
fi

# 3. Validar contenido (Hardening check)
if curl -s $URL | grep -q "SoftrainCorp SRE"; then
    echo "✅ [CONTENT]: El index.html es correcto."
else
    echo "❌ [CONTENT]: El contenido del index no es el esperado."
    exit 1
fi

echo "🚀 SMOKE TEST PASSED: Infraestructura validada."
