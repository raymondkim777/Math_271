# Declaring packages
using JuMP, HiGHS

# Preparing an optimization model
m = Model(HiGHS.Optimizer)

# Declaring variables
@variable(m, x1 >= 0)
@variable(m, x2 >= 0)
@variable(m, x3 >= 0)

# Setting the objective
@objective(m, Min, x1^2 + 2x2^2)

# Adding constraints
@constraint(m, c1, x1 + x2 + x3 == 3)
@constraint(m, c2, x1 - 2x2 == -3)

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