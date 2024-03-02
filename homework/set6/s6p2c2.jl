# Declaring packages
using JuMP, GLPK

# Preparing an optimization model
m = Model(GLPK.Optimizer)

# Declaring variables
@variable(m, y1 >= 0)
@variable(m, y2 >= 0)
@variable(m, y3 >= 0)

# Setting the objective
@objective(m, Max, 6y1 + 10y2 + 8y3)

# Adding constraints
@constraint(m, c1, 3y1 + 2y2 + 2y3 <= 0.5)
@constraint(m, c2, 4y2 + 5y3 <= 0.8)

# Printing the prepared optimization model
print(m)

# Solving the optimization problem
JuMP.optimize!(m)

# Print the information about the optimum.
println("Objective value: ", objective_value(m))
println("Optimal solutions:")
println("y1 = ", value(y1))
println("y2 = ", value(y2))
println("y3 = ", value(y3))