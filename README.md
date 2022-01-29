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

## Login

```sh
./cli.sh ui login

# introducir nombre de usuario y contraseña
```

## Logout

```sh
./cli.sh ui logout

# introducir nombre de usuario y contraseña
```

## Creación de servicios

```sh
./cli.sh ui servicio-create

# seleccionar sitio, sala, tipo de servicio, rito, fecha, hora y difunto
```

## Buscador de piezas

```sh
./cli.sh ui repertorio-search
```
## Limpiar la cache

```sh
./cli.sh ui cache-flush
```
