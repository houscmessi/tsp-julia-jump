# Traveling Salesman Problem (TSP) with JuMP

[中文说明](./README.md)

This repository provides a Julia implementation of the **Traveling Salesman Problem (TSP)** using [JuMP](https://jump.dev/).  
It includes **two classical ILP formulations** and supports **multiple solvers** for reproducibility.  

---

## 📑 Table of Contents | 目录
- [✨ Features](#-features-)
- [🖼️ Visualization](#-visualization--)
- [🧪 Generate Random Instances](#-generate-random-instances--)
- [🗂️ Project Structure](#️-project-structure)
- [🚀 Quickstart](#-quickstart)
- [⚙️ Command-line Options](#-command-line-options--)
- [📊 Example](#-example--)
- [⚠️ Notes](#-notes--)
- [📖 References](#-references--)
- [📜 License](#-license--)

--- 
## ✨ Features
- **Two models**  
  - **Cutting-Plane (CG)**：Subring elimination constraints (SECs) are iteratively added until only a single Hamiltonian circuit remains.  
  - **Miller–Tucker–Zemlin (MTZ)**：Remove subrings by ordering variables `u[i]`.  
- **Multi-solver support**  
  - ✅ [HiGHS](https://www.highs.dev/) (default)  
  - ⚠️ [Cbc](https://github.com/coin-or/Cbc) (experimental，macOS Apple The chip may crash)  
- **Batch runner**：Run multiple instances and models at once and export the results to CSV  
- **Clean modular code**Easy to expand and reproduce  

## 🖼️ Visualization
After solving, optimal tours can be saved as PNG files under `plots/`.  

```bash
#Example: Run the CG model on inst8.csv and save the optimal tour graph
JULIA_NUM_THREADS=1 julia --project src/main.jl --model cg --instance data/inst8.csv
#Output example：plots/inst8.csv.png'''
```
---


## 🧪 Generate Random Instances
Use the script in `scripts/` to create reproducible instances (fixed seed).  
```bash
julia --project scripts/gen_instance.jl
# Default generation data/inst10.csv（n=10, seed=123）
```
---


## 🗂️ Project Structure
```bash
tsp-julia-jump/
├─ Project.toml          # Dependencies 
├─ src/
│  ├─ utils.jl           # Helper functions 
│  ├─ model_cg.jl        # CG formulation 
│  ├─ model_mtz.jl       # MTZ formulation 
│  ├─ main.jl            # Single instance entry 
│  ├─ run_all.jl         # Batch runner 
│  └─ run_one.jl         # Run one instance 
├─ data/
│  ├─ inst6.csv | inst8.csv | inst10.csv
├─ results/
│  └─ results.csv        # Generated after run
└─ scripts/
   ├─ setup.sh           # Install deps 
   └─ gen_instance.jl    # Random generator 
```
---

## 🚀 Quickstart 

-Install dependencies 
```bash
julia --project -e 'using Pkg; Pkg.instantiate()'
```
2. Run a single instance 
```bash
#Example: CG model on inst8.csv with default HiGHS
JULIA_NUM_THREADS=1 julia --project src/main.jl --model cg --instance data/inst8.csv
```
3. Run all instances 
```bash
JULIA_NUM_THREADS=1 julia --project src/run_all.jl
```

4. Results 
```bash
Results are written to results/results.csv
instance
obj
status
solve_time_sec
```

---

## ⚙️ Command-line Options
- `--model {cg|mtz}` : Select model (default: `cg`)  
- `--instance path/to/file.csv` : Path to input instance  
- `--solver {highs|cbc}` : Solver (default: `highs`)  
- `--timelimit N` : Time limit in seconds (optional)  
- `--seed N` : Random seed (optional)  

---

## 📊 Example

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


## ⚠️ Notes
	•	Cbc on macOS Apple Silicon may crash with pointer being freed was not allocated.
	•	Always run with JULIA_NUM_THREADS=1 for stability.
---




## 📖 References
	•	JuMP: https://jump.dev/
	•	HiGHS: https://www.highs.dev/
	•	COIN-OR Cbc: https://github.com/coin-or/Cbc
	•	Miller, Tucker, Zemlin (1960): Original MTZ paper

---


## 📜 License
```bash
Released under the MIT License
```