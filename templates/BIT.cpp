struct FenwickTree {
    int n;
    vector<long long> bit;

    FenwickTree(int n) {
        this->n = n;
        bit.assign(n + 1, 0);
    }

    FenwickTree(const vector<long long>& a) {
        n = (int)a.size() - 1;
        bit = a;

        for (int i = 1; i <= n; i++) {
            int j = i + (i & -i);
            if (j <= n)
                bit[j] += bit[i];
        }
    }

    // adiciona delta na posição idx
    void add(int idx, long long delta) {
        while (idx <= n) {
            bit[idx] += delta;
            idx += idx & -idx;
        }
    }

    // soma do prefixo [1 .. idx]
    long long sum(int idx) const {
        long long ret = 0;
        while (idx > 0) {
            ret += bit[idx];
            idx -= idx & -idx;
        }
        return ret;
    }

    // soma do intervalo [l .. r]
    long long query(int l, int r) const {
        return sum(r) - sum(l - 1);
    }
};
