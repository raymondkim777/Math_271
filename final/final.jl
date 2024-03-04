#= 
Usage Guide

Input model parameters & data.
Run Julia code.

Model output prints to "model.lp"
Results print to "results.lp"
=#


# Declaring packages
using JuMP, GLPK

# Preparing an optimization model
m = Model(GLPK.Optimizer)

# Input parameters/data
t_max = 50
F = [n for n=1:2]  # array of flight numbers
K = [2n - 1 for n=1:4]  # array of airport numbers --> odd
J = vcat(K, [2n for n=1:6])  # array of sector numbers --> even
C = Pair{Float64}[]  # array of (f1, f2) cont. pairs

P = Vector{Vector{Int64}}()  # array of flight path arrays P[f][i] = Int64
N = Vector{Int64}()  # array of sector cnt in f N[f] = Int64
l = Vector{Dict{Int64, Int64}}()  # min time for flight in sector l[f][j] = Int64

D = Dict{Int64, Vector{Int64}}()  # dict of departure capacity arrays D[k][t] = Int64
A = Dict{Int64, Vector{Int64}}()  # dict of arrival capacity arrays A[k][t] = Int64
S = Dict{Int64, Vector{Int64}}()  # array of sector capacity arrays S[j][t] = Int64

d = Vector{Int64}()  # array of scheduled departure times d[f] = Int64
r = Vector{Int64}()  # array of scheduled arrival times r[f] = Int64
s = Vector{Int64}()  # array of turnaround times s[f] = Int64

c_g = Vector{Float64}()  # cost of ground holds c_g[f] = Float64
c_a = Vector{Float64}()  # cost of air holds c_a[f] = Float64

# for sake of simplicity, T_all will cover all values of t for now
T_f = Vector{Dict{Int64, Int64}}()  # first time for f to arrive at j T_f[f][j] = Int64
T_l = Vector{Dict{Int64, Int64}}()  # last time for f to arrive at j T_f[f][j] = Int64
T_all = Vector{Dict{Int64, Vector{Int64}}}()  # all times for f to arrive at j T_all[f][j] = Vector{Int64}
T = [i for i in 1:t_max]


# Manual Entry of Data
push!(P, [1, 2, 6, 8, 10, 7])  # first & last are airports (odd), not sectors (even)
push!(P, [3, 12, 10, 8, 4, 5])
for f in F
    push!(N, size(P[f])[1])
end
sect_times = Dict(1=>1, 3=>1, 5=>1, 7=>1, 2=>4, 4=>3, 6=>3, 8=>3, 10=>5, 12=>2)
push!(l, sect_times)
push!(l, sect_times)

for k in K
    D[k] = [1 for i in 1:t_max]
    A[k] = [1 for i in 1:t_max]
end
for j in J
    S[j] = [1 for i in 1:t_max]
end

push!(d, 10)
push!(d, 15)
push!(r, 35)
push!(r, 38)
push!(s, 0)
push!(s, 0)

for f in F
    push!(c_g, 5)
    push!(c_a, 17)
end

for f in F
    temp1 = Dict{Int64, Int64}()
    temp2 = Dict{Int64, Int64}()
    for j in J
        temp1[j] = 1
        temp2[j] = t_max
    end
    push!(T_f, temp1)
    push!(T_l, temp2)

    temp3 = Dict{Int64, Vector{Int64}}()
    for j in J
        temp3[j] = [i for i in T_f[f][j]: T_l[f][j]] 
    end
    push!(T_all, temp3)
end

padding = maximum([maximum(values(l[f])) for f in F])

# Declaring decision variables
@variable(m, w[f in F, j in P[f], t in vcat(
    [0], T_all[f][j], [i for i in T_l[f][j] + 1: T_l[f][j] + padding]
)], Bin)

# Objective
@objective(m, Min, sum([
    (
        (c_g[f] - c_a[f]) * sum([
            (t * (w[f, P[f][1], t] - w[f, P[f][1], t - 1]))
            for t in T_all[f][P[f][1]]
        ])
        + c_a[f] * sum([
            (t * (w[f, P[f][N[f]], t] - w[f, P[f][N[f]], t - 1]))
            for t in T_all[f][P[f][N[f]]]
        ])
    ) for f in F
]))

# Constraints

# additional constraints (planes have to takeoff & land)
@constraint(m, c0_0[f in F], w[f, P[f][1], d[f] - 1] == 0)
@constraint(m, c0_1[f in F], w[f, P[f][N[f]], r[f]] == 1)

# given model constraints
@constraint(m, c1[k in K, t in T], sum(vcat([0], [
    (w[f, k, t] - w[f, k, t - 1])
    for f in F if P[f][1] == k
])) <= D[k][t])

@constraint(m, c2[k in K, t in T], sum(vcat([0], [
    (w[f, k, t] - w[f, k, t - 1])
    for f in F if P[f][N[f]] == k
])) <= A[k][t])

@constraint(m, c3[j in J, t in T], sum(vcat([0], [
    (w[f, j, t] - w[f, P[f][i + 1], t])
    for f in F for i in 1:(N[f] - 1) if P[f][i] == j
])) <= S[j][t])

@constraint(m, c4[
    f in F, i in 1:(N[f] - 1), t in T_all[f][P[f][i]]
], w[f, P[f][i + 1], t + l[f][P[f][i]]] - w[f, P[f][i], t] <= 0)

@constraint(m, c5[
    (fp, f) in C, t in T_all[f][P[f][1]]
], w[f, P[f][1], t] - w[fp, P[f][1], t - s[fp]] <= 0)

@constraint(m, c6[
    f in F, j in P[f], t in T_all[f][j]
], w[f, j, t] - w[f, j, t - 1] >= 0)


# Printing Model
file1 = open("model.lp", "w")
print(file1, m)

# Solving LP
JuMP.optimize!(m)

# Printing Model to File
println(file1, "Objective value: ", objective_value(m))
println(file1, "Optimal solutions:")
println(file1, "w[] = \n", value.(w))
close(file1)

# Printing Flight Paths in stdout
file2 = open("results.lp", "w")
path = Vector{Dict{Int64, Int64}}()  # path[f][sec] = time

for f in F
    temp = Dict{Int64, Int64}()
    for sec in P[f]
        for t in T_all[f][sec]
            if value(w[f, sec, t]) == 1
                temp[sec] = t
                break
            end
        end
    end
    push!(path, temp)
end

println(file2, "Optimization Results:\n")
for f in F
    println(file2, "Flight ", f, " Path:")
    for sec in P[f]
        print(file2, "\t")
        if sec in K
            print(file2, "Airport ")
        else
            print(file2, "Sector ")
        end
        println(file2, sec, ": t = ", path[f][sec])
    end
    println(file2)
end
close(file2)
