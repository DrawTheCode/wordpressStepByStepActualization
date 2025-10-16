## Estructura del Proyecto:

La idea base es mantener una estructura limpia para futuras implementaciones de WordPress, esto nace desde la necesidad de tratar con sitios _legacy_ y poder así ir subiendo de versiones una a una y probar como reacciona WordPress en el proceso.

```
project-root/
├── configs/
│   └── docker/
│       ├── dockerFiles/
│       │   ├── Dockerfile.mysql
│       │   └── Dockerfile.php
│       ├── utils/
│       │   ├── 01-create-database.sh
│       │   ├── 02-import-dump.sh
│       │   └── refresh.sh
│       ├── php/
│       │   ├── php.conf.uploads.ini
│       │   └── php.ini
│       └── wordpress/
│           └── wp-config.php
│    
│   
│
├── data/
│   ├── backups/      ← Respaldos automáticos (archivos .sql.gz)
│   ├── database/     ← Volumen para MySQL, se crea despúes de la primera instalación.
│   └── dumps/        ← Archivo dump.sql para restauración manual/automática
│
├── src/              ← Código fuente de WordPress
│
├── .env              ← Variables de entorno del proyecto
├── .env.example      ← Ejemplo base para configuración inicial
├── .gitignore        ← Exclusiones de versión (data, node_modules, etc.)
├── docker-compose.yml← Orquestador principal de servicios
└── README.md         ← Documentación del entorno

```


## Descripción de los Componentes:

| Carpeta / Archivo               | Rol principal                                                                       |
| ------------------------------- | ----------------------------------------------------------------------------------- |
| **configs/docker/dockerFiles/** | Contiene las imágenes base personalizadas para PHP y MySQL.                         |
| `Dockerfile.mysql`              | Define la imagen MySQL con scripts de inicialización y restauración automática.     |
| `Dockerfile.php`                | Imagen PHP con configuración Apache, PHP.ini y extensiones personalizadas.          |
| **configs/docker/utils/**       | Scripts de automatización para inicializar, importar y mantener la base de datos.   |
| `01-create-database.sh`         | Crea la base y el usuario si no existen.                                            |
| `02-import-dump.sh`             | Importa un dump inicial si la base está vacía.                                      |
| `refresh.sh`                    | Servicio sidecar: vigila `dump.sql`, reimporta y genera respaldos automáticos.      |
| **configs/docker/php/**         | Configuraciones PHP personalizadas (límites de subida, memory_limit, etc.).         |
| **configs/docker/wordpress/**   | Archivo `wp-config.php` adaptado para variables de entorno (env vars).              |
| **data/**                       | Directorio persistente de datos y sincronización.                                   |
| `data/backups/`                 | Almacena respaldos generados automáticamente por el sidecar.                        |
| `data/database/`                | Carpeta local que puede montarse como `/var/lib/mysql` (si no se usa named volume). |
| `data/dumps/`                   | Lugar donde colocar el `dump.sql` que el contenedor `init` observa para restaurar.  |
| **src/**                        | Código fuente de WordPress y archivos del proyecto (plugins, themes, etc.).         |
| **.env / .env.example**         | Variables de configuración: contraseñas, nombres de base, rutas, etc.               |
| **docker-compose.yml**          | Define los servicios `mysql`, `wordpress`, y `init` con sus dependencias.           |
| **README.md**                   | Documentación de instalación, comandos y flujo de mantenimiento.                    |


## Servicios Principales:

| Servicio      | Descripción                                                                                           |
| ------------- | ----------------------------------------------------------------------------------------------------- |
| **mysql**     | Contenedor de base de datos MySQL 5.7. Gestiona la base persistente y scripts de init.                |
| **wordpress** | Contenedor PHP/Apache para WordPress. Usa configuraciones personalizadas desde `configs/php/`.        |
| **init**      | Sidecar Alpine que monitorea los dumps e intervalos, haciendo restauraciones y respaldos automáticos. |


## Sobre las variables de entorno:

### CONFIGURACIÓN BASE DE DATOS

**MYSQL_ROOT_PASSWORD:**
- Contraseña del usuario root de MySQL.
- Solo usada internamente por el contenedor para inicialización.
- No es necesario que coincida con la del usuario de aplicación.

**MYSQL_DATABASE**            
- Nombre de la base de datos principal que usará WordPress.
- Si no existe, se crea automáticamente durante la inicialización.

**MYSQL_USER**
- Usuario de aplicación con permisos sobre la base de datos anterior.
- Este usuario es el que WordPress usará para conectarse al servidor MySQL.

**MYSQL_PASSWORD**          
- Contraseña del usuario de aplicación (MYSQL_USER).
- Recuerda que si contiene símbolos especiales, debe ir entre comillas.

### CONFIGURACIÓN DEL PROYECTO Y RED

**COMPOSE_PROJECT_NAME**    
- Nombre base para los contenedores, red y volúmenes generados por Docker Compose.
- Sirve para aislar este proyecto de otros entornos locales.

**WORDPRESS_DB_HOST**
- Nombre del servicio (o contenedor) donde corre MySQL.
- Normalmente "mysql" si así se define en docker-compose.yml.

**WORDPRESS_DB_HOST_PORT**
- Puerto interno del servicio MySQL dentro de la red de Docker.
- Suele ser 3306 (valor por defecto de MySQL).

### VERSIONES DE IMAGEN

**MYSQL_VERSION**
- Imagen base de MySQL que se usará para construir el contenedor.
- Ejemplo: mysql:5.7.29 — puedes cambiar a mysql:8.0 para actualizar.

**PHP_VERSION**
- Versión de PHP utilizada en el contenedor de WordPress.
- Ejemplo: 7.2 o 8.1, según compatibilidad con los plugins.

### CONFIGURACIÓN DE ENTORNO LOCAL
**MODE_URL**
- URL base donde se servirá el sitio WordPress en entorno local.
- Ejemplo: http://localhost:8080 o la IP del host si se accede desde red.
