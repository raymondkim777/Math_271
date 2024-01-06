using JuMP, GLPK

m = Model(GLPK.Optimizer)

# Lengths: 135, 108, 93, 42
# x1: 2*135
# x2: 135 + 108 + 42
# x3: 135 + 93 + 42
# x4: 135 + 3*42
# x5: 2*108 + 2*42
# x6: 108 + 2*93
# x7: 108 + 93 + 2*42
# x8: 108 + 4*42
# x9: 3*93
# x10: 2*93 + 2*42
# x11: 93 + 4*42
# x12: 7*42

@variable(m, x[1:12] >= 0, Int)

@objective(m, Min, sum(x))

@constraint(m, c1, 2*x[1] + x[2] + x[3] + x[4] >= 97)
@constraint(m, c2, x[2] + 2*x[5] + x[6] + x[7] + x[8] >= 610)
@constraint(m, c3, x[3] + 2*x[6] + x[7] + 3*x[9] + 2*x[10] + x[11] >= 395)
@constraint(m, c4, x[2] + x[3] + 3*x[4] + 2*x[5] + 2*x[7] + 4*x[8] + 2*x[10] + 4*x[11] + 7*x[12] >= 211)

print(m)

JuMP.optimize!(m)
println("Objective value: ", objective_value(m))
println("Optimal solutions:")
println("x[] = ", value.(x))
