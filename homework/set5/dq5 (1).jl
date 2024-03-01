using LinearAlgebra

A = [-2 1 1 0 0 ; 1 -2 0 1 0; 1 1 0 0 1]
b = [4, 2, 10]
c = [2, 3, 0, 0, 0]
B = [3, 4, 5]

# check B is basis
if size(B)[1] > size(A)[2]
    print("LP is infeasible")
elseif det(A[:, B]) == 0
    print("B is not a basis")

else
    while true
        # calculating tableau
        n = size(A)[2]
        Q = -inv(A[:, B]) * A[:, setdiff(1:n, B)]
        p = inv(A[:, B]) * b
        r = c[setdiff(1:n, B)] - transpose(transpose(c[B]) * inv(A[:, B]) * A[:, setdiff(1:n, B)])
        z0 = transpose(c[B]) * inv(A[:, B]) * b
        
        # printing tableau
        println("p = ", p)
        println("Q = ", Q)
        println("z0 = ", z0)
        println("r = ", r)

        # pivoting
        println("\nCurrent basis: ", B)
        print("Entering variable index: ")
        x_n = parse(Int64, readline())  
        print("Exiting variable index: ")
        x_b = parse(Int64, readline()) 

        # check for erronious input
        if size(findall(x->x == x_n, setdiff(1:n, B)))[1] == 0 || size(findall(x->x == x_b, B))[1] == 0
            println("Erronious input for x_n or x_b")
            exit()
        end
        println()

        # modify basis
        deleteat!(B, findall(x->x == x_b, B)[1])
        push!(B, x_n)
        sort!(B)
    end    
end
