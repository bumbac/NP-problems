#=
data_analysis:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-10-14
=#
using JLD2
using Statistics
using Plots

function analyze(filename)
    all_results = load_object("../out/results/"*filename)
    bnb_id = 2
    n = 500
    bench = zeros(Int64, n, 2)
    brute_id = 1
    uniques_brute = Set()
    uniques_bnb = Set()
    for idx in 1:n
        if length(all_results[1]) > 1
            bench[idx, brute_id] = all_results[brute_id][idx][4]
            push!(uniques_brute, all_results[brute_id][idx][4])
        end
        bench[idx, bnb_id] = all_results[bnb_id][idx][4]
        push!(uniques_bnb, all_results[bnb_id][idx][4])
    end
    for i in [1, 2]
        lbel = "Brute"
        if i == 1
            println("BRUTE RESULTS")
            lbel = "Brute force"
        else
            println("BNB RESULTS")
            lbel = "Branch and bound"
        end
        if length(all_results[i]) > 1
            println("max ", maximum(bench[:, i]))
            println("min ", minimum(bench[:, i]))
            println("std ", std(bench[:, i]))
            println("mean ", mean(bench[:, i]))
            println("median ", median(bench[:, i]))
            histogram([1:n], bench[:, i], bins=10, xlabel = "Visited configurations", label = lbel)
            savefig(("./hist/"*filename*string(i)*".png"))
        end
    end
end

for (root, dirs, files) in walkdir("../out/results")
    for file in files
        println(file)
        if occursin("Z4", file) || occursin("Z3", file) || occursin("Z2", file)
            analyze(file)
        end
    end
end