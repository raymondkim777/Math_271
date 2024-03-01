# Declaring packages
using JuMP, GLPK

# Preparing an optimization model
m = Model(GLPK.Optimizer)

# Declaring variables
@variable(m, x1 >= 0)
@variable(m, x2 >= 0)
@variable(m, x3 >= 0)
@variable(m, x4 >= 0)
@variable(m, x5 >= 0)
@variable(m, x6 >= 0)

# Setting the objective
@objective(m, Max, x1 - x2)

# Adding constraints
@constraint(m, constraint1, 2x1 + x2 + x3 == 4)
@constraint(m, constraint2, x1 + x4 == 2)
@constraint(m, constraint3, x2 + x5 == 2)
@constraint(m, constraint4, x3 + x6 == 2)

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
println("x4 = ", value(x4))
println("x5 = ", value(x5))
println("x6 = ", value(x6))
