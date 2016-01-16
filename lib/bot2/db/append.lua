local index = redis.call('ZCARD', KEYS[1]); redis.call('ZADD', KEYS[1], ARGV[1], index); return index
