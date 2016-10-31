---
layout: post
title: Destruyendo el sistema bancario
subtitle: Algunas personas sólo quieren ver el mundo arder
token: destroy-bank
lang: es
categories: [code, netsec]
icon: pencil
date: 2016-10-25
header: bank-fire.jpg
attribution: Christopher Cook

---
_Originalmente publicado el 25 de Octubre de 2016_

Bueno. Ese fue terrible _clickbait_, no? Este blogpost no es acerca de ninguna
postura política sobre cómo destruir el capitalismo ni nada por el estilo. No es
sobre cómo "teóricamente" se puede destruir el sistema bancario...

Este blogpost es sobre cómo pude haber destruido el sistema económico de 
Uruguay por un pequeño _bug_ en una aplicación de _e-banking_.

Esta historia empieza hace mucho tiempo -al menos para los tiempos que se 
manejan en internet-, cuando uno de los bancos de mi país sacó una campaña
diciéndole a todos sus usuarios que tenían una aplicación móvil nueva. 
Fantástico.
Lo bueno es que está bastante bien diseñada y funciona en iOS y Android.
Lo malo es que era la mitad de la noche y yo estaba lo suficientemente borracho
como para tratar de destrozarla.

## Disclaimer

Después de intentar comunicarme varias veces de una forma segura con el
propio banco terminé consiguiendo el e-mail de un directivo y el _bug_ fue
reportado en detalle el 7 de julio.

Se siguió el _thread_ sobre el _bug_ con varias notas que sería arreglado "la
próxima semana".

## Expectativas

Tengo unas expectativas de lo que una aplicación de _e-banking_ debería hacer:

* SSL en todo.
* SSL _pinning_ del lado de la aplicación.
* Manejo adecuado de las claves.

Esta es una pequeña lista sobre las cosas que una aplicación debería considerar
y cosas que los _pentesters_ deberían revisar en sus tests.

Sólo quiero recordarles que Pokémon Go sí tiene SSL _pinning_...

## Realidad

Ninguna de las tres estaba presente, así que empecé a escarvar... profundo.

Primero lo primero, reconocimiento.

Ya que la aplicacion no configuró [SSL _pinning_](https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning) correctamente
es muy fácil intentar un [MITM _attack_](https://en.wikipedia.org/wiki/Man-in-the-middle_attack)
con sólo agregar un certificado raíz a mi dispositivo que me permita interceptar
todas las llamadas.

Fue una sorpresa encontrar que no **TODAS** las llamadas tuvieran SSL.
Todos los recursos del banco estaban siendo descargados correctamente sobre 
HTTPS, pero uno de ellos no y casualmente era un archivo Javascript.
¿Un Javascript? ¿Por qué? Sólo por curiosidad lo miré:

```
http://maps.googleapis.com/maps/api/js
```

Entonces, tenemos una transferencia por HTTP plano pidiendo el Google Map JS API
directamente a la aplicación para poder ver un mapa de todos los bancos.
Entonces lo lógico sería que en la app hubiera una WebView embebida por alguna razón.

Intercepté la llamada sólo probando una simple inyección XSS. ¡Bingo! Puedo
ejecutar cualquier JS internamente a la aplicación. ¿Qué más?

Teniendo la habilidad de inyectar cualquier JS, me dio curiosidad saber si la
aplicación no era más que un sitio web empaquetado con [Cordova](https://cordova.apache.org/),
conviertiendo toda la aplicación en un simple programa JS y por ende
dándome la opción de investigar cada rincón de ella.

Como uno esperaría siendo una aplicación que maneja dinero **REAL** de gente
**REAL** era... solamente un programa JS. Un programa usando [Ionic](http://ionicframework.com/)
empaquetado con Cordova para ser más preciso.

Cómo es que sé esto? Se acuerdan que era posible ejecutar **CUALQUIER** JS
en la aplicación?
Bueno, como podía ejecutar lo que yo quisiera inicié un servidor de [Weinre](https://people.apache.org/~pmuellr/weinre/docs/latest/Home.html) en mi máquina.
Esta herramienta facilita el _debugging_ de una aplicación JS dentro del dispositivo.
Extremadamente útil para saber qué esta sucediendo en el dispositivo, y en este
escenario muy útil para inspeccionar todo el flujo de información que pasa
por la aplicación.

Ya que la aplicación era en su totalidad un sitio web, esta herramienta de 
ejecución de código remoto me permitió ejecutar y cambiar lo que quisiese.
Este camino demostró ser útil únicamente para cambiar el logo del banco 
por un Dickbutt y publicar todo esto en Twitter porque... bueno...
estaba borracho.

Di el día por terminado, ya había hecho mucho.

## El fin está cerca.

Quería saber más y tenía todo para aprender de los recursos del banco y del
código de la propia aplicación. Como toda la aplicación es JS es posible
conseguir esto:

![](/img/blog/bank-code.png)

Todo, a la mano.

Entonces, tenemos el código de la aplicación, los recursos, la estructura, y una
manera de acceder a todo y modificarlo ya que es sólo JS.

Teniendo acceso al código que se está ejecutando me dio curiosidad saber si
información estaba siendo guardada en `localStorage`... para mi horror encontré
la sesión actual en `access_token` ahí... esperando.

![](/img/blog/bank-localstorage.jpg)

## Prueba de Concepto

Pero, qué tipo de vector de ataque podemos usar?
Tenemos muchas opciones

Un ataque posible sólo para divertirme fue hacer SSID _spoofing_ con un MITM _injection_.

Cualquier wifi pública (y muchas privadas) son claramente no seguras y pueden ser
fácilmente atacables: https://medium.com/matter/heres-why-public-wifi-is-a-public-health-hazard-dd5b8dcb55e6

El concepto es muy simple, tenemos una Raspberry Pi:
![](/img/blog/pi-in-the-middle.jpg)

Esta pequeña bestia clona un SSID y usa la segunda antena para darle a la
víctima(s?) acceso a Internet y poder ocultarse a simple vista.

## El mundo en llamas.

Todo este suspenso fue por una razón.

Usando este ataque **teórico** podemos obtener usuario y password de cualquier
usuario... y por si fuera poco podemos usar las credenciales que están guardadas
en la aplicación para hacer menos esfuerzo.

El tema es: puede que quieras robarle a personas... está mal y merecés ser
procesado. Pero talvez, y sólo talvez, también puede ser un mensaje.

$0.01 es el monto mínimo posible para una transferencia entre cuentas, y los 
propietarios de las mismas no serían notificados (ya que no hay ningún 
mecanismo de notificación).

Tener acceso a un manojo de cuentas le permitiría a un atacante congelar
el sistema bancario por un tiempo considerable.

El máximo a transferir entre cuentas sin ningún tipo de _token_ o autenticación
a dos pasos es de USD 1000.

Entonces el daño máximo posible es la transferencia mínima (0.01) * el límite de
transferencias (1000), y aprovechando el hecho de que el límite máximo es en
dólares americanos y el mínimo es en pesos uruguayos tenemos que:

```
1000 * 27 / 0.01 = 2.700.000 transactions.
```

Y eso es solamente para una cuenta.

Siempre se pueden usar cantidades al azar en las transacciones para joder todo
aún mas.
Todo el sistema económico DDOSeado por un error tonto, en un día. Incontables
horas hombre para revertir algo que no debería estar ahí.

Y si expanden el alcance siempre se pueden intentar transacciones a otos países
sólo para ver qué pasa.

## Conclusión

Estamos cagados. Fin.
La tecnología es parte de nuestras sociedades pero aún así la tratamos como magia,
como un callejón oscuro y misterioso.

La confianza es fundamental en nuestro mundo actual. Nuestros bancos, nuestros
gobernantes, nosotros confiamos en ellos por ninguna otra razón más allá de que
se supone que confiemos.

Ser evaluado por nuestros pares no sólo es una de las mejores maneras de mejorar el
código, sino además un estándar en la investigación de seguridad que DEBERÍA ser
parte de cualquier ciclo de desarrollo. Ayer.

Creemos que la seguridad y el _hacking_ es algo que le sucede a otra gente, en
otros países. Internet nos enseñó que las fronteras son cosas del pasado, algo
de un libro de geografía.

Tenemos que pensar en seguridad, necesitamos DEMANDAR seguridad y transparencia a
todos nuestros antiguos sistemas como lo son los bancos. Tenemos que adoptar
estándares de _infosec_.

Sólo hace falta un mal día para hacer que el castillo de cartas se derrumbe.
Claro, hipotéticamente.

