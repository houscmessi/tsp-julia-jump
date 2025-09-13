
using CSV, DataFrames, Random, Printf
include("utils.jl"); using .Utils
include("model_mtz.jl"); using .ModelMTZ
include("model_cg.jl"); using .ModelCG

function solve_instance(path::AbstractString; model::Symbol=:cg, seed::Int=1, timelimit::Real=60.0)
    Random.seed!(seed)
    ids, coords = Utils.read_coords(path)
    C = Utils.euclid_matrix(coords)
    n = size(C,1)

    if model == :mtz
        obj, X, t, st = ModelMTZ.solve_mtz(C; time_limit=timelimit)
        return (; instance=basename(path), n, model=String(model), obj, time=t, status=String(st), cuts=missing, iters=missing)
    elseif model == :cg
        obj, X, t, st, cuts, iters = ModelCG.solve_cg(C; time_limit=timelimit)
        return (; instance=basename(path), n, model=String(model), obj, time=t, status=String(st), cuts, iters)
    else
        error("Unknown model $(model)")
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    path = length(ARGS) >= 1 ? ARGS[1] : "data/inst8.csv"
    model = length(ARGS) >= 2 ? Symbol(ARGS[2]) : :cg
    res = solve_instance(path; model=model)
    @info res
end
