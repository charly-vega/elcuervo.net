---
layout: post
title: Destroying the banking system
subtitle: Some men just want to watch the world burn
token: destroy-bank
lang: en
categories: [code, netsec]
icon: pencil
date: 2016-10-25
header: bank-fire.jpg
attribution: Christopher Cook

---
_Originally published October 25th 2016_

Well, that's a big ass clickbaith right?. This blogpost is not about any
political statement on how to destroy capitalism or whatever, it's not on how to
theorically destroy the banking system... this blogpost is about how I could've
destroyed the economic system in Uruguay due to a tiny bug in an ebanking
application.

This story begins a lot of time ago, well, a lot in Internet noteworthy time at
least.
One of the banks of my country emailed telling all their users that they
have a brand new mobile app, pretty sweet right?.
The good part is that it is pretty well designed and it runs both in iOS and
Android.
The bad part is that it was late at night and I was drunk so I gave it a try to
torn it apart.

## Disclaimer

After attempting several times to communicate in a safe way to the bank itself I
ended up getting a manager email and the bug was reported in detail on July 7th.

There was several follow ups on the matter with the answer of the bug going to
be fixed "next week".

## Expectations

I have some expectations on what a mobile ebanking app should do:

* SSL in all the endpoints.
* SSL pinning on the app side.
* Proper keys storage.

This is a small list on things that apps should take in consideration and things
that pentesters should enforce in their tests.
I want to remember you that Pokemon Go has SSL pinning...

## Reality

None of the above were present, so I started digging... deep.

First things first, reconnaissance.
Since the app didn't configure [SSL pinning](https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning),
I could set up a [MITM attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack)
just adding a root certificate to my device that allows the proxy to intercept
the requests.

To my surprise not **ALL** the request were SSL. All the bank endpoints were
correctly set to HTTPS but one of them were not and it was a Javascript file.
A Javascript file? Why? For the sake of curiosity I inspected the request:

```
http://maps.googleapis.com/maps/api/js
```

So we have a plain HTTP request to Google Map JS API and in the app itself we have a
pretty map with all the banks. So I expected a WebView that embeded the map for
some reason.

I hijacked the request just trying some simple XSS injection. Bingo! I could
execute any JS script in the app but what else?.

Having the ability to inject JS I doubted that app itself was just a website
wrapped in [Cordova](https://cordova.apache.org/) or something converting the
whole app in just a JS program giving me the option to go through all the
corners of it.

As you might expect being a sensitve application handling **REAL** money of
**REAL** people... it was a JS program, an [Ionic](http://ionicframework.com/)
app wrapped in Cordova being more explicit.

How do I know this? Well, remember that I can execute **ANY** JS in the app?.
Well since I just can I started a [Weinre](https://people.apache.org/~pmuellr/weinre/docs/latest/Home.html) server in my machine, this tool is used to debug your JS
application in the device. Really useful to see what's going on the device and
in this scenario really handy to dig through everything.

This remote execution tool and since the app itself is just a webpage allowed me
to execute code and change anything in my device.
This endeavour proven to be worthy only for changing the bank's logo for
Dickbutt and publishing that information in Twitter, remember... I was drunk.

<blockquote class="twitter-tweet" data-lang="en"><p lang="es" dir="ltr">Banco. Me voy a dormir. Que descanses: <a href="https://t.co/KEmmghnWmW">pic.twitter.com/KEmmghnWmW</a></p>&mdash; Cuervo (@cuerbot) <a href="https://twitter.com/cuerbot/status/684239299773116416">January 5, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

I called it a day I had enough.

## The end is near

I wanted to know more and I have everything to learn all the banks endpoints
and the app code itself. Remember that in this world everything is JS?:

![](/img/blog/bank-code.png)

Everything there, ready for the taking.

So, we have the application code, the endpoints, the markup and a way to access
it and since it's JS a way to modify it on the fly.

Having access to the running code itself gave me curiosity on what information
is being stored in `localStorage`... for my horror I found the current session
`access_token` just there... Waiting.

![](/img/blog/bank-localstorage.jpg)

## PoC

What's the attack vector for this?
We have several ones.

One approach possible just for the lolz is SSID spoofing with a MITM injection.

Public wifi (and some private ones) are known to not being secure and easily
exploitable: https://medium.com/matter/heres-why-public-wifi-is-a-public-health-hazard-dd5b8dcb55e6

The concept is really simple, we have a Raspberry Pi:
![](/img/blog/pi-in-the-middle.jpg)

And this little beauty just clones a give SSID and uses the second antenna to
give the victim(s?) Internet access and just be hidden at plain sight.

## The world on fire

All this buildup was for a reason.

Using this **theorical** attack we could get user and passwords from the
users... even if we don't want for any reason we can always use the stored
credentials in the client.

The thing is that you may want to steal from people... is wrong and you deserve
to be hunt down for it but maybe and just maybe it can also be a statement.

$0.01 is the less you can transfer between accounts and since you can basically
hijack an account without being truly noticed (since you can't see anything
really in the app).

Having access to a fair amount of accounts can allow an attacker to freeze the
banking system for a pretty big amount of time.

The maximum transfer between accounts without any kind of token or two factor
auth is $1000.

Then the maximum damage possible is the minimum transfer (0.01) * the transfer
limit (1000) but then we can also take advantage that the limit is in american
dollars but the minimum currency is 0.01 Uruguay pesos.

```
1000 * 27 / 0.01 = 2.700.000 transactions.
```

And that's just one account.

You can always use random transaction amounts to screw things up even better.
The whole economic system DDOSed with a silly bug, in a day. Countless hours of
manpower to revert something that shouldn't been there.

And if you expand your reach you can always try some other countries just for
the heat, just for the fire.

## Conclusion

We are fucked. Period.
Technology has taken over our society but we still treat it like magic, like a
dark and misterious alley.

Trust is a fundamental thing in our world nowdays. Our banks, our goverments, we
trust them for no real reason besides that we are supose to do it.

Peer reviews are one of the best ways to improve code quality but also standard
security research MUST be a part of software development yesterday.

We think security and hacking is a thing that happens to other people, to other
countries. Internet thought us that the borders are a thing of the past, a thing
that is found in a geography book.

We need to think about security, we need to DEMAND security and transparency to
arcane systems like banks. They need to adapt to current infosec standards.

You just need one bad day to see the house of cards crumble. You know, hypothetically.
