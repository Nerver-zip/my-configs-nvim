struct LCA {
    int n, LOG;
    vector<int> depth;
    vector<vector<int>> up;
    vector<vector<int>> adj;

    LCA(int n) : n(n) {
        LOG = 1;
        while ((1 << LOG) <= n) LOG++;

        depth.assign(n + 1, 0);
        up.assign(n + 1, vector<int>(LOG));
        adj.assign(n + 1, {});
    }

    void addEdge(int u, int v) {
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    void dfs(int v, int p) {
        up[v][0] = p;

        for (int j = 1; j < LOG; j++) {
            up[v][j] = up[up[v][j - 1]][j - 1];
        }

        for (int to : adj[v]) {
            if (to == p) continue;

            depth[to] = depth[v] + 1;
            dfs(to, v);
        }
    }

    void build(int root = 1) {
        dfs(root, root);
    }

    int lift(int v, int k) {
        for (int j = 0; j < LOG; j++) {
            if (k & (1 << j)) {
                v = up[v][j];
            }
        }
        return v;
    }

    int lca(int u, int v) {
        if (depth[u] < depth[v])
            swap(u, v);

        u = lift(u, depth[u] - depth[v]);

        if (u == v)
            return u;

        for (int j = LOG - 1; j >= 0; j--) {
            if (up[u][j] != up[v][j]) {
                u = up[u][j];
                v = up[v][j];
            }
        }

        return up[u][0];
    }

    int dist(int u, int v) {
        int w = lca(u, v);
        return depth[u] + depth[v] - 2 * depth[w];
    }
};
