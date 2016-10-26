---
layout: post
title: Destruyendo el sistema bancario
subtitle: Algunas personas solo quieren ver el mundo arder
token: destroy-bank
lang: es
categories: [code, netsec]
icon: pencil
date: 2016-10-25
header: bank-fire.jpg
attribution: Christopher Cook

---
_Originalmente publicado el 25 de Octubre de 2016_

Bueno, ese fue terrible clickbaith no?. Este blogpost no es acerca de ninguna
postura politica sobre como destruir el capitalismo o nada por el estilo, no es
sobre como "teóricamente" se puede destruir el sitema bancario... este blogpost
es sobre como pude haber destruído el sistema economico de Uruguay por un
pequeño bug en una aplicación de ebanking.

Esta historia empieza hace mucho tiempo, no hace mucho tiempo en los tiempos que
maneja la internet.
Uno de los bancos de mi pais sacó una campaña diciendole a todos sus usuarios
que tenían una aplicación móvil nueva. Fantastico.
Lo bueno es que está bastante bien diseñada y funciona en iOS y Android.
Lo malo es que era la mitad de la noche y yo estaba suficientemente borracho
como para tratar de destrozarla.

## Disclaimer

Después de intentar varias veces de comunicarme en una manera segura con el
propio banco termine consiguiendo el email de un directivo y el bug fue
reportado con detalle el 7 de Julio.

Se siguió el thread sobre el bug con varias notas que "Sería arreglado la
próxima semana"

## Expectativas

Tengo unas expectativas de lo que una aplicación de ebanking debería hacer:

* SSL en todo.
* SSL pinning del lado de la aplicación.
* Manejo adecuado de las claves.

Esta es una pequeña lista sobre las cosas que una aplicación debería considerar
y cosas que los pentesters deberían revisar en sus tests.

Solo quiero recordarles que Pokemon Go tiene SSL pinning...

## Realidad

Ninguna de las tres estaba presente, asi que empecé a escarvar... profundo.

Primero lo primero, reconocimiento.

Ya que la aplicacion no configuro [SSL pinning](https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning) correctamente
es muy fácil intentar un [MITM attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack)
solo agregando un certificado raiz a mi dispositivo que me permita interceptar
todas las llamadas.

Fue una sorpresa encontrar que no **TODAS** las llamadas tuvieran SSL.
Todos los recursos del banco estaban correctamente como HTTPS pero uno de ellos
no y casualmente era un Javascript.
Un Javascript? Por qué? Solo por curiosidad lo miré:

```
http://maps.googleapis.com/maps/api/js
```

Entonces, tenemos un archivo HTTP plano pidiendo el Google Map JS API
directamente a la aplicacion para poder ver un mapa de todos los bancos.
Entonces lo lógico sería una WebView embebida por alguna razón.

Intercepté la llamada solo probando una simple injección XSS. Bingo! Puedo
ejecutar cualquier JS internamente a la aplicación, que más?

Teniendo la habilidad de inyectar cualquier JS  me dio curiosidad que la
aplicación no fuera mas que un sitio web empaquetado en [Cordova](https://cordova.apache.org/)
conviertiendo toda la aplicación en solo un programa en JS y con eso  dandome la opción de investigar cada
rincón de ella.

Como uno esperaría siendo una aplicación que maneja dinero **REAL** de gente
**REAL** era... solamente un programa JS, un programa usando [Ionic](http://ionicframework.com/)
empaquetado con Cordova para ser mas explicito.

Cómo es que sé esto? Bueno, se acuerdan que es posible ejecutar **CUALQUIER** JS
en la aplicación?.
Bueno, como puedo ejecutar lo que sea inicié un servidor de [Weinre](https://people.apache.org/~pmuellr/weinre/docs/latest/Home.html) en mi maquina.
Esta herramienta facilita el debug de una aplicación JS dentro del dispositivo.
Extremadamente util para saber que esta sucediendo en el dispositivo y en este
escenario muy util para ver todo lo que pasa.

Esta herramienta de ejecución de código remoto (y ya que la aplicación era solo
un sitio web) me permitió ejecutar y cambiar lo que quisiese.
Este camiino demostró solo útil para cambiar el logo del banco por un Dickbutt y
publicando todo esto en Twitter... porque bueno... estaba borracho.

Di el dia por terminado, ya hice mucho.

## El fin esta cerca.

Quería saber mas y tenía todo para aprender de los recursos del banco y del
código de la propia aplicación. Como toda la aplicación es JS es posible
conseguir esto:

![](/img/blog/bank-code.png)

Todo, a la mano.

Entonces, tenemos el código de la aplicación, los recursos, la estructura y una
manera de acceder a todo y modificarlo ya que es solo JS.

Teniendo acceso la código que se esta ejecutando me dió curiosidad de que
informacion estaba siendo guardada en `localStorage`... para mi horror encontré
la sesión actual en `access_token` ahí... esperando.

![](/img/blog/bank-localstorage.jpg)

## Prueba de Concepto

Pero que tipo de vector de ataque podemos usar?
Tenemos muchas opciones

Un ataque posible solo para divertirme fue SSID spoofing con un MITM injection.

Cualquier wifi pública (y muchas privadas) son claramente no seguras y pueden ser
facilmente atacables: https://medium.com/matter/heres-why-public-wifi-is-a-public-health-hazard-dd5b8dcb55e6

El concepto es muy simple, tenemos una Raspberry Pi:
![](/img/blog/pi-in-the-middle.jpg)

Esta pequeña bestia clona un SSID y usa la segunda antena para darle a la
victima(s?) acceso a Internet y poder ocultarse a simple vista.

## El mundo en llamas.

Todo este suspenso fue por una razón.

Usando este ataque **teorico** podemos obtener usuario y password de cualquier
usuario... y por si fuera poco podemos usar las credenciales que estan guardadas
en la aplicación para hacer menos esfuerzo.

El tema es: puede que quieras robarle a personas... está mal y merecés ser
procesado pero talvez, y solo talvez, también puede ser un mensaje.

$0.01 es la mínima trasferencia posible entre cuentas entre cuentas y no serias
notificados (ya que no hay ningún tipo de notificación).

Teniendo acceso a un manojo de cuentas le puede permitir a un atacante congelar
el sistema bancario por un tiempo considerable.

La máxima transferencia entre cuentas sin ningún tipo de token o autenticación a
dos pasos son $1000.

Entonces el daño máximo posible es la transferencia minima (0.01) * el límite de
transferencias (1000) pero entonces podemos aprovecharnos de que el límite es en
dólares americanos pero el mínimo es 0.01 pesos uruguayos.

```
1000 * 27 / 0.01 = 2.700.000 transactions.
```

Y eso es solamente para una cuenta.

Siempre se pueden usar cantidades al azar en las transacciones para joder todo
aún mas.
Todo el sistema económico DDOSeado por un error tonto, en un día. Incontables
horas hombre para revertir algo que no debería estar ahí.

Y si expanden el alcance siempre se pueden intentar transacciones a otors países
solo para ver que pasa.

## Conclusión

Estamos cagados. Fin.
La tecnología es parte de nuestras socieded pero aún así la tratamos como magia,
como un callejón oscuro y misterioso.

La confianza es fundamental en nuestro mundo actual. Nuestros bancos, nuestros
gobernantes, nosotros confiamos en ellos por ninguna otra razón mas allá de que
se supone que confiemos.

Ser evaluado por nuestros pares es una de las mejores maneras de mejorar el
código pero ademas un standard en la investigación de seguridad que DEBERÍA ser
parte de cualquier ciclo de desarrollo ayer.

Creemos que la seguridad y el hacking es algo que le sucede a otra gente, en
otros países. Internet nos enseño que las fronteras son cosas del pasado, algo
de un libro de geografía.

Tenemos que pensar en seguridad, necesitamos DEMANDAR seguridad y transparencia a
todos nuestros antigüos sistemas como lo son los bancos. Tenemos que adoptar
standares de infosec.

Es solo necesario un mal dia para hacer que el castillo de cartas se derruble.
Claro, hipoteticamente.

