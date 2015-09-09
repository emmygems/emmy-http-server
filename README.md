# EmmyHttp::Server


## Usage

```ruby
server do
  connect do |req, res|
    response.success()
  end
end

bind *server
```

### Routing

```ruby
server do
  get '/' do
    #...
  end
end

bind *server
```

### Rack support

```ruby
app do
  use Rack::Logger

  #run Sinatra::Application
  get '/' do
    #...
  end
end

bind *app
```
