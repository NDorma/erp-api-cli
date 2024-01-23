# ERP API CLI

## Instalación

```sh
cd ~ && git clone https://github.com/ndorma/erp-api-cli.git
```

## Dependencias (sin docker)

- curl
- find
- fzf
- jq
- ncurses (opcional)
- sed
- sha256sum
- xargs

## Dependencias (con docker)

- docker (para ejecutar tests y dcli)

## Configuración

```sh
# Incluir estas líneas en el ~/.bashrc o ~/.zshrc según la shell

export ERP_API_CLI_ENVIRONMENT="testing|staging|production"
export ERP_API_CLI_TOKEN="..."

export PATH="$PATH:~/erp-api-cli/bin"
```

> Nota: El **ERP_API_CLI_TOKEN** se obtiene:
>
> 1. Entrando en la **ERP**.
> 2. Ir a **Admin** > **API** > **Admin de la API** desde el menú superior.
> 3. Copiar el token que se muestra en la sección **API token**

## Uso

```sh
eac comando sub-comando [argumentos]
```

> Ver uso con [docker](#docker)

## Comandos API

### Crear servicio

```sh
eac api servicio-create --sitio=11 --sala=82 --fecha=2020-01-01 --hora=10:00 --difunto="test" --interpretes=1 --rito=1 | jq ".messages, .errors"
```

### Listados de recursos

```sh
eac api sitios
eac api salas
eac api repertorio
eac api interpretes
eac api ritos
```

## Comandos UI

### Info

```sh
eac info
```

### Login

```sh
eac login [username]
```

> Introducir nombre de usuario (opcional) y contraseña será solicitada luego

### Logout

```sh
eac logout
```

### Creación interactiva de servicios

```sh
eac ui servicio-create
```

> Seleccionar sitio, sala, tipo de servicio, rito, fecha, hora, difunto y
> repertorio (opcional)

### Buscador / selector interactivo de piezas

```sh
eac ui repertorio
```

### Limpiar la cache

```sh
eac cache-flush
```

## <a id="docker"></a>Ejecutando la aplicación con Docker

Es posible ejecutar la versión _dockerizada_ de la aplicación, la cual incluye
todas las dependencias instaladas.

```sh
deac comando sub-comando [argumentos]
```

---

## Debugging CURL

Definiendo la variable EAC_DEBUG_CURL=1 antes de cada comando, se muestra el
comando curl en lugar de ejecutarlo.

```sh
EAC_DEBUG_CURL=1 eac api repertorio

# curl --silent -X POST https://test.erp.ndorma.com/api/repertorio -H 'accept: application/json' -H 'Content-Type: application/json' -H 'usuario: 1' -H 'hash: 8b7f2076423ef84d44febf72718cbc73228107aa0d6d56da37aadac7783933ff'
```

---

### Testing

Ejecutar tests

```sh
./run-tests
```
