# 
using JuMP, GLPK

# Preparing an optimization model
m = Model(GLPK.Optimizer)

# Declaring variables
@variable(m, y1 >= 0)
@variable(m, y2 >= 0)
@variable(m, y3 >= 0)

# Setting the objective
@objective(m, Min, y1 + 15y2 + 10y3)

# Adding constraints
@constraint(m, constraint1, -y1 + y2 + 4y3 >= 1)
@constraint(m, constraint2,  y1 + 6y2 - y3 >= 1)

# Printing the prepared optimization model
print(m)

# Solving the optimization problem
JuMP.optimize!(m)

# Print the information about the optimum.
println("Objective value: ", objective_value(m))
println("Optimal solutions:")
println("x1 = ", value(y1))
println("x2 = ", value(y2))
println("x2 = ", value(y3))
