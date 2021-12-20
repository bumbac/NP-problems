#=
file_loader:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-11-04
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
            n=15
            bag = zeros(Int64, (15, 3))
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
                if weight > M price = 0 end
                bag[idx, 2] = price
                bag[idx, 3] = idx
                idx += 1
                if idx > 15 break end
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
