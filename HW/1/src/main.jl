#=
main:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-09-26
=#
using Pkg
using Combinatorics
using DataStructures
using BenchmarkTools

mutable struct BagInst
    ID::Int64
    n::Int64
    M::Int64
    B::Int64
    items
end

mutable struct BBNode
    ID::Int64
    lbound::Float64
    profit::Float64
    level::Int64
    flag::Int8
    parent::Ref
    decision
end


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
    matrix = zeros(Int64, example.n, 2, example.n)
    i_id = 1
    idx_weight = 1
    idx_price = 2
    for item in example.items
        matrix[i_id, idx_price] = item.price
        matrix[i_id, idx_weight] = item.weight
        i_id += 1
    end

    lbound = -Inf
    root = BBNode(1, lbound, 0, 0, 0, missing, zeros(example.n))
    leaves = Vector{BBNode}()
    push!(leaves, root)
    i_level = 0
    i_node = 1

    while ! isempty(leaves)
        node = leaves[i_node]
        while node.flag == 2 && i_node <= length(leaves)
            node = leaves[i_node]
            i_node += 1
        end
        curr_capacity = 0
        curr_profit = 0
        idx = 1
        while idx <= example.n
            if curr_capacity == example.B
                break
            end

            if (curr_capacity + matrix[idx, idx_weight]) <= example.B
                curr_capacity += matrix[idx, idx_weight]
                curr_profit += matrix[idx, idx_price]
                root.decision[idx] = 1
                idx += 1
            else
                if lbound < curr_profit
                    lbound = curr_profit
                    it = iterate(leaves)
                    while it != nothing
                        item, state = it
                        if (item.flage !=2) && (item.lbound < lbound)
                            item.flag = 2
                        end
                        it = iterate(leaves, state)
                    end
                end
                remain = example.B - curr_capacity
                fraction = matrix[idx, idx_price]/matrix[idx, idx_weight]*remain
                curr_profit += fraction
                curr_capacity = example.B
        end
    end
    end

    i_id += 1
    decision = copy(root_decision)
    i_level += 1
    decision[i_level] = 0
    left = BBNode(i_id, -Inf, 0, i_level, 0, Ref(root), copy(decision))
    i_id += 1
    decision[i_level] = 1
    right = BBNode(i_id, -Inf, 0, i_level, 0, Ref(root), copy(decision))
    push!(leaves, left)
    push!(leaves, right)


end

#function branch(node)
#end

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
            for i in 5:(length(pieces) - 1)
                weight = 0
                price = 0
                try
                    weight = parse(Float64, pieces[i])
                    price = parse(Float64, pieces[i + 1])
                catch e
                    println("ERROR in parsing pairs")
                end
                push!(bag.items, (weight, price))
            end
            push!(instances, bag)
        end
        end
        return instances
    end

instances = readFile("../data/NR/NR4_inst.dat")
brute_results = eval(instances)
dump(brute_results)

