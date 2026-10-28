# Sistemas de Big Data · Spark ARM64

**[Guía web de despliegue](https://iesataulfoargentasor.github.io/sistemas-big-data-spark-arm64/)** · **[Descargar ZIP](https://github.com/iesataulfoargentasor/sistemas-big-data-spark-arm64/archive/refs/heads/main.zip)**


Variante del [proyecto docente Spark para M4](https://github.com/iesataulfoargentasor/spark-cluster-mac-m4), preparada el 28/10/2026.
Spark 4.0.1, Java 17, Python y JupyterLab 4.4.9. Todos los servicios se construyen para Linux ARM64, sin emulación Intel.
Se conserva la imagen oficial de Spark fijada por digest y el cuaderno de clase.

## Dos modos

| Modo | Workers | Tareas simultáneas por aplicación | Heap Spark por worker | Suma de límites de contenedores |
|---|---:|---:|---:|---:|
| ligero | 1 | 2 | 1 GiB | 4,5 GiB |
| clase | 2 | 4 | 1 GiB | 6,5 GiB |

Cada worker tiene un límite de 2 GiB: 1 GiB para el executor y margen para Python y el proceso worker.
Jupyter tiene un límite de 2 GiB y el master de 512 MiB. Los límites no son memoria reservada ni garantizan que cualquier conjunto de datos quepa.
La configuración está pensada para una aplicación Spark a la vez y datos pequeños de clase.
El modo clase permite observar ejecución en dos workers; ambos siguen estando en el mismo portátil.

Respecto al proyecto de origen se reduce el heap del executor de 2 a 1 GiB, el límite del worker de 4 a 2 GiB y la memoria del daemon de 512 a 256 MiB.
Esto reduce el presupuesto de memoria; no hace más rápidos todos los trabajos ni sustituye una medición de tu práctica.

## Preparación

1. Abre Docker Desktop para Apple Silicon. Como punto de partida, asigna 8 GB y 4 CPU; para el modo clase puedes usar 10 GB y 6 CPU si el ejercicio lo necesita. Deja margen para macOS.
2. Detén el otro stack desde Docker Desktop antes de trabajar. Se mantienen los puertos habituales del material de clase.
3. Descomprime este proyecto en una carpeta local fuera de iCloud Drive. Guarda tus cuadernos actuales: esta carpeta incluye un workspace nuevo e independiente.
4. Abre Terminal en la carpeta que contiene compose.yaml y ejecuta:

```bash
bash preparar.sh
bash iniciar.sh ligero
bash comprobar.sh
```

La primera preparación requiere Internet. No hace falta instalar Java, Spark o Python en macOS.
No uses sudo. El asistente escribe tu UID/GID en .env para que puedas guardar archivos desde Jupyter.
Si conservas un .env de otro equipo, ajusta LOCAL_UID y LOCAL_GID a los valores de id -u e id -g y vuelve a preparar la imagen.

Para practicar con dos workers:

```bash
bash iniciar.sh clase
bash comprobar.sh
```

**Guarda tus cuadernos antes de cambiar de modo.** iniciar.sh recrea los contenedores de este proyecto: las sesiones en memoria terminan, pero los archivos de workspace se conservan.
Su nombre de proyecto es spark-aula-m4; no es el nombre del stack original.

## Interfaces

| Servicio | URL |
|---|---|
| JupyterLab | http://localhost:8888 |
| Master | http://localhost:8080 |
| Worker 1 | http://localhost:8081 |
| Worker 2, sólo en modo clase | http://localhost:8082 |
| Aplicación Spark, mientras exista una sesión | http://localhost:4040 |

Token inicial de Jupyter: sbd-spark. Puedes cambiarlo en .env.
Las interfaces se publican sólo en 127.0.0.1. Si modificas los puertos en .env, utiliza las nuevas direcciones.

Abre notebooks/01_Primer_cluster.ipynb. La sesión se conecta a spark://spark-master:7077.
No cambies a local[*], porque dejarías de utilizar el clúster.
Usa rutas /workspace/...: todos los contenedores ven esa carpeta.
Finaliza con spark.stop() antes de ejecutar la prueba o abrir otra aplicación.
Los CSV, cuadernos y resultados permanecen en workspace/ en tu Mac.

## Comprobación real

```bash
bash comprobar.sh
```

Detecta si hay uno o dos workers en marcha y comprueba:
- Arquitectura aarch64 en el driver y en los procesos Python remotos.
- Registro de los workers y ejecución de tareas en todos ellos.
- Agregación del CSV: ES=30 y FR=12.
- Escritura y lectura de Parquet en el directorio compartido.

Debe terminar con un objeto JSON que incluya "resultado": "OK".
Si hay otra SparkSession usando los recursos, la prueba puede quedar esperando: detén esa sesión primero.

## Parar y reanudar

```bash
bash parar.sh
bash iniciar.sh ligero
```

Para reanudar dos workers utiliza iniciar.sh clase.
Los comandos de inicio usan la imagen local y no descargan ni construyen nada.
Antes de una clase sin Internet, ejecuta preparar.sh y comprobar.sh con conexión.
Los ejercicios que descarguen paquetes o datos externos necesitan preparación aparte.

## Diagnóstico

```bash
docker compose --profile "*" ps -a
docker compose logs --tail 100 spark-master spark-worker-1 spark-worker-2 jupyter
```

- Puerto ocupado: detén el stack anterior o modifica los puertos publicados en .env.
- Imagen inexistente: ejecuta bash preparar.sh.
- Error al guardar: revisa permisos de la carpeta y LOCAL_UID/LOCAL_GID.
- OOMKilled o trabajos grandes: usa menos datos, libera cachés de Spark o aumenta de forma coordinada la memoria del worker, executor y Docker. El modo ligero reduce el consumo total, pero conserva 1 GiB por executor.
- AMD64: esta variante declara ARM64 en todos los servicios. Comprueba que estás arrancando esta carpeta y no el stack de Hadoop/Hive.

## Procedencia y validación

Se conserva LICENSE del proyecto de origen: código y configuración MIT; texto docente y cuaderno CC BY-NC-SA 4.0, atribuidos al IES Ataúlfo Argenta. Las adaptaciones del texto y cuaderno se distribuyen bajo CC BY-NC-SA 4.0.
Consulta VALIDACION.txt para ver las pruebas realizadas y sus límites.
No se han modificado ni publicado cambios en los repositorios de GitHub.

## Guía visual

La guía de `docs/` explica cómo desplegar este laboratorio en MacBook Air M4 de 24 GB e incluye esquemas de sus servicios. Se publica con GitHub Pages desde `main` → `/docs`.
