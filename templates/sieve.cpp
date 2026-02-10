vector<ll> prefix;
vector<bool> prime;
void sieveOfEratosthenes(int n) {

    prime.assign(n + 1, true);
    prime[0] = false, prime[1] = false;

    for (int p = 2; p * p <= n; p++) {
        if (prime[p] == true) {
            for (int i = p * p; i <= n; i += p)
                prime[i] = false;
        }
    }
    
    ll curr = 0;
    for (int p = 2; p <= n; p++)
        if (prime[p])
            prefix.push_back(p);
}
