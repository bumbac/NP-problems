#=
main:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-10-23
=#

include("file_loader.jl")
include("price_dec.jl")


function main()
    # starting function for loading and solving knapsack problem
    # number of instances
    n = 40
    filename = "../data/NK/NK"*string(n)*"_inst.dat"
    instances = readFile(filename)
    filename = "../data/NK/NK"*string(n)*"_sol.dat"
    solutions = readSolution(filename)
    idx = 1
    cnt = 0
    for instance in instances
        max_price = price_decompose(instance[1], instance[2], epsilon_error = 0.01)
        if max_price != solutions[idx][3]
            println("Wrong answer.")
            println(max_price, " ", solutions[idx][3])
            println(idx)
            cnt += 1
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

main()
