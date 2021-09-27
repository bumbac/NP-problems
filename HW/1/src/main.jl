#=
main:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-09-26
=#
using Combinatorics

mutable struct BagInst
    ID
    n
    M
    B
    items
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
            println("Found solution ", sset)
            return sset
        end
    end
    println(example.ID, " found no solution.")
    end

function bnb(example)
    println("TBA")
    end

function eval(instances)
    for example in instances
        println("Solving ", example.ID, " using brute force, capacity ", example.B)
        brute(example)
        # bnb(example)
    end
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
        eval(instances)
        end
    end

readFile("../data/NR/NR15_inst.dat")
