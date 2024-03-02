#  In this script we find the (mixed) Nash equilibrium
#  for the monkey vs rabbit rock/paper/scissors game.

# load in packages
using JuMP, GLPK, LinearAlgebra

# INPUT - Payoff matrix M (m by n)
M = [0 -1; 1 0; -1 1]
m, n = size(M)[1], size(M)[2]

###  SOLVING THE PRIMAL PROBLEM

# Preparing an optimization model
md1 = Model(GLPK.Optimizer)

# Declaring variables
# Note here that x0 is unconstrained in the problem.
@variable(md1, x0)
@variable(md1, x[1:m] >= 0)

# Setting the objective
@objective(md1, Max, x0)

# Adding constraints M'x - 1x0 >=0 and sum(x) == 1
@constraint(md1, constraint1, transpose(M) * x - [x0 for i in 1:n] >= 0)
@constraint(md1, constraint2,  sum(x) == 1)

# Printing the prepared optimization model
print(md1)

# Solving the optimization problem
JuMP.optimize!(md1)

# Print the information about the optimum.
# We don't print x0 because it's just the value of the objective
println(" \n PRIMAL \n ")
println("Objective value: ", objective_value(md1), "\n")
println("Optimal solution:")
for i in 1:m
    println("x", i, " = ", value(x[i]))
end
println()

###  SOLVING THE DUAL PROBLEM

# Preparing an optimization model
md2 = Model(GLPK.Optimizer)

# Declaring variables
# Note y0 is unconstrained.

@variable(md2, y0)
@variable(md2, y[1:n] >= 0)

# Setting the objective
@objective(md2, Min, y0)

# Adding constraints My - 1y0 <= 0, sum(y) == 1
@constraint(md2, constraint1, M*y - [y0 for i in 1:m] <= 0)
@constraint(md2, constraint2, sum(y) == 1)

# Printing the prepared optimization model
print(md2)

# Solving the optimization problem
JuMP.optimize!(md2)

# Print the information about the optimum.
println(" \n DUAL \n ")
println("Objective value: ", objective_value(md2), "\n")
println("Optimal solution:")
for i in 1:n
    println("y", i, " = ", value(y[i]))
end
println()
