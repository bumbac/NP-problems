#=
price_dec:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-10-23
=#
include("file_loader.jl")

function price_decompose(bag, M)
    # limit price is the height of table, maximum price of bag is sum of all items
    limit_price = 0
    n = size(bag)[1]
    items = zeros(Int64, (n, 3))
    i = 1
    for item in eachrow(bag)
        items[i, 1] = item[1]
        items[i, 2] = item[2]
        # find maximum possible price
        limit_price += item[2]
        items[i, 3] = item[3]
        i += 1
    end
#     println(M, "\t", items)
#     println(example)
    table = zeros((n + 1, limit_price + 1))
    table[1,:] .= typemax(Float64)
    table[1,1] = 0

#     println(size(table))
#     println(n)
    max_index = 0
    max_price = 0
    for n in 2:(n+1)
        for p in 2:(limit_price+1)
            # weight and price of possibly added item
            wi = items[n-1, 1]
            ci = items[n-1, 2]
            right = typemax(Float64)
            if (p - ci) >= 1
                right = table[n-1, p - ci] + wi
            end
            table[n, p] = min(table[n-1, p], right)
            if table[n, p] <= M  && (p-1) > max_price
                max_price = p - 1
                max_index = n - 1
            end
        end
    end
    return max_price
end

function main()
    n = 4
    filename = "../data/NK/NK"*string(n)*"_inst.dat"
    instances = readFile(filename)
    filename = "../data/NK/NK"*string(n)*"_sol.dat"
    solutions = readSolution(filename)
    idx = 1
    # check if valid
    for instance in instances
        max_price = price_decompose(instance[1], instance[2])
        if max_price != solutions[idx][3]
            println("Wrong answer.")
            println(max_price, " ", solutions[idx][3])
            println()
        end
        idx += 1
    end
end


function bench()
    n_values = [4, 10, 15, 20, 25]#, 30, 35, 40]
    attempts = 3
    b_values = []
    for n in n_values
        for attempt in 1:attempts
            filename = "../data/NK/NK"*string(n)*"_inst.dat"
            instances = readFile(filename)
            t = @elapsed for instance in instances
                price_decompose(instance[1], instance[2])
            end
            push!(b_values, t)
            println("N:\t", n, "\tattempt:\t", attempt, "\ttime:\t", t)
        end
    end
    print(b_values)
end

# main()


bench()
