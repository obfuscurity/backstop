# Backstop

[![Build Status](https://secure.travis-ci.org/obfuscurity/backstop.png?branch=master)](http://travis-ci.org/obfuscurity/backstop)

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

All GitHub commit metrics contain the project name, branch information, author email and commit identifier, and are stored with a value of `1`. These can then be visualized as annotation-style metrics using Graphite's `drawAsInfinite()` function. Sample metric:

```
github.project.refs.heads.master.bob-example-com.10af2cb02eadd4cb1a3e43aa9cae47ef2cd07016 1 1203116237
```

### PagerDuty Incident Webhooks

Backstop can also receive PagerDuty incidents courtesy of Jesse Newland's [pagerduty-incident-webhooks](https://github.com/github/pagerduty-incident-webhooks) project. When deploying `pagerduty-incident-webhooks` make sure to set `PAGERDUTY_WEBHOOK_ENDPOINT` to your Backstop service URL with the `/pagerduty` endpoint. For example, `https://backstop.example.com/pagerduty`.

Metrics will be stored under the `alerts` prefix with a value of `1`. These can then be visualized as annotation-style metrics using Graphite's `drawAsInfinite()` function. Sample metric:

```
alerts.nagios.web1.diskspace 1 1365206103
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

#### Using with Hosted Graphite

Graphite hosting service [Hosted Graphite](https://www.hostedgraphite.com) requires metrics to be submitted with an API key prepended to the metric.  To use their service, just define the `API_KEY` environment variable.

## Deployment

Backstop supports optional Basic Authentication through Rack::Auth::Basic. Simply set BACKSTOP_AUTH to your colon-delimited credentials (e.g. `user:pass`).

### Local

The following instructions assume a working Ruby installation with the bundler gem already installed on your system.

```bash
$ git clone https://github.com/obfuscurity/backstop.git
$ cd backstop
$ bundle install
$ export CARBON_URLS=...
$ export PREFIXES=...
$ export BACKSTOP_AUTH=... (optional)
$ foreman start
```

### Heroku

```bash
$ heroku create
$ heroku config:add CARBON_URLS=...
$ heroku config:add PREFIXES=...
$ heroku config:add BACKSTOP_AUTH=... (optional)
$ git push heroku master
```

## License

Backstop is distributed under a 3-clause BSD license.

## Thanks

Thanks to Michael Gorsuch (@gorsuch) for his work on the collectd parser and the "Mitt" application that preceded Backstop.

