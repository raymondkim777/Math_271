# Declaring packages
using JuMP, GLPK, LinearAlgebra

# Preparing an optimization model
m = Model(GLPK.Optimizer)

# Declaring variables

M = [-2 3 ; 3 -4 ; -4 5]
@variable(m, x0)
@variable(m, x1 >= 0)
@variable(m, x2 >= 0)
@variable(m, x3 >= 0)

# Setting the objective
@objective(m, Max, x0)

# Adding constraints
@constraint(m, c1, transpose(M) * [x1; x2; x3] - [x0; x0] >= [0; 0])
@constraint(m, c2, x1 + x2 + x3 == 1)


# Printing the prepared optimization model
print(m)

# Solving the optimization problem
JuMP.optimize!(m)

# Print the information about the optimum.
println("Objective value: ", objective_value(m))
println("Optimal solutions:")
println("x1 = ", value(x1))
println("x2 = ", value(x2))
println("x3 = ", value(x3))