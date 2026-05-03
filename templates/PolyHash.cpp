struct PolyHash {
    using ll = long long;
    static constexpr int MOD = 1'000'000'007;
    static constexpr int BASE = 91138233;

    static inline std::vector<ll> powers = {1};

    std::deque<int> dq;
    ll hash = 0;

    static void init(int maxN) {
        ensure(maxN);
    }
    
    static void ensure_powers(int n) {
        if ((int)powers.size() > n) return;
        int cur = powers.size();
        powers.resize(n + 1);
        for (int i = cur; i <= n; ++i)
            powers[i] = (powers[i-1] * BASE) % MOD;
    }

    int size() const {
        return dq.size();
    }

    // --- PUSH BACK ---
    void push_back(char c) {
        int x = c - 'a' + 1;
        ensure_powers(size());

        hash = (hash * BASE + x) % MOD;
        dq.push_back(x);
    }

    // --- PUSH FRONT ---
    void push_front(char c) {
        int x = c - 'a' + 1;
        ensure_powers(size());

        hash = (hash + x * powers[size()] % MOD) % MOD;
        dq.push_front(x);
    }

    // --- POP BACK ---
    void pop_back() {
        if (dq.empty()) return;

        int x = dq.back();
        dq.pop_back();

        hash = (hash - x + MOD) % MOD;
        hash = (hash * mod_inv(BASE)) % MOD;
    }

    // --- POP FRONT ---
    void pop_front() {
        if (dq.empty()) return;

        int x = dq.front();
        dq.pop_front();

        ensure_powers(size());

        ll rem = x * powers[size()] % MOD;
        hash = (hash - rem + MOD) % MOD;
    }

    // --- HASH TOTAL ---
    ll get() const {
        return hash;
    }

    // --- SUBSTRING HASH (O(n)) ---
    ll get(int l, int r) {
        ll h = 0;
        for (int i = l; i < r; ++i) {
            h = (h * BASE + dq[i]) % MOD;
        }
        return h;
    }

private:
    // --- modular inverse ---
    static ll modexp(ll a, ll e) {
        ll r = 1;
        while (e) {
            if (e & 1) r = r * a % MOD;
            a = a * a % MOD;
            e >>= 1;
        }
        return r;
    }

    static ll mod_inv(ll x) {
        return modexp(x, MOD - 2);
    }
};
