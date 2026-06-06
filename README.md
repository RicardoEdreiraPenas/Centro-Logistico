# 📦 Simulación End-to-End de Centro Logístico en AWS

Un simulador integral de operaciones logísticas diseñado y desplegado en AWS. Este proyecto modela la operativa completa de un centro de distribución, desde la recepción física hasta el análisis de datos, respaldado por una arquitectura orientada a eventos y aprovisionamiento en la nube automatizado.

## ✨ Características Principales

* 🚚 **Gestión de Flota y Muelles:** Simulación del flujo de entrada y salida de camiones, junto con la asignación dinámica de muelles de carga.
* 📦 **Procesamiento de Pedidos:** Manejo robusto de órdenes de clientes, desglosadas al detalle con múltiples líneas de SKU.
* 📊 **Analítica Integrada:** Pipeline de Extracción y Carga (EL) que procesa los datos operativos para alimentar dashboards interactivos en Metabase.
* ☁️ **Infraestructura como Código:** Entorno completamente automatizado, reproducible y empaquetado en contenedores.

## 🛠️ Stack Tecnológico

| Categoría | Tecnologías |
| :--- | :--- |
| **Backend / API** | Python, FastAPI |
| **Mensajería / Eventos** | AWS SQS |
| **Base de Datos** | PostgreSQL (AWS RDS) |
| **Datos / BI** | Pipeline EL, Metabase |
| **DevOps & IaC** | Docker, Terraform |
