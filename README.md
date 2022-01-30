# ERP API CLI

## Instalación

```sh
git clone https://github.com/ndorma/erp-api-cli.git && cd erp-api-cli
```

## Dependencias

- curl
- find
- fzf
- jq
- sed
- sha256sum
- shellspec (únicamente para ejecutar los tests)
- xargs

## Configuración

```sh
# Incluir estas líneas en el ~/.bashrc o ~/.zshrc según la shell

export ERP_API_URL="https://test.erp.ndorma.com/api"
export ERP_API_TOKEN="..."
```

> Nota: El **ERP_API_TOKEN** se obtiene:
>
> 1. Entrando en la **ERP**.
> 2. Ir a **Admin** > **API** > **Admin de la API** desde el menú superior.
> 3. Copiar el token que se muestra en la sección **API token**

## Comandos

### Login

```sh
./cli.sh ui login [username]
```
> Introducir nombre de usuario (opcional) y contraseña será solicitada luego

### Logout

```sh
./cli.sh ui logout
```

### Creación interactiva de servicios

```sh
./cli.sh ui servicio-create
```
> Seleccionar sitio, sala, tipo de servicio, rito, fecha, hora, difunto y repertorio (opcional)

### Buscador / selector interactivo de piezas

```sh
./cli.sh ui repertorio
```

### Limpiar la cache

```sh
./cli.sh ui cache-flush
```

---

## Debugging CURL

Definiendo la variable DEBUG_CURL=1 antes de cada comando, se muestra el comando curl en lugar de ejecutarlo.

```sh
DEBUG_CURL=1 ./cli.sh api repertorio

# curl --silent -X POST https://test.erp.ndorma.com/api/repertorio -H 'accept: application/json' -H 'Content-Type: application/json' -H 'usuario: 1' -H 'hash: 8b7f2076423ef84d44febf72718cbc73228107aa0d6d56da37aadac7783933ff'
```

---
### Testing

Ejecutar la test suite con

```sh
shellspec
```
