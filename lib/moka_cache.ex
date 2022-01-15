defmodule MokaCache do
    use Rustler, otp_app: :moka_props, crate: "moka_cache"

    # When your NIF is loaded, it will override this function.
    def create_cache(), do: :erlang.nif_error(:nif_not_loaded)

    def insert(_key, _value), do: :erlang.nif_error(:nif_not_loaded)

    def get(_key), do: :erlang.nif_error(:nif_not_loaded)

    def invalidate(_key), do: :erlang.nif_error(:nif_not_loaded)

end
