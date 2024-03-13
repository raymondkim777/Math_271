# Declaring packages
using JuMP, GLPK, LinearAlgebra

# Preparing an optimization model
m = Model(GLPK.Optimizer)

# Declaring variables
x = [2/3 ; 1/3 ; 0]
M = [-2 2 3 -3; 3 -3 -4 4; -4 4 5 -5]
@variable(m, y[1:4] >= 0)

# Setting the objective
@objective(m, Min, transpose(x) * M * y)

# Adding constraints
@constraint(m, c1, sum(y) == 1)

# Printing the prepared optimization model
print(m)

# Solving the optimization problem
JuMP.optimize!(m)

# Print the information about the optimum.
println("Objective value: ", objective_value(m))
println("Optimal solution:")
for i in 1:4
    println("y", i, " = ", value(y[i]))
end