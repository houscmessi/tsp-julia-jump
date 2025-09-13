# scripts/gen_instance.jl
# 生成随机 TSP 实例（n 个城市），保存到 data/inst<n>.csv
# 用固定随机种子保证可复现

using Random, CSV, DataFrames
using Dates

"""
gen_instance(n, outfile; seed=42, range=100)
- n: 城市数
- outfile: 输出 CSV 路径
- seed: 随机种子（默认 42）
- range: 坐标范围 [1, range]
"""
function gen_instance(n::Int, outfile::AbstractString; seed::Int=42, range::Int=100)
    @assert n ≥ 3 "城市数量 n 至少为 3"
    Random.seed!(seed)
    xs = rand(1:range, n)
    ys = rand(1:range, n)
    df = DataFrame(x=xs, y=ys)
    mkpath(dirname(outfile))
    CSV.write(outfile, df)
    println("[$(Dates.format(now(), dateformat"""yyyy-mm-dd HH:MM:SS"""))] Generated -> $(outfile) (n=$(n), seed=$(seed))")
end

# 示例用法（也可用 `julia --project scripts/gen_instance.jl 10 data/inst10.csv 123` 这种 CLI 包一层）
gen_instance(10, "data/inst10.csv"; seed=123)