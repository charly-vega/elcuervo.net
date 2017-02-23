---
layout: post
title: Omnibus
subtitle: Hackeando el Sistema de Transporte Metropolitano
categories: [netsec]
date: 2016-11-29
icon: pencil
header: omnibus.jpg
attribution: Matthew Henry

---

Publicado originalmente el .

_Omnibus, del latin: Para todos_

STM nace con el ideal de llevar a Montevideo al siglo 21 ofreciendo una tarjeta de transporte
como hay en cualquier otro lugar del mundo.

Mas allá de la diversión técnica que trae crackear este tipo de tarjetas la motivación
principal es el aparente conocimiento de parte del estado de las carencias de seguridad
de la misma. Véase presentación mas abajo.

## Érase una vez...

Desde la invención de [NFC](https://en.wikipedia.org/wiki/Near_field_communication)
la batalla de qué tarjeta es mejor fue fiera.

Hubo una que se hizo extremadamente famosa ya que se implementó en varios lugares
del mundo especialmente en sistemas de transporte. Ésta fue la [Mifare Classic](https://en.wikipedia.org/wiki/MIFARE) de
la empresa NXP.

Todo este blogpost trata sobre un problema que tienen las tarjetas Mifare desde el principio.
Siendo totalmente público desde el 2008 llegó hasta que la propia Mifare no
recomiende el uso de sus tarjetas Classic cuando la seguridad es algo
importante: [Seguridad Mifare Classic](http://www.nxp.com/products/identification-and-security/mifare-ics/mifare-classic:MC_41863)

[Modelo Mifare usado](https://en.wikipedia.org/wiki/MIFARE#Security_of_MIFARE_Classic.2C_MIFARE_DESFire_and_MIFARE_Ultralight)

> Following the broad acceptance of contactless ticketing technology and
> extraordinary success of the MIFARE Classic® product family, application
> requirements and security needs constantly increased. Therefore we do not
> recommend to use MIFARE Classic in security relevant applications anymore.

Bueno, empecemos con lo que nos atañe.
Esta es una explicación de una vulnerabilidad que tiene tantos años como el
producto en sí.

La vulnerabilidad afecta todas y cada una de las tarjetas STM.

Para dar un poco de contexto esta es una presentación "interna" (gracias Google)
de explicación de todo el sistema de transporte. Antes que me digan nada es del
2008.

<iframe src="//www.slideshare.net/slideshow/embed_code/key/fyzLVFGy7yynyr" height="485" frameborder="0" marginwidth="0" marginheight="0" scrolling="no"> </iframe>
[Original](http://es.slideshare.net/alejandro.benitez/ssistema-de-transporte-montevideo-presentation)
[Mirror](/arquitectura-stm.ppt)

Mas allá de la antiguedad de la presentacion lo que mas me llama la atención es
la cantidad de información interna que hay.

## ... una tarjeta de transporte

Montevideo optó por un modelo de tarjeta NFC de la empresa NXP.
NFC es una tecnología que tiene muchos años en el mercado, es ese tipo de magia
negra que nos llena de ilusión sobre estar viviendo en el futuro: transmisión de
datos sin contacto.
La elección del modelo de NXP sucedió hace ya mucho tiempo seguramente atado a
un bajo precio o quién sabe qué.

## ... qué no era como las demas

![](/img/blog/stm.png)

Sabemos varias cosas: es una tecnología que tiene tiempo ahí afuera y que no es
particularmente cara.

En cualquier otro escenario esto no sería ningún problema, el problema es (como con
las ideas en general) la implementación, una idea no vale nada.

Dentro de la tecnología de la información hay dos escuelas, la cerrada que pregona
que toda tecnología privada y sellada es mas valiosa y la otra donde se nos tilda
de hippies que no entendemos nada y optamos por compartir lo que sabemos.

Mi mentor una vez me dijo: "nunca uses un algoritmo que no haya sido evaluado por
pares, cuantos mas ojos miren mas van a poder encontrar los errores". Me tomo 15
años encontrar un caso tan evidente como este:

NXP, la empresa atrás del desarrollo de la tarjeta STM decidió usar su propio
sistema criptografico conocido como [CRYPTO1](https://en.wikipedia.org/wiki/Crypto-1).

Como se imaginarán esa no fue una idea demasiado brillante.

La seguridad por oscuridad tiende a colapsar ante el primer vestigio de luz.

Meses despues del lanzamiento de la tarjeta ya exisitia un exploit.
El problema radica en la generacion de numeros al azar ([RNG](https://en.wikipedia.org/wiki/Random_number_generation)) de la tarjeta donde
por una mala implementación el azar es predecible.
Asi nació [CRAPTO1](http://crapto1.netgarage.org/).

## ... y quería que todos viajaran.

![](/img/blog/dump.jpg)

Esta es la parte jugosa.

Sabemos como funciona y sabemos como puede llegar a fallar.
Ahora: ¿qué tan fácil es viajar gratis en el sistema de transporte metropolitano?

¿Qué información habrá en su interior?
¿Será víctima de un [Replay Attack](https://en.wikipedia.org/wiki/Replay_attack)?
es decir, ¿se podrá clonar la tarjeta y/o restaurarla a un estado anterior
terminando así con (a efectos prácticos) saldo ilimitado?

Mi investigación llevó un tiempo, desde la comprensión del problema hasta el acceso
al hardware necesario.

Al dia de hoy el costo es de $40 dólares de Trump ^_^.

Pero no siempre fue así.

La historia comienza cuando pude tener acceso a un lector NFC de bajo costo.
El modelo que elegi es el [PN532](https://www.adafruit.com/product/364) que sabía tenia buena compatibildad con
Raspberry Pi. Esa elección se daba por lo siguiente:

Ese modelo de tarjeta NFC esta dividida en sectores, para tener acceso a
cada sector se necesita una clave de lectura y una de escritura.

Dado el problema en la generación de números aleatorios de la tarjeta teniendo
cualquiera de las 32 claves posibles de una tarjeta se puede inferir el valor del
resto.
Esto puede ser un proceso tedioso de entre 5 minutos a algunas horas pero garantiza
una copia completa de la tarjeta siempre... siempre y cuando se tenga paciencia.

Mi enfoque original era bastante optimista, asumí que durante la implementación
no habian cambiado alguna clave por defecto.

En defensa de quien sea que lo haya implementado efectivamente cambiaron las claves
por defecto de la tarjeta.

Aún no termina la historia, si bien es *mas fácil* acceder a una tarjeta teniendo
una de las claves existe otra manera: fuerza bruta.

Es por ese motivo que queria una Raspberry Pi, armé un setup con una pi y el lector,
redundancia electrica y una alerta cuando encontrara algo y tiré una moneda al aire.

4 días después me llené de euforia al ver esa clave hexadecimal: `0xd14400000000 `

Bueno, no esa... puse en cero algunos valores para hacerlo mas interesante :P.

Habiendo conseguido esa clave pude inferir el resto de las claves de la tarjeta.

¿Pero cual es la gracia si solo se puede hacer en una tarjeta? Hay una cantidad
gigante de claves ahi afuera, todos sabemos que repetir este proceso por cada
una de ellas es ridículamente trabajoso... a menos que...

Intentando reproducir el experimento en otra tarjeta me cansé de esperar el ataque
de fuerza bruta y probé las 32 claves que ya tenía de la tarjeta original con
otra que conseguí.

31 claves denegadas luego noté algo interesante... la primera clave de lectura
del primer sector de todas las tarjetas es la misma.
Usando esta clave "maestra" todo el resto de claves pueden ser inferidas.

![](/img/blog/proxmark3.jpg)

Con mejor hardware, como un lector Proxmark3 el tiempo de crackeo de la clave
es de menos de 10 segundos.

## Un vestigio de luz.

Ahora ilumenemos todo el cuarto y veamos cómo funciona la STM.

En el momento que un usuario compra su tarjeta de transporte se asocia el UID
de la tarjeta NFC a la cédula sin puntos ni guiones:

`UID: 123123123123 -> CI: 12346789`

En caso de perder la tarjeta y solicitar una nueva se va a repetir el proceso
pero la cédula (o usuario en este caso) cambia a `12346789_2`, osea, un guión bajo
mas el `n` siguiente.

Esto trae muchos problmeas, empezando por el anonimato, cada ruta de un portador
de tarjeta STM puede ser inferida con bastante facilidad pero no solo eso.
Los `UID` de las tarjetas NFC pueden ser leidos sin necesidad de una clave de
lectura, por lo tanto un agente externo puede "identificar" a un usuario a una
distancia prudencial.

Luego, al subir a un omnibus y acercar la tarjeta al lector sucede lo siguiente:
se lee el primer sector con la clave maestra que irónicamente guarda el `UID` de
la tarjeta, seguramente como validación. Con ese `UID` se calculan los valores
de las claves de los siguientes sectores.

Se usan varias de las recomendaciones de seguridad que les pide Mifare a los que
usen este modelo viejo que son: contadores (que aumentan y decresen) y los datos
(por suerte) no estan en texto plano como las fechas y crédito. Están guardados
usando [XOR](https://en.wikipedia.org/wiki/Exclusive_or).

Ese registro de crédito pasa a la computadora de a bordo, arriba, a la derecha
entrando en el omnibus. Que tiene un pendrive que guarda los datos de las tarjetas
y sus rutas y es entregado con la recaudación al final de cada jornada.

Es decir, el registro de boletos y su crédito es guardado offline y luego
(¿diariamente?) es actualizado en una base central.

Lo que nos da como única fuente de la verdad la tarjeta STM.
Una tarjeta hackeable.

La tarjeta (en su implementación) es vulnerable a lo que se conoce como [Replay Attack](https://en.wikipedia.org/wiki/Replay_attack)
ya que si guardamos una imagen de la tarjeta con $2000 podemos restaurarla
a su estado anterior.

Incluso el uso de emuladores NFC como el Proxmark3 hacen posible tener un
dispositivo con saldo perpetuo.

## Destino.

El problema no radica exclusivamente en la ejecucion de la solucion, sino en la
falta de contralor que los sistemas estatales (y no estatales) tienen.
El objetivo de esta investigación es entender un sistema y sus piezas móviles, no
el abuso del mismo.

Cabe aclarar que no somos la excepción en la región, tanto la SUBE de Argentina,
como la BIP! de Chile son vulnerables al mismo ataque.
La unica curiosidad que tengo es que nuestro sistema fue implementado *luego* de
que este modelo de tarjeta se haya mostrado como vulnerable.
