using LinearAlgebra

A = [1 0 0 -2 -9 1 9; 0 1 0 1/3 1 -1/3 -2; 0 0 1 2 3 -1 -12]
b = [0; 0; 2]
c = [0; 0; 0; 2; 3; -1; -12]
B = [1, 2, 3]

# check B is basis
if size(B)[1] > size(A)[2]
    print("LP is infeasible")
elseif det(A[:, B]) == 0
    print("B is not a basis")

else
    while true
        # calculating tableau
        n = size(A)[2]
        N = setdiff(1:n, B)
        
        Q = -inv(A[:, B]) * A[:, N]
        p = inv(A[:, B]) * b
        r = c[N] - transpose(transpose(c[B]) * inv(A[:, B]) * A[:, N])
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
        if x_n in B || !(x_b in B)
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
