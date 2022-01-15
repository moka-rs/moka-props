defmodule MokaCache do
    use Rustler, otp_app: :moka_props, crate: "moka_cache"

    def create_cache(), do: :erlang.nif_error(:nif_not_loaded)

    def drop_cache(_cache_id), do: :erlang.nif_error(:nif_not_loaded)

    def insert(_cache_id, _key, _value), do: :erlang.nif_error(:nif_not_loaded)

    def get(_cache_id, _key), do: :erlang.nif_error(:nif_not_loaded)

    def invalidate(_cache_id, _key), do: :erlang.nif_error(:nif_not_loaded)

end
