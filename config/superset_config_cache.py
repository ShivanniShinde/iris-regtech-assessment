# superset_config.py additions — Redis caching configuration
# (Task 6.2 — Superset Caching Configuration)

from cachelib.redis import RedisCache

PUBLIC_ROLE_LIKE_GAMMA = False

FEATURE_FLAGS = {
    "ALERT_REPORTS": True,
    "DRILL_TO_DETAIL": True,
    "DRILL_BY": True,
}

CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 300,          # 5 minutes — UI/metadata cache
    'CACHE_KEY_PREFIX': 'superset_',
    'CACHE_REDIS_HOST': 'superset_cache',  # Redis container name on the compose network
    'CACHE_REDIS_PORT': 6379,
    'CACHE_REDIS_DB': 1,
}

DATA_CACHE_CONFIG = {
    'CACHE_TYPE': 'RedisCache',
    'CACHE_DEFAULT_TIMEOUT': 600,          # 10 minutes — chart query result cache
    'CACHE_KEY_PREFIX': 'superset_data_',
    'CACHE_REDIS_HOST': 'superset_cache',
    'CACHE_REDIS_PORT': 6379,
    'CACHE_REDIS_DB': 2,
}