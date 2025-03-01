# Inertia Phoenix

Maintained by [Devato](https://devato.com)

[![CI](https://github.com/devato/inertia_phoenix/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/devato/inertia_phoenix/actions/workflows/ci.yml)
![Coverage](https://img.shields.io/coveralls/github/devato/inertia_phoenix/master)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/2aafaf190f434aca97c9734ae2395bcc)](https://app.codacy.com/gh/devato/inertia_phoenix?utm_source=github.com&utm_medium=referral&utm_content=devato/inertia_phoenix&utm_campaign=Badge_Grade_Dashboard)
[![Hex.pm](https://img.shields.io/hexpm/v/inertia_phoenix)](https://hex.pm/packages/inertia_phoenix)

Inertiajs Adapter for Elixir Phoenix

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Usage](#usage)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Render from Controller](#render-from-controller)
  - [Layout/Templates](#layouttemplates)
  - [Shared Data / Props](#shared-data--props)
    - [Shared Data Custom Plug](#shared-data-custom-plug)
  - [Handle Form Errors](#handle-form-errors)
  - [Configure Axios](#configure-axios)
- [Features](#features)
  - [Complete](#complete)
  - [In Progress](#in-progress)
- [Example Apps](#example-apps)
- [Contributing](#contributing)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Usage

Getting started with Inertia.js in a few steps.

## Installation

Add to mix.exs:
```elixir
{:inertia_phoenix, "~> 0.4.0"}
```

Add Plug to `WEB_PATH/router.ex`
```elixir
  pipeline :browser do
    ...
    plug InertiaPhoenix.Plug
  end
```

Import render_inertia `lib/active_web.ex`
```elixir
  def controller do
    quote do
      ...
      import InertiaPhoenix.Controller
    end
  end
```

## Configuration

Add to `config/config.exs`

```elixir
config :inertia_phoenix,
  assets_version: 1,          # default 1
  inertia_layout: "app.html"  # default app.html
```

- Asset Versioning Docs: https://inertiajs.com/asset-versioning

## Render from Controller

NOTE: Flash data is automatically passed through to the page props.

```elixir
def index(conn, _params) do
  render_inertia(conn, "Home", props: %{hello: "world"})

  # OR

  render_inertia(conn, "Home")
end
```

## Layout/Templates

- Doesn't require templates as Inertia Pages are templates.
- `div#app` is rendered automatically.

An example layout:

```eex
<!DOCTYPE html>
<html lang="en">
  <head>
    ...
  </head>
  <body>
    <%= @inner_content %>
    <script type="text/javascript" src="<%= Routes.static_path(@conn, "/js/app.js") %>"></script>
  </body>
</html>
```

## Shared Data / Props

Inertia.js Docs: https://inertiajs.com/shared-data

To share data:
```elixir
InertiaPhoenix.share(:hello, fn -> :world end)
InertiaPhoenix.share(:foo, :baz)
InertiaPhoenix.share("user", %{name: "José"})
```

NOTE: `props` will overwrite shared data.

### Shared Data Custom Plug

For more complex data, you can create a custom plug.

Here's an example from the PingCRM app:
```elixir
defmodule PingWeb.Plugs.InertiaShare do

  def init(default), do: default

  def call(conn, _) do
    conn
    |> InertiaPhoenix.share(:auth, build_auth_map(conn)),
    |> InertiaPhoenix.share(:errors, errors_from_session(conn))
  end

  defp build_auth_map(conn) do
    # build complex auth map
  end

  defp errors_from_session(conn) do
    errors = get_session(conn, :errors) 
    if is_map(errors) and map_size(errors) > 0 do
      errors
    else
      %{}
    end
  end
end
```
Then add it to any pipeline that makes sense in `myapp_web/router.ex`:

```elixir
pipeline :browser do
  ...
  plug PingWeb.Plugs.InertiaShare # put before main Plug
  plug InertiaPhoenix.Plug
end
```
## Handle Form Errors

Begin by assigning any errors to the session, under the key of `:errors` so they can be
shared with inertia via `InertiaShare` plug.

```elixir
conn
|> put_session(:errors, %{foo: "bar"})
```

If you are dealing with a changeset, which you most liekly will if you are dealing with
forms, then you can utilize the provided utility function to extract errors.

```elixir
defmodule MyAppWeb.GenericController do

    def index(conn, params) do
        case MyContext.operation(params) do
            {:ok, result} ->
                # continue with successful operation
            {:error, %Ecto.Changeset{} = changeset}  ->
                conn 
                # Helper function extracts and assigns appropriate errors from changeset
                |> put_errors(changeset)
                # Redirect back to the appropriate page
                |> redirect(to: new_path)
        end
    end
end
```

Any errors assigned with `put_errors` will appear under the `errors` prop on your page components as such.

```javascript
const { errors } = usePage().props
// { input_name: "validation errors for input of name 'input_name'"}
```


## Configure Axios

`XSRF-TOKEN` cookie is set automatically.

To configure axios to use it by default, in `app.js`
```javascript
import axios from "axios";
axios.defaults.xsrfHeaderName = "x-csrf-token";
```

# Features

## Complete
- Render React/Vue/Svelte from controllers
- Flash data passed to props via Plug
- Assets Versioning: https://inertiajs.com/asset-versioning
- Lazy Evaluation: https://inertiajs.com/responses#lazy-evaluation
- Auto put response cookie for crsf token: https://inertiajs.com/security#csrf-protection
- Override redirect codes: https://inertiajs.com/redirects#303-response-code
- Partial reloads: https://inertiajs.com/requests#partial-reloads
- Shared data interface: https://inertiajs.com/shared-data

## In Progress

[See Issue Tracker](https://github.com/devato/inertia_phoenix/issues)

# Example Apps

- N/A

# Contributing

[Contribution guidelines for this project](CONTRIBUTING.md)
