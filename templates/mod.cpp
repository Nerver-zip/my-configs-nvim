ll modpow(ll base, ll exp, ll mod = MOD) {
    assert(mod > 0);

    base %= mod;
    if(base < 0) base += mod;

    ll res = 1 % mod;

    while(exp > 0) {
        if(exp & 1)
            res = (ll)((__int128)res * base % mod);

        base = (ll)((__int128)base * base % mod);
        exp >>= 1;
    }

    return res;
}

ll modinv(ll x, ll mod = MOD) {
    assert(mod > 1);
    assert(std::gcd(x, mod) == 1);

    x %= mod;
    if(x < 0) x += mod;

    return modpow(x, mod - 2, mod);
}
