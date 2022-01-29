# ERP API CLI

## Instalación

```sh
git clone https://github.com/ndorma/erp-api-cli.git && cd erp-api-cli
```

## Configuración

```sh
export ERP_API_URL="https://test.erp.ndorma.com/api"
export ERP_API_TOKEN="..."
```

> _Nota:_ El __ERP_API_TOKEN__ se obtiene:
> 1. Entrando en la ERP.
> 2. Desde el menu, ir a Admin > API > Admin de la API.
> 3. Copiar el token de la sección __API token__

## Comandos

### Login

```sh
./cli.sh ui login

# introducir nombre de usuario y contraseña
```

### Logout

```sh
./cli.sh ui logout

# introducir nombre de usuario y contraseña
```

### Creación interactiva de servicios

```sh
./cli.sh ui servicio-create

# seleccionar sitio, sala, tipo de servicio, rito, fecha, hora y difunto
```

### Buscador/selector interactivo de piezas

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
