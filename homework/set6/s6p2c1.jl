# Declaring packages
using JuMP, GLPK

# Preparing an optimization model
m = Model(GLPK.Optimizer)

# Declaring variables
@variable(m, x1 >= 0)
@variable(m, x2 >= 0)

# Setting the objective
@objective(m, Min, 0.5x1 + 0.8x2)

# Adding constraints
@constraint(m, c1, 3x1 >= 6)
@constraint(m, c2, 2x1 + 4x2 >= 10)
@constraint(m, c3, 2x1 + 5x2 >= 8)

# Printing the prepared optimization model
print(m)

# Solving the optimization problem
JuMP.optimize!(m)

# Print the information about the optimum.
println("Objective value: ", objective_value(m))
println("Optimal solutions:")
println("x1 = ", value(x1))
println("x2 = ", value(x2))