# Declaring packages
using JuMP, GLPK

# Preparing an optimization model
m = Model(GLPK.Optimizer)

# Declaring variables
@variable(m, x1 >= 0)
@variable(m, x2 >= 0)

# Setting the objective
@objective(m, Min, x1 + x2)

# Adding constraints
@constraint(m, constraint1, x1 + 3x2 <= 9)
@constraint(m, constraint2, -2x1 + x2 <= -5)
@constraint(m, constraint3, x1 + 2x2 <= 8)

# Printing the prepared optimization model
print(m)

# Solving the optimization problem
JuMP.optimize!(m)

# Print the information about the optimum.
println("Objective value: ", objective_value(m))
println("Optimal solutions:")
println("x1 = ", value(x1))
println("x2 = ", value(x2))
