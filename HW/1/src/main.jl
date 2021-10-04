#=
main:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-09-26
=#
using Pkg
using Plots
using Statistics
using Combinatorics
using DataStructures
using BenchmarkTools
using DataFrames
using DataAPI

mutable struct BagInst
    ID::Int64
    n::Int64
    M::Int64
    B::Int64
    items
end

mutable struct BBNode
    ID::Int64
    ubound::Float64
    profit::Float64
    weight::Int64
    level::Int64
    flag::Int8
    included::Bool
    parent::Ref
    decision
end
import Base: isless
isless(a::BBNode, b::BBNode) = isless(a.ubound, b.ubound)


function brute(example)
    weight_limit = example.M
    price_limit = example.B
    sumprice = 0
    sumweight = 0
    for sset in powerset(example.items)
        sumprice = 0
        sumweight = 0
        for item in sset
            sumweight += item[1]
            sumprice += item[2]
            if sumweight > weight_limit
                break
            end
        end
        if sumprice >= price_limit && sumweight <= weight_limit
            # println("Found solution ", sset)
            return sset
        end
    end
    # println(example.ID, " found no solution.")
    end

function bnb(example)
    visited_configurations = 0
    matrix = zeros(Int64, example.n, 3)
    i_id = 1
    idx_weight = 1
    idx_price = 2
    idx_ID = 3
    for item in example.items
        matrix[i_id, idx_weight] = item[idx_weight]
        matrix[i_id, idx_price] = item[idx_price]
        matrix[i_id, idx_ID] = item[idx_ID]
        i_id += 1
    end

    idx = 1
    max = -Inf
    ubound = -Inf
    curr_capacity = 0
    curr_profit = 0
    i_level = 0
    i_node = 0
    flag = 0
    root = BBNode(i_node, ubound, curr_profit, curr_capacity, i_level, flag, false, Ref(missing), zeros(example.n))
    i_level += 1
    i_node += 1
    leaves = MutableBinaryMaxHeap{BBNode}()
    push!(leaves, root)
    node = root
    max_node = root
    while ! isempty(leaves)
        node  = pop!(leaves)
        i_level = node.level + 1
        for included in [0, 1]
            curr_capacity = node.weight
            real_capacity = node.weight
            curr_profit = node.profit
            real_profit = node.profit
            ubound = node.ubound
            idx = i_level
            if idx > example.n break end
            flag = 0
            decision = deepcopy(node.decision)
            visited_configurations += 1
            if curr_capacity + matrix[idx, idx_weight] <= example.M
                curr_capacity += matrix[idx, idx_weight]*included
                real_capacity = curr_capacity
                curr_profit += matrix[idx, idx_price]*included
                real_profit = curr_profit
                decision[idx] = included
            else
                if included == 1 flag = 2 end
            end
            # TODO BREAK CUZ LEAF IS NOT POSSIBLE
            if flag == 2 continue end
            idx += 1
            while idx <= example.n && curr_capacity + matrix[idx, idx_weight] <= example.M
                curr_capacity += matrix[idx, idx_weight]
                curr_profit += matrix[idx, idx_price]
                idx += 1
            end
            fraction = 0
            if idx <= example.n && curr_capacity != example.M
                remain = example.M - curr_capacity
                fraction = matrix[idx, idx_price]/matrix[idx, idx_weight]*remain
            end
            if ubound < curr_profit ubound = fraction + curr_profit end

            leaf = BBNode(i_node, ubound, curr_profit, real_capacity, i_level, flag, Bool(included), Ref(node), decision)
            i_node += 1
            push!(leaves, leaf)

            if max < ubound
                max = ubound
                max_node = leaf
                leaves = extract_all!(leaves)
                it = iterate(leaves)
                while it != nothing
                    item, state = it
                    if (item.flag != 2) && (item.ubound < max)
                        item.flag = 2
                    end
                    it = iterate(leaves, state)
                end
                new_leaves = MutableBinaryMaxHeap{BBNode}()
                for leaf in leaves
                    if leaf.flag != 2 || leaf.level == 0
                        push!(new_leaves, leaf)
                    end
                end
                leaves = new_leaves
            end
        end
    end
#     println("\n\n\n\n")
#     println("N ", example.n, " capacity ", example.M, " min price ", example.B, " profit ", max_node.profit)
#     println(matrix)
    checksum = 0
    checkweight = 0
    checkitems = zeros(Int8, example.n)
    for idx in 1:example.n
        if max_node.decision[idx] == 1
#             println(matrix[idx, idx_weight])
#             println(matrix[idx, idx_price])
            checksum += matrix[idx, idx_price]
            checkweight += matrix[idx, idx_weight]
            checkitems[matrix[idx, idx_ID]] = 1
        end
    end
#     println("CHECKSUM: ", checksum)
#     println("CHECKWEIGHT: ", checkweight)
#     println("CHECKITEMS: ", checkitems)
#     return checksum
    return visited_configurations
end

function eval(instances)
    brute_results = []
    for example in instances[1:3]
        println("Solving ", example.ID, " using brute force, capacity ", example.B)
        result = @benchmark brute($example)
        push!(brute_results, (example.ID, example.n, length(example.items), result.times))
        # bnb(example)
        # push!(bnb_results, (example, result))
    end
    return brute_results
    end

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
            B = 0
            try
                ID = parse(Int64, pieces[1])
                n = parse(Int64, pieces[2])
                M = parse(Float64, pieces[3])
                B = parse(Float64, pieces[4])
            catch e
                println("ERROR in parsing definition")
            end
            bag = BagInst(ID, n, M, B, [])
            idx = 1
            for i in 5:2:(length(pieces) - 1)
                weight = 0
                price = 0
                try
                    weight = parse(Float64, pieces[i])
                    price = parse(Float64, pieces[i + 1])
                catch e
                    println("ERROR in parsing pairs")
                end
                push!(bag.items, (weight, price, idx))
                idx += 1
            end
            sort!(bag.items, by = x -> (x[2]/x[1]), rev=true)
            push!(instances, bag)
        end
    end
    return instances
end

instances = readFile("../data/NR/NR40_inst.dat")
# brute_results = eval(instances)
# dump(brute_results)
sums = []
bench = zeros(Int64, length(instances), 2)
idx = 1
idx_n = 1
idx_visited = 2
uniques = Set()
for example in instances
    visited_configurations = bnb(example)
    bench[idx, idx_n] = example.n
    bench[idx, idx_visited] = visited_configurations
    global idx += 1
    push!(uniques, visited_configurations)
end
println(std(bench[:, idx_visited]))
println(var(bench[:, idx_visited]))
println(mean(bench[:, idx_visited]))
println(median(bench[:, idx_visited]))
histogram([1:length(instances)], bench[:,idx_visited])
savefig("./hist.png")
# dump(sums)

