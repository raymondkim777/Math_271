# Declaring packages
using JuMP, HiGHS

# Preparing an optimization model
m = Model(HiGHS.Optimizer)

# Declaring variables
@variable(m, x[1:2])
@variable(m, z[1:3])

# Setting the objective
@objective(m, Max, 2x[1] + 3z[1])

# Adding constraints
@constraint(m, c1, z[1] <= x[2] - 10)
@constraint(m, c2, z[1] <= -x[2] + 10)
@constraint(m, c3, z[2] + z[3] <= 5)
@constraint(m, c4, z[2] <= x[1] + 2)
@constraint(m, c5, z[2] <= -x[1] - 2)
@constraint(m, c6, z[3] <= x[2])
@constraint(m, c7, z[3] <= -x[2])


# Printing the prepared optimization model
print(m)

# Solving the optimization problem
optimize!(m)

# Print the information about the optimum.
println("Objective value: ", objective_value(m))
println("Optimal solutions:")
println("x1 = ", value(x[1]))
println("x2 = ", value(x[2]))
println("z123 = ", value.(z))