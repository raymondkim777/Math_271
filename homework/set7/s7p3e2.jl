# Declaring packages
using JuMP, GLPK, LinearAlgebra

# Preparing an optimization model
m = Model(GLPK.Optimizer)

# Declaring variables

M = [-2 3 ; 3 -4 ; -4 5]
@variable(m, y0)
@variable(m, y1 >= 0)
@variable(m, y2 >= 0)

# Setting the objective
@objective(m, Min, y0)

# Adding constraints
@constraint(m, c1, M * [y1; y2] - [y0; y0; y0] <= [0; 0; 0])
@constraint(m, c2, y1 + y2 == 1)


# Printing the prepared optimization model
print(m)

# Solving the optimization problem
JuMP.optimize!(m)

# Print the information about the optimum.
println("Objective value: ", objective_value(m))
println("Optimal solutions:")
println("y1 = ", value(y1))
println("y2 = ", value(y2))