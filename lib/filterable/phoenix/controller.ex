defmodule Filterable.Phoenix.Controller do
  @moduledoc ~S"""
  Allows to extend Phoenix controller with `filterable` macros and functions.

      use Filterable.Phoenix.Controller

  Example:

      defmodule MyApp.PostController do
        use MyApp.Web, :controller
        use Filterable.Phoenix.Controller

        filterable do
          filter author(query, value, _conn) do
            query |> where(author_name: ^value)
          end
        end

        # /posts?author=Kafka
        def index(conn, params) do
          with {:ok, query, filter_values} <- apply_filters(Post, conn),
               posts                       <- Repo.all(query),
           do: render(conn, "index.json", posts: posts, meta: filter_values)
        end
      end
  """
  defmacro __using__(_) do
    quote do
      use Filterable

      @before_compile unquote(__MODULE__)
      @filters_module __MODULE__
      @filter_options []
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def apply_filters!(queryable, %Plug.Conn{params: params} = conn, opts \\ []) do
        Filterable.apply_filters!(queryable, params, @filters_module, filter_options(conn, opts))
      end

      def apply_filters(queryable, %Plug.Conn{params: params} = conn, opts \\ []) do
        Filterable.apply_filters(queryable, params, @filters_module, filter_options(conn, opts))
      end

      def filter_values(%Plug.Conn{params: params} = conn, opts \\ []) do
        Filterable.filter_values(params, @filters_module, filter_options(conn, opts))
      end

      def filter_options(conn, opts \\ []) do
        [share: conn] |> Keyword.merge(opts) |> Keyword.merge(@filter_options)
      end
    end
  end
end
