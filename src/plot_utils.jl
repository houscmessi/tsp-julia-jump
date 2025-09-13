# src/plot_utils.jl
# 可视化最优巡回：从模型解中抽取 x[i,j] > 0.5 的边，根据实例 CSV 坐标画图并保存为 PNG

module PlotUtils

using CSV, DataFrames
using JuMP
using Plots

export save_tour_plot

"""
save_tour_plot(model, instance_file; outdir="plots", varname=:x)

- 从 `model` 中读取变量容器 `varname`（默认 :x）的值；
- 从 `instance_file` 读取城市坐标（DataFrame 的前两列视为 x/y）；
- 绘制点与边，并将图像保存到 `outdir/basename(instance_file).png`。
"""
function save_tour_plot(model::Model, instance_file::AbstractString;
                        outdir::AbstractString="plots", varname::Symbol=:x)

    # 1) 读取实例坐标
    df = CSV.read(instance_file, DataFrame)
    @assert size(df,2) ≥ 2 "坐标文件至少需要两列 (x,y)"
    xs = collect(df[:, 1])
    ys = collect(df[:, 2])
    n  = length(xs)

    # 2) 取变量容器
    # 约定变量名为 x[i,j]（二进制 0/1），如果你的名字不同，调用时用 varname=...
    x_container = get(model, varname, nothing)
    @assert x_container !== nothing "模型中未找到变量容器 $(varname)。请确认 @variable(model, $(String(varname))[...]) 的名字。"

    # 3) 取解：x_val[i,j] = value(x[i,j])
    x_val = Array{Float64}(undef, n, n)
    for i in 1:n, j in 1:n
        x_val[i,j] = value(x_container[i,j])
    end

    # 4) 生成图
    mkpath(outdir)
    plt = plot(xs, ys; seriestype=:scatter, markersize=6, label="Cities")
    annotate!(eachindex(xs), ys, string.(1:n))  # 标注城市编号（1..n）

    for i in 1:n, j in 1:n
        if x_val[i,j] > 0.5
            plot!([xs[i], xs[j]], [ys[i], ys[j]]; lw=2, label="")
        end
    end

    outfile = joinpath(outdir, basename(instance_file) * ".png")
    savefig(plt, outfile)
    println("Saved tour plot -> $(outfile)")
    return outfile
end

end # module