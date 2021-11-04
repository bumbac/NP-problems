#=
main:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-10-23
=#


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

