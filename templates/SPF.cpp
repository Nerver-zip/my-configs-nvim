vector<int> spf;

void spf_init(int n){
    spf.resize(n+1);
    iota(spf.begin(), spf.end(), 0);

    for (int i = 2; i * i <= n; i++) {
        if (spf[i] == i) {
            for (int j = i * i; j <= n; j += i) {
                if (spf[j] == j)
                    spf[j] = i;
            }
        }
    }
}
