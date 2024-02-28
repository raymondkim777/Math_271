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
    allBasis = Array[]
    while true
        # tracking basis
        if B in allBasis
            cyc_idx = findall(x->x == B, allBasis)[1]
            cyc_len = size(allBasis)[1] - cyc_idx + 1
            println("\n", cyc_len, "-cycle: ", allBasis[cyc_idx: size(allBasis)[1]])
            exit()
        end
        push!(allBasis, copy(B))

        # calculating tableau
        n = size(A)[2]
        Q = -inv(A[:, B]) * A[:, setdiff(1:n, B)]
        p = inv(A[:, B]) * b
        r = c[setdiff(1:n, B)] - transpose(transpose(c[B]) * inv(A[:, B]) * A[:, setdiff(1:n, B)])
        z0 = transpose(c[B]) * inv(A[:, B]) * b
        
        # printing tableau
        println("\nBasis: ", B)
        println("Nonbasis: ", setdiff(1:n, B))
        println("p = ", p)
        println("Q = ", Q)
        println("z0 = ", z0)
        println("r = ", r)
        
        # choosing pivot

        # entering
        maxval_n, idx_n = findmax(r)
        x_n = setdiff(1:n, B)[idx_n]

        # (if optimum found)
        if maxval_n <= 0
            x = Array{Float64}(undef, 0)
            for i in eachindex(view(A, 1, :))
                if i in B
                    push!(x, p[findall(x->x == i, B)[1]])
                else
                    push!(x, 0)
                end
            end
            println("\nOptimum found: z = ", z0, " at x = ", x)
            exit()
        end

        # exiting
        x_b = B[1]
        minval_b = -1
        coeff_b = 0

        for i in eachindex(view(A, :, 1))
            idx = findall(x->x == x_n, setdiff(1:n, B))[1]
            coeff = Q[i, idx]
            println("coeff: ", coeff)
            if coeff < 0
                if minval_b == -1 || p[i] / (-coeff) < minval_b || (p[i] / (-coeff) == minval_b && abs(coeff) > abs(coeff_b))
                    x_b = B[i]
                    minval_b = p[i] / (-coeff)
                    coeff_b = coeff
                end
            end
        end

        # (if LP unbounded)
        if minval_b == -1
            println("\n LP is Unbounded")
            exit()
        end

        println("\nEntering variable index: ", x_n)
        println("Exiting variable index: ", x_b)

        # modify basis
        deleteat!(B, findall(x->x == x_b, B)[1])
        push!(B, x_n)
        sort!(B)
    end    
end
