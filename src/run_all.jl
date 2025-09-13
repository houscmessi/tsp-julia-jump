# run_all.jl — batch runner (single-thread Cbc) — FIX
import Pkg
Pkg.instantiate()

using CSV, DataFrames
using Dates
using JuMP, MathOptInterface
const MOI = MathOptInterface
using HiGHS      # 默认
using Cbc        # 可选

if isfile(joinpath(@__DIR__, "Utils.jl"));      include("Utils.jl");      end
if isfile(joinpath(@__DIR__, "ModelCG.jl"));    include("ModelCG.jl");    end
if isfile(joinpath(@__DIR__, "ModelMTZ.jl"));   include("ModelMTZ.jl");   end

function build_and_solve(model_name::String, instance_file::String)
    include("utils.jl")  # Ensure Utils is loaded for get_optimizer

    solver = get(opts, "solver", "highs")
    make = get_optimizer(solver)
    model = make()
    set_optimizer_attribute(model, "threads", 1)
    set_attribute(model, MOI.NumberOfThreads(), 1)

    if model_name == "cg"
        @assert @isdefined(ModelCG) "ModelCG.jl not found; please provide ModelCG.build!(...)"
        ModelCG.build!(model, instance_file)
    elseif model_name == "mtz"
        @assert @isdefined(ModelMTZ) "ModelMTZ.jl not found; please provide ModelMTZ.build!(...)"
        ModelMTZ.build!(model, instance_file)
    else
        error("Unknown model: $model_name")
    end

    t0 = time()
    optimize!(model)
    t1 = time()

    status = string(termination_status(model))
    obj = try
        has_values(model) ? objective_value(model) : missing
    catch
        missing
    end
    return (model=model_name, instance=instance_file,
            obj=obj, status=status, solve_time_sec=round(t1 - t0, digits=3))
end

function list_instances(dir::String="data")
    if !isdir(dir)
        return String[]
    end
    files = sort(readdir(dir; join=false))
    files = filter(f -> endswith(lowercase(f), ".csv"), files)
    return map(f -> joinpath(dir, f), files)
end

function run_all()
    models = ["cg", "mtz"]
    instances = list_instances("data")
    if isempty(instances)
        @warn "No CSV instances found in ./data"
    end

    rows = DataFrame(model=String[], instance=String[],
                     obj=Union{Missing,Float64}[],
                     status=String[], solve_time_sec=Float64[])

    for ins in instances
        for m in models
            @info "Solving" model=m instance=ins
            res = build_and_solve(m, ins)
            push!(rows, res)
        end
    end


    mkpath("results")
    out = "results/results.csv"
    CSV.write(out, rows)
    println(rows)

    # —— 关键修正：先格式化时间，再插入字符串，避免引号/括号冲突 ——
    ts = Dates.format(now(), Dates.DateFormat("yyyy-mm-dd HH:MM:SS"))
    println("\nSaved results to $out at $ts")
end

"solver ∈ {\"highs\",\"cbc\"}; 默认为 highs"
function get_optimizer(solver::String)
    s = lowercase(solver)
    if s == "cbc"
        opt = Cbc.Optimizer
        # 单线程，避免 macOS 崩溃
        return () -> begin
            m = JuMP.Model(opt)
            set_optimizer_attribute(m, "threads", 1)
            set_attribute(m, MOI.NumberOfThreads(), 1)
            m
        end
    else
        return () -> JuMP.Model(HiGHS.Optimizer)
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    run_all()
end