# Traveling Salesman Problem (TSP) with JuMP | 使用 JuMP 实现旅行商问题

[English Version](./README.en.md)

本仓库提供了基于 [JuMP](https://jump.dev/) 的 **旅行商问题 (TSP)** Julia 实现，  
包含 **两种经典整数规划 (ILP) 模型**，并支持 **多种求解器**，方便复现与扩展。

---

## 📑 Table of Contents | 目录
- [✨ Features | 特性](#-features--特性)
- [🖼️ Visualization | 可视化](#-visualization--可视化)
- [🧪 Generate Random Instances | 生成随机实例](#-generate-random-instances--生成随机实例)
- [🗂️ Project Structure | 项目结构](#️-project-structure--项目结构)
- [🚀 Quickstart | 快速开始](#-quickstart--快速开始)
- [⚙️ Command-line Options | 命令行选项](#-command-line-options--命令行选项)
- [📊 Example | 示例](#-example--示例)
- [⚠️ Notes | 注意事项](#-notes--注意事项)
- [📖 References | 参考](#-references--参考)
- [📜 License | 许可](#-license--许可)

---

## ✨ Features | 特性
- **Two models | 两种模型**  
  - **Cutting-Plane (CG) | 割平面**：迭代添加子环消除约束 (SEC)，直到只剩单一哈密顿回路。  
  - **Miller–Tucker–Zemlin (MTZ)**：通过次序变量 `u[i]` 去除子环。  
- **Multi-solver support | 多求解器支持**  
  - ✅ [HiGHS](https://www.highs.dev/) (default | 默认，推荐，稳定)  
  - ⚠️ [Cbc](https://github.com/coin-or/Cbc) (experimental | 实验性，macOS Apple 芯片可能崩溃)  
- **Batch runner | 批量运行**：一次运行多个实例、多个模型，结果导出 CSV  
- **Clean modular code | 代码结构清晰**，便于扩展和复现  

## 🖼️ Visualization | 可视化
求解完成后，可将**最优巡回路径**绘制并保存到 `plots/` 目录。

```bash
#示例：在 inst8.csv 上运行 CG 模型，保存最优巡回图
JULIA_NUM_THREADS=1 julia --project src/main.jl --model cg --instance data/inst8.csv
#输出示例：plots/inst8.csv.png'''
```
---


## 🧪 Generate Random Instances | 生成随机实例 
使用 `scripts/` 下的脚本生成**可复现**的随机实例（固定随机种子）。
```bash
julia --project scripts/gen_instance.jl
# 默认生成 data/inst10.csv（n=10, seed=123）
```
---


## 🗂️ Project Structure | 项目结构
```bash
tsp-julia-jump/
├─ Project.toml          # Dependencies | 依赖声明
├─ src/
│  ├─ utils.jl           # Helper functions | 工具函数
│  ├─ model_cg.jl        # CG formulation | 割平面模型
│  ├─ model_mtz.jl       # MTZ formulation | MTZ 模型
│  ├─ main.jl            # Single instance entry | 单实例入口
│  ├─ run_all.jl         # Batch runner | 批量运行
│  └─ run_one.jl         # Run one instance | 运行单个实例
├─ data/
│  ├─ inst6.csv | inst8.csv | inst10.csv
├─ results/
│  └─ results.csv        # Generated after run | 运行后生成
└─ scripts/
   ├─ setup.sh           # Install deps | 一键安装依赖
   └─ gen_instance.jl    # Random generator | 随机实例生成
```
---

## 🚀 Quickstart | 快速开始

-安装依赖
```bash
julia --project -e 'using Pkg; Pkg.instantiate()'
```
-运行单个实例
```bash
#示例：在 inst8.csv 上跑 CG 模型（默认使用 HiGHS）
JULIA_NUM_THREADS=1 julia --project src/main.jl --model cg --instance data/inst8.csv
```
-批量运行所有实例
```bash
JULIA_NUM_THREADS=1 julia --project src/run_all.jl
```

-结果
```bash
运行结果将导出到 results/results.csv：model
instance
obj
status
solve_time_sec
```

---

## ⚙️ Command-line Options | 命令行选项
- `--model {cg|mtz}` : Select model (default: `cg`)  
  选择模型（默认 `cg`）  
- `--instance path/to/file.csv` : Path to input instance  
  指定输入实例文件路径  
- `--solver {highs|cbc}` : Solver (default: `highs`)  
  指定求解器（默认 `highs`）  
- `--timelimit N` : Time limit in seconds (optional)  
  时间限制（秒，可选）  
- `--seed N` : Random seed (optional)  
  随机种子（可选）  

---

## 📊 Example | 示例

Run
```bash
JULIA_NUM_THREADS=1 julia --project src/main.jl --model mtz --instance data/inst6.csv --solver highs
```
Output
```bash
>>> Model = mtz, Instance = data/inst6.csv, Solver = highs
Termination status: OPTIMAL
Objective value: 378.0
```
---


## ⚠️ Notes | 注意事项
	•	建议默认使用 HiGHS，Cbc 在 macOS Apple 芯片可能崩溃。
	•	建议运行时保持 JULIA_NUM_THREADS=1，避免多线程不稳定。
---




## 📖 References | 参考
	•	JuMP: https://jump.dev/
	•	HiGHS: https://www.highs.dev/
	•	COIN-OR Cbc: https://github.com/coin-or/Cbc
	•	Miller, Tucker, Zemlin (1960): Original MTZ paper

---


## 📜 License | 许可
```bash
本项目基于 MIT License 开源。
```