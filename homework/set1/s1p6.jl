# Declaring packages
using JuMP, GLPK

# Preparing an optimization model
diet = Model(GLPK.Optimizer)

# Declaring variables
@variable(diet, pb >= 0)
@variable(diet, wmlk >= 0)
@variable(diet, oats >= 0)
@variable(diet, beef >= 0)

# Setting the objective
@objective(diet, Min, 0.80pb + 0.20wmlk + 0.40oats + beef)

# Adding constraints
@constraint(diet, constraint1, 16pb + 8wmlk + 6oats + 12beef <= 80)
@constraint(diet, constraint2, 3pb + 11wmlk <= 40)
@constraint(diet, constraint3, 7pb + 8wmlk + 12oats + 26beef >= 160)


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