
# TSP with JuMP (Julia) — MTZ & Cut-Generation (SEC)

最小可跑版 **旅行商问题 (TSP)**：提供两种 ILP 模型：
- **CG (Cut-Generation)**：度约束 + 迭代添加**子环消除约束** (SEC)，直到得到单一哈密顿回路；
- **MTZ**：经典 Miller–Tucker–Zemlin 公式。

求解器：**Cbc.jl**（开源、免许可）。数据：提供 6/8/10 城市的坐标实例。

---

## 快速开始
```bash
# 0) 安装 Julia 1.10+
# 1) 安装依赖
julia --project -e 'using Pkg; Pkg.instantiate()'

# 2) 跑一个实例（默认 CG 模型）
julia --project src/main.jl --model cg --instance data/inst8.csv

# 3) 跑所有实例 & 模型（输出到 results/results.csv）
julia --project src/run_all.jl
```

### 模型说明
- `cg`：先建立**入/出度=1**的松弛模型，求出整数解后检出是否存在多个子环；若有，就对每个子集 S 加上 SEC：
  `sum_{i∈S, j∈S} x[i,j] <= |S|-1`，并**重新求解**，迭代直到只有一个环；
- `mtz`：引入 `u[i]` 次序变量，通过 `u[j] ≥ u[i] + 1 - n*(1-x[i,j])` 去除子环。

> 备注：CG 的实现**不使用回调**，而是“外循环”分离 SEC，兼容 Cbc。

---

## 目录结构
```
tsp-julia-jump/
├─ Project.toml          # 依赖
├─ src/
│  ├─ utils.jl           # 读数据、距离矩阵、子环检测
│  ├─ model_cg.jl        # CG 模型（迭代加 SEC）
│  ├─ model_mtz.jl       # MTZ 模型
│  ├─ run_one.jl         # 运行一个实例
│  ├─ run_all.jl         # 批量运行并导出 results.csv
│  └─ main.jl            # CLI 入口
├─ data/
│  ├─ inst6.csv | inst8.csv | inst10.csv
├─ results/
│  └─ results.csv        # 运行后生成
└─ scripts/
   ├─ setup.sh           # 一键安装依赖
   └─ run_all.sh         # 一键批跑
```

---

## 样例输出
```text
# 实际结果以你机器为准，最终会写入 results/results.csv
```

---

## 从零到 GitHub（一步一步）
```bash
# 1) 解压并进入目录
cd tsp-julia-jump

# 2) 初始化 Git
git init
git add .
git commit -m "feat: TSP (JuMP) minimal MTZ & CG models with multi-instance runner"

# 3) 在 GitHub 新建空仓库 tsp-julia-jump（public）

# 4) 绑定并推送
git branch -M main
git remote add origin https://github.com/<你的用户名>/tsp-julia-jump.git
git push -u origin main
```

---

## 引用
- JuMP: https://jump.dev/
- Cbc: https://github.com/coin-or/Cbc
- MTZ: Miller, Tucker, and Zemlin (1960)
