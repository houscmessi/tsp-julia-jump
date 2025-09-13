
module Utils

using JuMP, MathOptInterface, HiGHS, Cbc
const MOI = MathOptInterface

"solver ∈ {\"highs\",\"cbc\"}; 默认为 highs"
function get_optimizer(solver::String)
    s = lowercase(solver)
    if s == "cbc"
        return () -> begin
            m = JuMP.Model(Cbc.Optimizer)
            set_optimizer_attribute(m, "threads", 1)
            set_attribute(m, MOI.NumberOfThreads(), 1)
            m
        end
    else
        return () -> JuMP.Model(HiGHS.Optimizer)
    end
end

using CSV, DataFrames, LinearAlgebra, Statistics, Printf

export read_coords, euclid_matrix, extract_cycles_directed, format_time

function read_coords(path::AbstractString)
    df = CSV.read(path, DataFrame)
    ids = Vector{Int}(df.id)
    coords = hcat(df.x, df.y)
    return ids, Matrix{Float64}(coords)
end

function euclid_matrix(coords::AbstractMatrix{<:Real})
    n = size(coords,1)
    C = zeros(Float64, n, n)
    for i in 1:n, j in 1:n
        if i==j
            C[i,j] = 1e6
        else
            dx = coords[i,1] - coords[j,1]
            dy = coords[i,2] - coords[j,2]
            C[i,j] = sqrt(dx*dx + dy*dy)
        end
    end
    return C
end

function extract_cycles_directed(X::AbstractMatrix; thresh::Float64=0.5)
    n = size(X,1)
    used = falses(n)
    cycles = Vector{Vector{Int}}()
    for s in 1:n
        if used[s]; continue; end
        cur = s
        cyc = Int[]
        while !used[cur]
            push!(cyc, cur)
            used[cur] = true
            row = X[cur, :]
            nxt = argmax(row)
            if row[nxt] < thresh
                break
            end
            cur = nxt
        end
        if length(cyc) > 1 && X[cyc[end], cyc[1]] >= thresh
            push!(cycles, cyc)
        end
    end
    cycles = [c for c in cycles if 2 <= length(c) <= n-1]
    return cycles
end

format_time(t::Real) = t < 1 ? @sprintf("%.0f ms", t*1000) : @sprintf("%.2f s", t)

end
