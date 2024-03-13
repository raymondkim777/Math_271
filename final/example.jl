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
t_max = 96                                      # DATA: 24 hours, 15 minute intervals
delay_padding = 8                               # DATA: 2 hour delays allowed

F = [n for n=1:3]                               # array of flight numbers
K = [2n - 1 for n=1:4]                          # array of airport numbers --> odd
J = vcat(K, [2n for n=1:11])                    # array of sector numbers --> even
C = Pair{Int64, Int64}[]                        # array of (f1, f2) cont. pairs

P = Vector{Vector{Int64}}()                     # array of flight path arrays P[f][i] = Int64
N = Vector{Int64}()                             # array of sector cnt in f N[f] = Int64
l = Vector{Dict{Int64, Int64}}()                # min time for flight in sector l[f][j] = Int64

D = Dict{Int64, Vector{Int64}}()                # dict of departure capacity arrays D[k][t] = Int64
A = Dict{Int64, Vector{Int64}}()                # dict of arrival capacity arrays A[k][t] = Int64
S = Dict{Int64, Vector{Int64}}()                # array of sector capacity arrays S[j][t] = Int64

d = Vector{Int64}()                             # array of scheduled departure times d[f] = Int64
r = Vector{Int64}()                             # array of scheduled arrival times r[f] = Int64
s = Vector{Int64}()                             # array of turnaround times s[f] = Int64

c_g = Vector{Float64}()                         # cost of ground holds c_g[f] = Float64
c_a = Vector{Float64}()                         # cost of air holds c_a[f] = Float64

# T_all covers all t values, restrictions included in constraints
T_f = Vector{Dict{Int64, Int64}}()              # first time for f to arrive at j T_f[f][j] = Int64
T_l = Vector{Dict{Int64, Int64}}()              # last time for f to arrive at j T_f[f][j] = Int64
T_all = Vector{Dict{Int64, Vector{Int64}}}()    # all times for f to arrive at j T_all[f][j] = Vector{Int64}
T = [i for i = 1:t_max]


# Manual Entry of Data
push!(C, 2 => 3)
push!(P, [1, 4, 8, 10, 14, 20, 22, 5])  # first & last are airports (odd), not sectors (even)
push!(P, [1, 4, 2, 6, 12, 3])
push!(P, [3, 12, 14, 16, 18, 7])
for f in F
    push!(N, size(P[f])[1])
end
sect_times = Dict(
    # Airports
    1=>1, 
    3=>1, 
    5=>1, 
    7=>1, 
    # Sectors
    2=>1, 
    4=>1, 
    6=>1, 
    8=>1, 
    10=>1, 
    12=>1, 
    14=>2, 
    16=>2, 
    18=>1, 
    20=>1, 
    22=>1 
)
for f in F
    push!(l, sect_times)
end

# Capacities
for k in K
    D[k] = [1 for i = 1:t_max]
    A[k] = [1 for i = 1:t_max]
end
for j in J
    S[j] = [1 for i = 1:t_max]
end

# Schedule
push!(d, 40)
push!(d, 32)
push!(d, 42)

push!(r, 49)
push!(r, 38)
push!(r, 50)

push!(s, 0)
push!(s, 0)
push!(s, 4)

# Costs
push!(c_g, 100)
push!(c_a, 200)

push!(c_g, 250)
push!(c_a, 300)

push!(c_g, 250)
push!(c_a, 300)

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
        temp3[j] = [i for i = T_f[f][j]: T_l[f][j]] 
    end
    push!(T_all, temp3)
end

padding = delay_padding + maximum([maximum(values(l[f])) for f in F])

# Declaring decision variables
@variable(m, w[f in F, j in P[f], t in vcat(
    [0], T_all[f][j], [i for i = T_l[f][j] + 1: T_l[f][j] + padding]
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
@constraint(m, c0_1[f in F], w[f, P[f][N[f]], r[f] + delay_padding] == 1)

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
    for f in F for i = 1:(N[f] - 1) if P[f][i] == j
])) <= S[j][t])

@constraint(m, c4[
    f in F, i = 1:(N[f] - 1), t in T_all[f][P[f][i]]
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

# Printing Flight Paths to File
file2 = open("results.lp", "w")
path1 = Vector{Dict{Int64, Int64}}()    # path1[f][sec] = time period
path2 = Vector{Dict{Int64, String}}()   # path2[f][sec] = actual time

for f in F
    temp1 = Dict{Int64, Int64}()
    temp2 = Dict{Int64, String}()
    for sec in P[f]
        for t in T_all[f][sec]
            if value(w[f, sec, t]) == 1
                temp1[sec] = t
                hr = div(t, 4)
                mi = (t % 4) * 15
                ap = "AM"
                if hr - 12 >= 0
                    if hr - 12 > 0
                        hr -= 12
                    end
                    ap = "PM"
                end
                my_str = ("0" ^ (2 - length(string(hr)))) * string(hr) * ":" * ("0" ^ (2 - length(string(mi)))) * string(mi) * " " * ap
                temp2[sec] = my_str
                break
            end
        end
    end
    push!(path1, temp1)
    push!(path2, temp2)
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
        println(file2, sec, ": \t t = ", path1[f][sec], " --> ", path2[f][sec])
    end
    println(file2)
end
close(file2)
