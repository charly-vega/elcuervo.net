---
title: Gost
subtitle: The Go simple worker
categories: [golang, oss]
date: 2014-02-21
icon: code
header: gost.jpg
attribution: emiliano-iko

---

There are a lot of fantastic projects out there. One of them being
[goworker](http://www.goworker.org/) which is a
[Resque](https://github.com/defunkt/resque) compatible project.

But sometimes you want something simpler. And as usual is easy to get that kind
of simplicity of the right Ruby projects.

This time the inspiration comes from [Ost](https://github.com/soveran/ost). This
is a lightweight lib to enqueue jobs to be executed in workers.

To push a job you simply do:

```ruby
Ost[:videos_to_process].push(@video.id)
```

And to do something with it:

```ruby
require "ost"

Ost[:videos_to_process].each do |id|
  # Do something with it!
end
```

Inspired bit its simplicity I wrote [Gost](https://github.com/elcuervo/gost) a
Go package that allows you to start Ost compatible queues or use it as it own
thing.

Some examples:


```go
import "github.com/elcuervo/gost"

// ...

gost := gost.Connect(":6379")
gost.Push("my_jobs", "id_to_be_procesed")
```

And that's it, the `id_to_be_procesed` id is pushed to the `my_jobs` queue ready
for the next worker to fetch it.

```go
gost.Each("my_jobs", func(id string) bool {
  if(doesSomethingWithTheId(id)) {
    // Everything is ok
    return true
  } else {
    // If the fn returns false the
    // items is kept in the backup key
    return false
  }
})
```

You can do more things like knowing how many items are to be executed:

```go
gost.Items("my_jobs")
```

Or stoping the worker. Useful if you want to make your worker gracefully exit
given a system signal.

```go
gost.Stop()
```
