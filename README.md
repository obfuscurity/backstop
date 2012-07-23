# Backstop

Backstop is a simple endpoint for submitting metrics to Graphite. It accepts JSON data via HTTP POST and proxies the data to one or more Carbon/Graphite listeners.

## Usage

### Collectd Metrics

Backstop supports submission of metrics via the Collectd [write_http](http://collectd.org/wiki/index.php/Plugin:Write_HTTP) output plugin. A sample client configuration:

```
<Plugin write_http>
  <URL "https://backstop.example.com/collectd">
    Format "JSON"
    User ""
    Password ""
  </URL>
</Plugin>
```

### GitHub Post-Receive Hooks

Backstop can receive commit data from GitHub [post-receive webhooks](https://help.github.com/articles/post-receive-hooks). Your WebHook URL should consist of the Backstop service URL with the `/github` endpoint. For example, `https://backstop.example.com/github`.

All GitHub commit metrics contain the project name, branch information, author email and commit identifier, and are stored with a value of `1`. These can then be visualized as annotation-style metrics using Graphite's `drawAsFinite()` function. Sample metric:

```
github.project.refs.heads.master.bob-example-com.10af2cb02eadd4cb1a3e43aa9cae47ef2cd07016 1 1203116237
```

### Custom Metrics

Use the `/publish` endpoint in conjunction with one of the approved `PREFIXES` for submitting metrics to Backstop. In most environments it makes sense to use distinct prefixes for normal (e.g. gauge, counters, etc) metrics vs annotation (event-style) metrics.

#### Sending Metrics

Here is a basic example for posting an application metric to the `custom` prefix.

```ruby
RestClient.post("https://backstop.example.com/publish/custom",
   [{:metric => key, :value => value, :measure_time => Time.now.to_i}].to_json)
```

#### Sending Annotations

Here is an example for posting a software release announcement to the `note` prefix.

```ruby
RestClient.post("https://backstop.example.com/publish/note",
   [{:metric => "foobar.release", :value => "v214", :measure_time => Time.now.to_i}].to_json)
```

## Deployment

### Local

```bash
$ export CARBON_URLS=...
$ export PREFIXES=...
$ foreman start
```

### Platform

```bash
$ heroku create -s cedar
$ heroku config:add CARBON_URLS=...
$ heroku config:add PREFIXES=...
$ git push heroku master
```

## License

Backstop is distributed under a 3-clause BSD license.

## Thanks

Thanks to Michael Gorsuch (@gorsuch) for his work on the collectd parser and the "Mitt" application that preceded Backstop.

