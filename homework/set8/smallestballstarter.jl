#  This script is a starter script for solving the convex (quadratic)
#  optimization problem for the smallest ball enclosing a set of points.

# load in packages
using JuMP
import HiGHS # run 'using Pkg;  Pkg.add("HiGHS")' if needed
using Plots  # run 'using Pkg;  Pkg.add("Plots")' if needed

# Generate random points.  These points will all be in the unit square [0,1]x[0,1]
n = 10; # number of points
Q = rand(2,n);  # generate n random points in R^2 as columns of a 2xn matrix
pnts = [Q[:,i] for i = 1:n]  # pnts is the list of points 
pdp =[Q[:,i]'*Q[:,i] for i = 1:n];  # list of dot products p_j^T p_j.


# Prepare the model using the HiGHS solver.
model = Model(HiGHS.Optimizer)

# Declaring variables
@variable(model, x[1:n] >= 0)

# Define your objective
@objective(model, Min, x' * Q' * Q * x - sum([
    (x[j] * pdp[j]) for j in 1:n
]))

# Define your constraint
@constraint(model, c1, sum(x) == 1)

# Optimize your model
optimize!(model)

# Access the values of the decision variables and objective
xstar = value.(x)
opt = objective_value(model)


# This is template code for plotting your points and a circle that will (hopefully) enclose them.
t = range(0,stop=2*π,length=100)
rad = sqrt(-opt)
cen = Q * xstar
xc1 = cen[1] .+ rad*cos.(t)
xc2 = cen[2] .+ rad*sin.(t)

# Plot our data 
plot(Q[1,:],Q[2,:], xlims=(-.2, 1.2), ylims=(-.2,1.2),seriestype=:scatter, label="random points",aspect_ratio=1.0)
plot!(xc1,xc2,label="enclosing ball")