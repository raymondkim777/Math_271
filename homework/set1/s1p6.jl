# Declaring packages
using JuMP, GLPK

# Preparing an optimization model
diet = Model(GLPK.Optimizer)

# Declaring variables
@variable(diet, pb >= 1)
@variable(diet, wmlk >= 0)
@variable(diet, oats >= 0)
@variable(diet, beef >= 0)

# Setting the objective
@objective(diet, Min, 0.80pb + 0.20wmlk + 0.40oats + beef)

# Adding constraints

@constraint(diet, constraint1, 7pb + 8wmlk + 12oats + 24.19beef >= 160)
@constraint(diet, constraint2, 16pb + 8wmlk + 6oats + 5.65beef <= 80)
# @constraint(diet, constraint3, 2pb + 9oats <= 25) 
@constraint(diet, constraint4, 3pb + 11wmlk <= 40)

# Printing the prepared optimization model
print(diet)

# Solving the optimization problem
JuMP.optimize!(diet)

# Print the information about the optimum.
println("Objective value: ", objective_value(diet))
println("Optimal solutions:")
println("pb = ", value(pb))
println("wmlk = ", value(wmlk))
println("oats = ", value(oats))
println("beef = ", value(beef))
println("\nprotein: ", value(7pb + 8wmlk + 12oats + 24.19beef))
println("fat: ", value(16pb + 8wmlk + 6oats + 5.65beef))
println("fiber: ", value(2pb + wmlk + 9oats))
println("sugar: ", value(3pb + 11wmlk))