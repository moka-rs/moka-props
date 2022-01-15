use std::time::Duration;

use moka::sync::Cache;

rustler::init!("Elixir.MokaCache", [create_cache, drop_cache, insert, get, invalidate]);

mod atoms {
    rustler::atoms! {
        ok,
    }
}

mod registry {

    use std::sync::Mutex;

    use dashmap::{mapref::one::Ref, DashMap};
    use moka::sync::Cache;
    use nanoid::nanoid;
    use once_cell::sync::Lazy;

    static REGISTRY: Lazy<DashMap<String, Cache<String, String>>> = Lazy::new(|| DashMap::new());

    static REGISTRY_LOCK: Lazy<Mutex<()>> = Lazy::new(|| Mutex::new(()));

    pub(crate) fn register(cache: Cache<String, String>) -> String {
        let _lock = REGISTRY_LOCK.lock().unwrap();
        loop {
            let id = nanoid!();
            if REGISTRY.contains_key(&id) {
                continue; // Retry
            }
            if REGISTRY.insert(id.clone(), cache).is_none() {
                return id; // Done
            } else {
                panic!("Cache with the same ID already exists: {}", id);
            }
        }
    }

    pub(crate) fn get(id: &str) -> Option<Ref<'_, String, Cache<String, String>>> {
        REGISTRY.get(id)
    }

    pub(crate) fn remove(id: &str) {
        let _lock = REGISTRY_LOCK.lock().unwrap();
        REGISTRY.remove(id);
    }
}

#[rustler::nif]
pub fn create_cache() -> String {
    let cache = Cache::builder()
        .max_capacity(1_000)
        .time_to_live(Duration::from_secs(5))
        .build();
    registry::register(cache)
}

#[rustler::nif]
pub fn drop_cache(cache_id: String) -> rustler::Atom {
    registry::remove(&cache_id);
    atoms::ok()
}

#[rustler::nif]
pub fn insert(cache_id: String, key: String, value: String) -> rustler::Atom {
    registry::get(&cache_id).unwrap().insert(key, value);
    atoms::ok()
}

#[rustler::nif]
pub fn get(cache_id: String, key: String) -> Option<String> {
    registry::get(&cache_id).unwrap().get(&key)
}

#[rustler::nif]
pub fn invalidate(cache_id: String, key: String) -> rustler::Atom {
    registry::get(&cache_id).unwrap().invalidate(&key);
    atoms::ok()
}
