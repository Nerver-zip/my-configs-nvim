struct FenwickTree {
    int n;
    vector<long long> bit;

    FenwickTree(const vector<int>& arr){
        n = arr.size();
        bit = {0};
        bit.insert(bit.end(), arr.begin(), arr.end());

        for(int i = 1; i <= n; ++i){
            // pega o pai de i
            int j = i + (i & -i);
            if(j <= n){
                bit[j] += bit[i];
            }
        }
    }

    void add(int idx, int delta){
        ++idx;
        while(idx <= n){
            bit[idx] += delta;
            idx += idx & -idx;
        }
    }

    long long prefixSum(int idx) const {
        ++idx;
        long long res = 0;
        while(idx > 0){
            res += bit[idx];
            idx -= idx & -idx;
        }
        
        return res;
    }

    long long query(int l, int r) const {
        return prefixSum(r) - prefixSum(l-1);
    }
};
