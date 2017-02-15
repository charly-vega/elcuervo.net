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

_del latin: Para todos_

STM nace como un proyecto de Servicio de Transporte Metropolinao, nace con el
ideal de llevar a Montevideo al siglo 21 ofreciendo una tarjeta de transporte
como hay en cuelquier otro lugar del mundo.

## Disclaimer

Esto no es un reporte de vulnerabilidad, no hay ninguna vulnerabilida nueva, no
descubri nada nuevo bajo el sol.
Este es un problema que tienen las tarjetas Mifare desde el principio siendo
totalmente publico desde otros afectados en 2008 como: hasta la propia Mifare
que no recomiendo el uso de sus tarjetas Classic cuando la seguridad es algo
importante: http://www.nxp.com/products/identification-and-security/mifare-ics/mifare-classic:MC_41863

https://en.wikipedia.org/wiki/MIFARE#Security_of_MIFARE_Classic.2C_MIFARE_DESFire_and_MIFARE_Ultralight


> Following the broad acceptance of contactless ticketing technology and extraordinary success of the MIFARE Classic® product family, application requirements and security needs constantly increased. Therefore we do not recommend to use MIFARE Classic in security relevant applications anymore.

Bueno, empecemos con lo que nos atañe.
Esta es una explicación de una vulnerabilidad que tiene tantos años como el
producto en si.

La vulnerabilidad afecta todas y cada una de las tarjetas STM.

Para dar un poco de contexto esta es una presentación "interna" (gracias Google)
de explicación de todo el sistema de transporte. Antes que me digan nada es del
2008.

<iframe src="//www.slideshare.net/slideshow/embed_code/key/fyzLVFGy7yynyr" height="485" frameborder="0" marginwidth="0" marginheight="0" scrolling="no"> </iframe>
[Original](http://es.slideshare.net/alejandro.benitez/ssistema-de-transporte-montevideo-presentation)
[Mirror](/arquitectura-stm.ppt)
