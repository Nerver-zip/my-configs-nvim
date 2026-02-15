vector<ll> primes;
vector<bool> isPrime;
void sieveOfEratosthenes(int n) {

    isPrime.assign(n + 1, true);
    isPrime[0] = false, isPrime[1] = false;

    for (int p = 2; p * p <= n; p++) {
        if (isPrime[p] == true) {
            for (int i = p * p; i <= n; i += p)
                isPrime[i] = false;
        }
    }
    
    ll curr = 0;
    for (int p = 2; p <= n; p++)
        if (isPrime[p])
            primes.push_back(p);
}
