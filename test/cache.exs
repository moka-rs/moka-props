defmodule Cache do

    defmodule ValueEntry do
        defstruct value: "", last_used: nil 
    end

    defstruct
        # The max capacity in number of entries.
        max_cap: 0,
        # The number of entries stored in this cache.
        size: 0,
        # The key value map. Stores pairs of key and value-entry.
        kv: %{},
        # The access order tree.
        # - Stores pairs of last used timestamp and key.
        # - These pairs are ordered by the last used timestamp.
        aot: :gb_trees.empty,
        # The frequency map. Stores pairs of key and access frequencies.
        freq: %{}

    def new(max_cap) do
        %Cache { max_cap: max_cap }
    end

    def is_empty(cache) do
        cache.size == 0
    end

    def get(cache, key) do
        freq = case Map.fetch(cache.freq, key) do
            {:ok, f} ->
                Map.put(cache.freq, key, f + 1)
            :error ->
                Map.put_new(cache.freq, key, 1)
        end

        cache = %Cache { cache | freq: freq }
        
        case Map.fetch(cache.kv, key) do
            :error ->
                {:none, cache}
            {:ok, entry} ->
                {:value, entry.value, cache} 
        end
    end

    def insert(cache, key, value) do
        case Map.fetch(cache.kv, key) do
            {:ok, entry} ->
                do_update(cache, key, value, entry)
            :error ->
                cond do
                    cache.size < cache.max_cap ->
                        do_insert(cache, key, value)
                    admit(cache, key) ->
                        cache = evict_lru(cache)
                        do_insert(cache, key, value)
                    true ->
                        # Rejected
                        cache
                end
        end
    end

    def invalidate(cache, key) do
        case Map.fetch(cache.kv, key) do
            {:ok, entry} ->
                do_invalidate(cache, key, entry)
            :error ->
                cache
        end
    end

    defp do_update(cache, key, value, entry) do
        now = now()
        aot = :gb_trees.delete(entry.last_used, cache.aot)
        aot = :gb_trees.insert(now, key, aot)
        entry = %ValueEntry { entry | value: value, last_used: now }
        kv = Map.put(cache.kv, key, entry)
        %Cache { cache | kv: kv, aot: aot }
    end

    defp admit(cache, key) do
        case Map.fetch(cache.freq, key) do
            :error ->
                false
            {:ok, f} ->
                {_, lru_key} = :gb_trees.smallest(cache.aot)
                {:ok, lru_f} = Map.fetch(cache.freq, lru_key)
                f > lru_f
        end
    end

    defp do_insert(cache, key, value) do
        now = now()
        entry = %ValueEntry { value: value, last_used: now }
        kv = Map.put_new(cache.kv, key, entry)
        aot = :gb_trees.insert(now, key, cache.aot)

        freq = case Map.fetch(cache.freq, key) do
            {:ok, f} ->
                # Already exist, no need to update
                cache.freq
            :error ->
                Map.put_new(cache.freq, key, 0)
        end

        %Cache { cache | kv: kv, aot: aot, freq: freq, size: cache.size + 1 }
    end

    defp evict_lru(cache) do
        case is_empty(cache) do
            true ->
                cache
            false ->
                {_, key, aot} = :gb_trees.take_smallest(cache.aot)
                kv = Map.delete(cache.kv, key)
                %Cache { cache | kv: kv, aot: aot, size: cache.size - 1 }
        end
    end

    defp do_invalidate(cache, key, entry) do
        kv = Map.delete(cache.kv, key)
        aot = :gb_trees.delete(entry.last_used, cache.aot)
        %Cache { cache | kv: kv, aot: aot, size: cache.size - 1 }
    end

    defp now() do
        :os.system_time(:micro_seconds)
    end
end
