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
./erp.sh api auth

# introducir nombre de usuario y contraseña
```

## Logout

```sh
./erp.sh api logout

# introducir nombre de usuario y contraseña
```

## Creación de servicios

```sh
./erp.sh api servicio-create

# seleccionar sitio, sala, tipo de servicio, rito, fecha, hora y difunto
```

## Buscador de piezas

```sh
./erp.sh api repertorio-search
```
## Limpiar la cache

```sh
./erp.sh api cache-flush
```
