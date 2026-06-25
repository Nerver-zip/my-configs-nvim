#include <bits/stdc++.h>
using namespace std;

// =================== Asserts ===================

#ifdef LOCAL

#define ASSERT(cond) \
    do { \
        if(!(cond)) { \
            cerr << "\n[ASSERTION FAILED]\n"; \
            cerr << "Condition: " << #cond << '\n'; \
            cerr << "File: " << __FILE__ \
                 << " | Line: " << __LINE__ << '\n'; \
            abort(); \
        } \
    } while(0)

#define ASSERT_EQ(a, b) \
    do { \
        auto _a = (a); \
        auto _b = (b); \
        if(!(_a == _b)) { \
            cerr << "\n[ASSERT_EQ FAILED]\n"; \
            cerr << #a << " = " << _a << '\n'; \
            cerr << #b << " = " << _b << '\n'; \
            cerr << "File: " << __FILE__ \
                 << " | Line: " << __LINE__ << '\n'; \
            abort(); \
        } \
    } while(0)

#else

#define ASSERT(cond) ((void)0)
#define ASSERT_EQ(a, b) ((void)0)

#endif

// ==================== Types ====================

using ll  = long long;
using ull = unsigned long long;
using ld  = long double;

using pii = pair<int,int>;
using pll = pair<ll,ll>;

using vi  = vector<int>;
using vll = vector<ll>;
using vii = vector<pii>;
using vllp = vector<pll>;

// ==================== Constants ====================

constexpr int INF = 0x3f3f3f3f;
constexpr ll LINF = 0x3f3f3f3f3f3f3f3fLL;
constexpr int MOD = 1000000007;
constexpr double EPS = 1e-9;

// ==================== Fast IO ====================

static const auto fastio = []() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    return 0;
}();

// ==================== Macros ====================

#define pb push_back
#define eb emplace_back
#define ff first
#define ss second

#define all(x) begin(x), end(x)
#define rall(x) rbegin(x), rend(x)

#define sz(x) ((int)(x).size())

#define FOR(i,a,b) for(int i=(a); i<(b); ++i)
#define RFOR(i,a,b) for(int i=(a); i>=(b); --i)

#define rep(i,n) for(int i=0; i<(n); ++i)
#define per(i,n) for(int i=(n)-1; i>=0; --i)

#define each(x,v) for(auto& x : v)

// ==================== Debug ====================

#ifdef LOCAL
    #define dbg(x) cerr << #x << " = " << (x) << '\n'
#else
    #define dbg(x)
#endif

// ==================== Utility ====================

template<typename T>
inline bool chmax(T& a, const T& b) {
    return (a < b) ? (a = b, true) : false;
}

template<typename T>
inline bool chmin(T& a, const T& b) {
    return (a > b) ? (a = b, true) : false;
}

#define yes cout << "YES\n"
#define no  cout << "NO\n"

#define Yes cout << "Yes\n"
#define No  cout << "No\n"

// ===================================================

template<typename T>
istream& operator>>(istream& is, vector<T>& v) {
    for(auto& x : v) is >> x;
    return is;
}

template<typename A, typename B>
istream& operator>>(istream& is, pair<A,B>& p) {
    return is >> p.first >> p.second;
}

template<typename T>
ostream& operator<<(ostream& os, const vector<T>& v) {
    for(int i = 0; i < (int)v.size(); ++i) {
        if(i) os << ' ';
        os << v[i];
    }
    return os;
}

template<typename K, typename V>
ostream& operator<<(ostream& os, const unordered_map<K, V>& m) {
    os << "{";
    bool first = true;

    for(const auto& [k, v] : m) {
        if(!first) os << ", ";
        first = false;
        os << k << ": " << v;
    }

    os << "}";
    return os;
}

int main() {
    #ifdef LOCAL
        freopen("../input.txt", "r", stdin);
        freopen("../output.txt", "w", stdout);
    #endif
   

    
    return 0;
}
