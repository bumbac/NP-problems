#=
price_dec:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-10-23
=#

function readFile(name::String)
    line = 0
    instances = []
    open(name) do f
        while !eof(f)
            s = readline(f)
            line += 1
            pieces = split(s, ' ')
            ID = 0
            n = 0
            M = 0
            try
                ID = parse(Int64, pieces[1])
                n = parse(Int64, pieces[2])
                M = parse(Float64, pieces[3])
            catch e
                println("ERROR in parsing definition")
            end
            bag = zeros(Int64, (n, 3))
            idx = 1
            for i in 4:2:(length(pieces) - 1)
                weight = 0
                price = 0
                try
                    weight = parse(Int64, pieces[i])
                    price = parse(Int64, pieces[i + 1])
                catch e
                    println("ERROR in parsing pairs")
                end
                bag[idx, 1] = weight
                bag[idx, 2] = price
                bag[idx, 3] = idx
                idx += 1
            end
            bag = sortslices(bag, dims=1, by=x->(x[2]/x[1]), rev=true)
            push!(instances, (bag, M))
        end
    end
    return instances
end


function readSolution(filename::String)
    solution = []
    line = 0
    open(filename) do f
     while !eof(f)
            s = readline(f)
            line += 1
            pieces = split(s, ' ')
            ID = 0
            n = 0
            B = 0
            try
                ID = parse(Int64, pieces[1])
                n = parse(Int64, pieces[2])
                B = parse(Float64, pieces[3])
            catch e
                println("ERROR in parsing definition")
            end
            push!(solution, (ID, n, B))
    end
    return solution
end
end


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
