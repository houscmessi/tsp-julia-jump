# main.jl — single-thread Cbc stable version
# Usage:
#   JULIA_NUM_THREADS=1 julia --project main.jl --model cg --instance data/inst8.csv
#
# Notes:
#   - Forces both Julia and Cbc to 1 thread to avoid macOS malloc crashes.
#   - Expects ModelCG.jl / ModelMTZ.jl to expose `build!(model, instance_file)`.

import Pkg
Pkg.instantiate()

using JuMP, MathOptInterface
const MOI = MathOptInterface
using HiGHS      # 默认
using Cbc        # 可选

# If your project has these files, keep includes here (no-op if not used).
if isfile(joinpath(@__DIR__, "Utils.jl"));      include("Utils.jl");      end
if isfile(joinpath(@__DIR__, "ModelCG.jl"));    include("ModelCG.jl");    end
if isfile(joinpath(@__DIR__, "ModelMTZ.jl"));   include("ModelMTZ.jl");   end

# ----------------- CLI ----------------- #
function parse_args(args)
    opts = Dict{String,Any}(
        "model" => "cg",
        "instance" => "",
        "timelimit" => nothing,
        "seed" => nothing,
    )
    i = 1
    while i <= length(args)
        if args[i] == "--model" && i+1 <= length(args)
            opts["model"] = lowercase(String(args[i+1])); i += 2
        elseif args[i] == "--instance" && i+1 <= length(args)
            opts["instance"] = String(args[i+1]); i += 2
        elseif args[i] == "--timelimit" && i+1 <= length(args)
            opts["timelimit"] = tryparse(Float64, String(args[i+1])); i += 2
        elseif args[i] == "--seed" && i+1 <= length(args)
            opts["seed"] = tryparse(Int, String(args[i+1])); i += 2
        else
            i += 1
        end
    end
    if isempty(opts["instance"])
        error("Missing --instance path")
    end
    if !(opts["model"] in ("cg","mtz"))
        error("Unknown --model: $(opts["model"]) (use cg|mtz)")
    end
    return opts
end

# ----------------- Builder ----------------- #
include("utils.jl")

function build_model(model_name::String, instance_file::String;
                     timelimit::Union{Nothing,Float64}=nothing,
                     seed::Union{Nothing,Int}=nothing,
                     solver::String="highs")

    make = get_optimizer(solver)
    model = make()

    if timelimit !== nothing
        set_time_limit_sec(model, timelimit)
    end
    if seed !== nothing
        set_optimizer_attribute(model, "randomSeed", seed)
    end

    if model_name == "cg"
        ModelCG.build!(model, instance_file)
    elseif model_name == "mtz"
        ModelMTZ.build!(model, instance_file)
    else
        error("未知模型类型: $model_name")
    end

    return model
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
# ----------------- Main ----------------- #
function main(args)
    opts = parse_args(args)
    println(">>> Model = $(opts["model"]), Instance = $(opts["instance"])")
    model = build_model(opts["model"], opts["instance"];
                        timelimit = opts["timelimit"], seed = opts["seed"])
    optimize!(model)

    println("Termination status: ", termination_status(model))
    if has_values(model)
        println("Objective value: ", objective_value(model))
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end