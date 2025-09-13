
module ModelMTZ

using JuMP, Cbc, LinearAlgebra, Printf
include("utils.jl")
using .Utils: format_time

export solve_mtz

function solve_mtz(C::AbstractMatrix{<:Real}; time_limit::Real=60.0, verbose::Bool=false)
    n = size(C,1)
    model = Model(Cbc.Optimizer)
    set_silent(model)
    set_time_limit_sec(model, time_limit)

    @variable(model, x[1:n,1:n], Bin)
    @variable(model, u[1:n] >= 0)

    @constraint(model, [i=1:n], x[i,i] == 0)
    @constraint(model, [i=1:n], sum(x[i,j] for j in 1:n) == 1)
    @constraint(model, [j=1:n], sum(x[i,j] for i in 1:n) == 1)

    @constraint(model, u[1] == 0)
    @constraint(model, [i=2:n], 1 <= u[i] <= n-1)
    @constraint(model, [i=1:n, j=2:n; i != j], u[j] >= u[i] + 1 - n*(1 - x[i,j]))

    @objective(model, Min, sum(C[i,j] * x[i,j] for i in 1:n, j in 1:n))

    t0 = time()
    optimize!(model)
    t = time() - t0

    st = termination_status(model)
    obj = objective_value(model)
    xsol = value.(x)
    return (obj, xsol, t, st)
end

end
