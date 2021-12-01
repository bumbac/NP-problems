#=
bnb:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-10-23
=#
using DataStructures
using Combinatorics

mutable struct BBNode
    ID::Int64
    ubound::Float64
    # real profit
    profit::Float64
    # real weight
    weight::Int64
    # depth in graph
    level::Int64
    # fresh, open, closed
    flag::Int8
    # take item or not
    included::Bool
    # decision vector of ordered items by w/p ratio
    decision
end

# comparison for heap, order by ubound
import Base: isless
isless(a::BBNode, b::BBNode) = isless(a.ubound, b.ubound)

function brute(bag, M)
    weight_limit = M
    sumprice = 0
    sumweight = 0
    attempts = 0
    # weight idx in matrix
    idx_weight = 1
    # price idx in matrix
    idx_price = 2
    # ID idx in matrix
    idx_ID = 3
    ran = collect([1:size(bag)[1];])
    result = [0, 0, 0]
    for sset in powerset(ran)
        sumprice = 0
        sumweight = 0
        for id in sset
            attempts += 1
            if sumweight + bag[id, idx_weight] > weight_limit continue end
            sumweight += bag[id, idx_weight]
            sumprice += bag[id, idx_price]
            if sumweight == weight_limit break end
        end
        if result[2] < sumprice
            result[1] = sumweight
            result[2] = sumprice
            result[3] = attempts
        end
    end
    return result
end



function bnb(bag, M)
    # benchmark for comparison
    visited_configurations = 0
    # matrix of items, their weight, price and ID
    n = size(bag)[1]
    matrix = zeros(Int64, n, 3)
    i_id = 1
    # weight idx in matrix
    idx_weight = 1
    # price idx in matrix
    idx_price = 2
    # ID idx in matrix
    idx_ID = 3
    for item in eachrow(bag)
        matrix[i_id, idx_weight] = item[idx_weight]
        matrix[i_id, idx_price] = item[idx_price]
        matrix[i_id, idx_ID] = item[idx_ID]
        i_id += 1
    end
    idx = 1
    # maximum price found yet
    max_ubound = -Inf
    # ubound found yet
    ubound = -Inf
    curr_capacity = 0
    curr_profit = 0
    # graph depth
    i_level = 0
    # ID of node in graph
    i_node = 0
    # shows if node is fresh - 0, open - 1 or closed - 2
    flag = 0
    root = BBNode(i_node, ubound, curr_profit, curr_capacity, i_level, flag, false, zeros(n))
    i_level += 1
    i_node += 1
    # MaxHeap of nodes - leaves, based on ubound
    leaves = MutableBinaryMaxHeap{BBNode}()
    push!(leaves, root)
    node = root
    max_node = root
    while ! isempty(leaves)
        # in each step choose leaf with highest ubound
        node  = pop!(leaves)
        i_level = node.level + 1
        # 0 left(do not take item), 1 right(take item) leaf of node
        for included in [0, 1]
            idx = i_level
            # depth of tree is greater than number of items
            if idx > n break end
            curr_capacity = node.weight
            real_capacity = node.weight
            curr_profit = node.profit
            real_profit = node.profit
            ubound = node.ubound
            flag = 0
            # copy vector of taken items
            decision = deepcopy(node.decision)
            # consider this node to be constructed and visited
            if (curr_capacity + matrix[idx, idx_weight]) <= M
                # values is multiplied by 0 or 1
                curr_capacity += matrix[idx, idx_weight]*included
                real_capacity = curr_capacity
                curr_profit += matrix[idx, idx_price]*included
                real_profit = curr_profit
                decision[idx] = included
            else
                # cannot take this item, too heavy, close leaf
                if included == 1 flag = 2 end
            end
            # continue because leaf is closed
            if flag == 2
                visited_configurations += 1
                continue
            end
            idx += 1
            # find ubound
            while idx <= n && curr_capacity + matrix[idx, idx_weight] <= M
                curr_capacity += matrix[idx, idx_weight]
                curr_profit += matrix[idx, idx_price]
                idx += 1
            end
            fraction = 0
            # take fraction of next item if possible
            if idx <= n && curr_capacity != M
                remain = M - curr_capacity
                fraction = matrix[idx, idx_price]/matrix[idx, idx_weight]
                ##
                curr_profit += (fraction*remain)
            end
            # update ubound with fraction
            if ubound < curr_profit ubound = curr_profit end
            leaf = BBNode(i_node, ubound, real_profit, real_capacity, i_level, flag, Bool(included), decision)
            i_node += 1
            push!(leaves, leaf)
            # check if current leaf is best solution yet
            if leaf.profit > max_node.profit max_node = leaf end

            if max_ubound < ubound
                max_ubound = ubound
                leaves = extract_all!(leaves)
                it = iterate(leaves)
                new_leaves = MutableBinaryMaxHeap{BBNode}()
                while it != nothing
                    item, state = it
                    if (item.flag != 2) && (item.ubound < max_ubound)
                        item.flag = 2
                        visited_configurations += 1
                    else
                        push!(new_leaves, item)
                    end
                    it = iterate(leaves, state)
                end
                leaves = new_leaves
            end

        end

    end
#     println("\n\n\n\n")
#     println("N ", n, " capacity ", M, " profit ", max_node.profit)
#     println(matrix)
    checksum = 0
    checkweight = 0
    checkitems = zeros(Int8, n)
    check_n = 0
    for idx in 1:n
        if max_node.decision[idx] == 1
#             println(matrix[idx, idx_weight])
#             println(matrix[idx, idx_price])
            checksum += matrix[idx, idx_price]
            checkweight += matrix[idx, idx_weight]
            checkitems[matrix[idx, idx_ID]] = 1
            check_n += 1
        end
    end
#     println("CHECKSUM: ", checksum)
#     println("CHECKWEIGHT: ", checkweight)
#     println("CHECKITEMS: ", checkitems)
#     return checksum, visited_configurations
#     return (checkweight, checksum, check_n, visited_configurations)
    return checksum
end

