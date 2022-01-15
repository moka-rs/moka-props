use std::time::Duration;

use moka::sync::Cache;
use once_cell::sync::OnceCell;

mod atoms {
    rustler::atoms! {
        ok,
    }
}

static SHARED_INSTANCE: OnceCell<Cache<String, String>> = OnceCell::new();

#[rustler::nif]
pub fn create_cache() -> rustler::Atom {
    let cache = Cache::builder()
        .max_capacity(1_000)
        .time_to_live(Duration::from_secs(5))
        .build();
    if let Err(_) = SHARED_INSTANCE.set(cache) {
        panic!("Could not initialize the cache");
    }
    atoms::ok()
}

#[rustler::nif]
pub fn insert(key: String, value: String) -> rustler::Atom {
    shared().insert(key, value);
    atoms::ok()
}

#[rustler::nif]
pub fn get(key: String) -> Option<String> {
    shared().get(&key)
}

#[rustler::nif]
pub fn invalidate(key: String) -> rustler::Atom {
    shared().invalidate(&key);
    atoms::ok()
}

fn shared() -> &'static Cache<String, String> {
    if let Some(cache) = SHARED_INSTANCE.get() {
        cache
    } else {
        panic!("The cache has not been initialized");
    }
}

rustler::init!("Elixir.MokaCache", [create_cache, insert, get, invalidate]);
