#=
greedy:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-11-04
=#
include("file_loader.jl")


function simple_greedy(bag, M)
    curr_price = 0
    curr_m = 0
    i = 1
    n = size(bag)[1]
    while curr_m <= M && i <= n
        if (bag[i, 1] + curr_m) <= M
            curr_m += bag[i, 1]
            curr_price += bag[i, 2]
        end
        i += 1
    end
    return curr_price
end


function redux_greedy(bag, M)
    simple_solution = simple_greedy(bag, M)
    redux_solution = 0
    n = size(bag)[1]
    max_price = 0
    for i in 1:n
        if bag[i, 2] > max_price
            max_price = bag[i, 2]
        end
    end
    redux_solution = max_price
    if redux_solution > simple_solution
        return redux_solution
    end
    return simple_solution
end
