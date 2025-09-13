
module ModelCG

using JuMP, Cbc, LinearAlgebra, Printf
include("utils.jl")
using .Utils: extract_cycles_directed, format_time

export solve_cg

function solve_cg(C::AbstractMatrix{<:Real}; time_limit::Real=60.0, max_iters::Int=50, verbose::Bool=false)
    n = size(C,1)
    model = Model(Cbc.Optimizer)
    set_silent(model)
    set_time_limit_sec(model, time_limit)

    @variable(model, x[1:n,1:n], Bin)
    @constraint(model, [i=1:n], x[i,i] == 0)
    @constraint(model, [i=1:n], sum(x[i,j] for j in 1:n) == 1)
    @constraint(model, [j=1:n], sum(x[i,j] for i in 1:n) == 1)
    @objective(model, Min, sum(C[i,j] * x[i,j] for i in 1:n, j in 1:n))

    cuts_added = 0
    iter = 0
    t0 = time()
    while iter < max_iters
        iter += 1
        optimize!(model)
        X = value.(x)
        cycles = extract_cycles_directed(X; thresh=0.5)
        if length(cycles) <= 1
            break
        end
        for S in cycles
            @constraint(model, sum(x[i,j] for i in S, j in S) <= length(S)-1)
            cuts_added += 1
        end
        if verbose
            @info "CG iter=$(iter) added $(length(cycles)) SECs, total cuts=$(cuts_added)"
        end
    end
    t = time() - t0
    st = termination_status(model)
    obj = objective_value(model)
    X = value.(x)
    return (obj, X, t, st, cuts_added, iter)
end

end
