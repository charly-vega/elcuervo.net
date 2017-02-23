---
layout: post
title: Ómnibus
subtitle: Hackeando el Sistema de Transporte Metropolitano
categories: [netsec]
date: 2016-11-29
icon: pencil
header: omnibus.jpg
attribution: Matthew Henry

---

Publicado originalmente el .

_Ómnibus, del latín: Para todos_

STM nace con el ideal de llevar a Montevideo al siglo 21 ofreciendo una tarjeta de transporte
como las que hay en muchos otros lugares del mundo.

Más allá de la diversión técnica que trae crackear este tipo de tarjetas, la motivación
principal es el aparente conocimiento por parte del estado de las carencias de seguridad
de la misma. Véase la presentación más abajo.

## Érase una vez...

Desde la invención de [NFC](https://en.wikipedia.org/wiki/Near_field_communication),
la batalla por qué tipo de tarjeta es mejor ha sido fiera. Pero hubo una que 
se hizo extremadamente famosa luego de ser adoptada en varios lugares
del mundo para sistemas de transporte: la [Mifare Classic](https://en.wikipedia.org/wiki/MIFARE) de
la empresa NXP.

Todo este blogpost trata sobre un problema que han tenido las tarjetas Mifare desde el principio.
Siendo totalmente público desde el 2008, el mismo llevó a que la propia Mifare no
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

La vulnerabilidad afecta a todas y cada una de las tarjetas STM.

Para dar un poco de contexto, la siguiente es una presentación "interna" (gracias Google)
que explica todo el sistema de transporte. Antes de que me digan nada, es del
2008.

<iframe src="//www.slideshare.net/slideshow/embed_code/key/fyzLVFGy7yynyr" height="485" frameborder="0" marginwidth="0" marginheight="0" scrolling="no"> </iframe>
[Original](http://es.slideshare.net/alejandro.benitez/ssistema-de-transporte-montevideo-presentation)
[Mirror](/arquitectura-stm.ppt)

Más allá de la antigüedad de la presentación, lo que más me llama la atención es
la cantidad de información interna que hay.

## ... una tarjeta de transporte

Montevideo optó por un modelo de tarjeta NFC de la empresa NXP.
NFC es una tecnología que tiene muchos años en el mercado, es ese tipo de magia
negra que nos llena con la ilusión de estar viviendo en el futuro: transmisión de
datos sin contacto.
La elección del modelo de NXP sucedió hace ya mucho tiempo seguramente atado a
un bajo precio o quién sabe qué.

## ... que no era como las demás

![](/img/blog/stm.png)

Sabemos varias cosas: es una tecnología que lleva tiempo ahí afuera y que no es
particularmente cara.

En cualquier otro escenario esto no sería ningún problema, el problema es (como con todas
las ideas en general) la implementación, una idea no vale nada.

Dentro de la tecnología de la información hay dos escuelas: la cerrada, que pregona
que toda tecnología privada y sellada es más valiosa; y la otra, donde optamos por compartir lo que sabemos (y se nos tilda
de hippies que no entendemos nada en el proceso).

Mi mentor una vez me dijo: "nunca uses un algoritmo que no haya sido evaluado por
pares; cuantos más ojos miren, más van a poder encontrar los errores". Me tomó 15
años encontrar un caso tan evidente como este.

NXP, la empresa detrás del desarrollo de la tarjeta STM decidió usar su propio
sistema criptográfico conocido como [CRYPTO1](https://en.wikipedia.org/wiki/Crypto-1).

Como se imaginarán, esa no fue una idea demasiado brillante.

La seguridad por oscuridad tiende a colapsar ante el primer vestigio de luz.

Unos meses después del lanzamiento de la tarjeta ya exisitía un _exploit_.
El problema radica en la generación de números al azar ([RNG](https://en.wikipedia.org/wiki/Random_number_generation)) de la tarjeta donde
por una mala implementación el azar es predecible.
Así nació [CRAPTO1](http://crapto1.netgarage.org/).

## ... y quería que todos viajaran.

![](/img/blog/dump.jpg)

Esta es la parte jugosa.

Sabemos cómo funciona y sabemos cómo puede llegar a fallar.
Ahora, ¿qué tan fácil es viajar gratis en el sistema de transporte metropolitano?

¿Qué información habrá en su interior?
¿Podrá ser víctima de un [Replay Attack](https://en.wikipedia.org/wiki/Replay_attack)?
Es decir, ¿se podrá clonar la tarjeta y/o restaurarla a un estado anterior
terminando así con (a efectos prácticos) saldo ilimitado?

Mi investigación llevó un tiempo, desde la comprensión del problema hasta el acceso
al hardware necesario.

Al día de hoy el costo de toda la investigación fue de $40 dólares de Trump ^_^.

Pero no siempre fue así.

La historia comienza cuando pude tener acceso a un lector NFC de bajo costo.
El modelo que elegí fue el [PN532](https://www.adafruit.com/product/364) que sabía tenía buena compatibildad con
Raspberry Pi. Esta elección se daba por lo siguiente:

El modelo de tarjeta NFC de la STM está dividida en sectores, y para tener acceso a
cada sector se necesita una clave de lectura y otra de escritura.

Dado el problema en la generación de números aleatorios de la tarjeta, teniendo
una clave cualquiera de las 32 posibles de una tarjeta se puede inferir el valor de
todas las restantes.
Esto puede ser un proceso tedioso de entre 5 minutos a algunas horas, pero garantiza
una copia completa de la tarjeta siempre... siempre y cuando se tenga paciencia.

Mi enfoque original era bastante optimista, asumí que durante la implementación
no habrían cambiado alguna de las claves que vienen en la tarjeta por defecto. Pero 
en defensa de quien sea que lo haya implementado, efectivamente cambiaron las claves
por defecto de la tarjeta.

Pero aún no termina la historia, si bien es *más fácil* acceder a una tarjeta teniendo
una de las claves, también existe otra manera: fuerza bruta.

Es por ese motivo que queria una Raspberry Pi: armé un setup con una Pi y el lector,
redundancia electrica, una alerta para cuando encontrara algo, y tiré una moneda al aire.

4 días después me llené de euforia al ver esa clave hexadecimal: `0xd14400000000`

Bueno, no esa... puse en cero algunos valores para hacerlo más interesante :P.

Habiendo conseguido esa clave pude inferir el resto de las claves de la tarjeta.

Pero, ¿cuál es la gracia si sólo se puede hacer en una tarjeta? Hay una cantidad
gigante de claves ahí afuera, todos sabemos que repetir este proceso por cada
una de ellas es ridículamente trabajoso... a menos que...

Intetando reproducir el experimento en otra tarjeta me cansé de esperar el ataque
de fuerza bruta y probé las 32 claves que ya tenía de la tarjeta original.

31 claves denegadas después noté algo interesante... la primer clave de lectura
del primer sector de todas las tarjetas es la misma.
Usando esta clave "maestra" todo el resto de claves pueden ser inferidas.

![](/img/blog/proxmark3.jpg)

Con mejor hardware, como un lector Proxmark3 el tiempo de crackeo de la clave
es de menos de 10 segundos.

## Un vestigio de luz.

Ahora ilumenemos todo el cuarto y veamos cómo funciona la STM.

En el momento que un usuario compra su tarjeta de transporte se asocia el UID
de la tarjeta NFC a la cédula, sin puntos ni guiones:

`UID: 123123123123 -> CI: 12346789`

En caso de perder la tarjeta y solicitar una nueva se repite el proceso,
pero la cédula (o usuario en este caso) cambia a `12346789_2`, o sea, un guión bajo
más el `n` siguiente.

Esto trae muchos problmeas, empezando por el anonimato: cada ruta de un portador
de tarjeta STM puede ser inferida con bastante facilidad, pero no sólo eso.
Los `UID` de las tarjetas NFC pueden ser leídos sin necesidad de una clave de
lectura, por lo tanto un agente externo puede "identificar" a un usuario desde una
distancia prudencial.

Luego, al subir a un ómnibus y acercar la tarjeta al lector sucede lo siguiente:
se lee el primer sector con la clave maestra que irónicamente guarda el `UID` de
la tarjeta, seguramente como validación. Con ese `UID` se calculan los valores
de las claves de los siguientes sectores.

Se siguen varias de las recomendaciones de seguridad que les pide Mifare a los que
usen este modelo viejo que son: contadores (que aumentan y decrecen) y que los datos
como las fechas y el crédito no estén en texto plano (por suerte). Están guardados
usando [XOR](https://en.wikipedia.org/wiki/Exclusive_or).

Ese registro de crédito pasa a la computadora de abordo, ubicada arriba a la derecha
entrando al ómnibus. Que tiene un pendrive que guarda los datos de las tarjetas
y sus rutas y es entregado con la recaudación al final de cada jornada.

Es decir, el registro de boletos y su crédito es guardado de forma offline, y luego
(¿diariamente?) es actualizado en una base central.

Lo que nos da como única fuente de la verdad a la tarjeta STM.
Una tarjeta hackeable.

La tarjeta (en su implementación) es vulnerable a lo que se conoce como [Replay Attack](https://en.wikipedia.org/wiki/Replay_attack)
ya que si guardamos una imagen de la tarjeta con $2000 podemos restaurarla
a su estado anterior.

Incluso el uso de emuladores NFC como el Proxmark3 hacen posible tener un
dispositivo con saldo perpetuo.

## Destino.

El problema no radica exclusivamente en la ejecución de la solución, sino en la
falta de control que los sistemas estatales (y no estatales) tienen.
El objetivo de esta investigación es entender un sistema y sus piezas móviles, no
el abuso del mismo.

Cabe aclarar que no somos la excepción en la región, tanto la SUBE de Argentina,
como la BIP! de Chile son vulnerables al mismo ataque.
La única curiosidad que tengo es que nuestro sistema fue implementado *luego* de
que este modelo de tarjeta se haya mostrado como vulnerable.

