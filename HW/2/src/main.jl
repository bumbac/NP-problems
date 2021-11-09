#=
main:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-10-23
=#

using JLD2

include("file_loader.jl")
include("price_dec.jl")
include("bnb.jl")
include("greedy.jl")



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
    n_values = [4, 10, 15, 20, 25, 30, 35, 40]
    attempts = 100
    decompose = Dict()
    ftps_bit = Dict()
    ftps_eps = Dict()

    for n in n_values
        println("n ", n)
        filename = "../data/ZKC/ZKC"*string(n)*"_inst.dat"


        decompose[n] = []
        for a in 1:attempts
            instances = readFile(filename)
            t = @elapsed for instance in instances
                price_decompose(instance[1], instance[2])
            end
            print(t," ")
            push!(decompose[n], t)
        end
        println()
        println(decompose)
        save_object("decompose_zk.jld2", decompose)

        ftps_bit[n] = []
        for a in 1:attempts
            instances = readFile(filename)
            t = @elapsed for instance in instances
                price_decompose(instance[1], instance[2], bits=2)
            end
            print(t," ")
            push!(ftps_bit[n], t)
        end
        println()
        println(ftps_bit)
        save_object("bits_zk.jld2", ftps_bit)

        ftps_eps[n] = []
        for a in 1:attempts
            instances = readFile(filename)
            t = @elapsed for instance in instances
                price_decompose(instance[1], instance[2], epsilon_error=0.1)
            end
            print(t, " ")
            push!(ftps_eps[n], t)
        end
        println()
        println(ftps_eps)
        save_object("eps_zk.jld2",ftps_eps)
    end


    bench_bit = Dict()
    bench_eps = Dict()
    bit = [1, 2, 4, 8, 16]
    epsilon = [0.01, 0.05, 0.1, 0.3, 0.5]
    for i in 1:size(bit)[1]
        bench_bit[i] = Dict()
        bench_eps[i] = Dict()
        for n in n_values
            println("n ", n)
            filename = "../data/ZKC/ZKC"*string(n)*"_inst.dat"

            bench_bit[i][n] = []
            for a in 1:attempts
                instances = readFile(filename)
                t = @elapsed for instance in instances
                    price_decompose(instance[1], instance[2], bits=bit[i])
                end
                print(t," ")
                push!(bench_bit[i][n], t)
            end
            println()
            save_object("bench_bit_zk.jld2", bench_bit)

            bench_eps[i][n] = []
            for a in 1:attempts
                instances = readFile(filename)
                t = @elapsed for instance in instances
                    price_decompose(instance[1], instance[2], epsilon_error=epsilon[i])
                end
                print(t, " ")
                push!(bench_eps[i][n], t)
            end
            println()
            save_object("bench_eps_zk.jld2", bench_eps)
        end
    end
end
# using DataFrames
# using StatsPlots
function analyze()

#    bench_bit = load_object("bench_bit.jld2")
#    bench_bit_zk = load_object("bench_bit_zk.jld2")
#    bench_eps = load_object("bench_eps.jld2")
#    bench_eps_zk = load_object("bench_eps_zk.jld2")
   decompose4 = load_object("decompose4-30.jld2")
#    bits4 = load_object("bits4-30.jld2")
#    eps4 = load_object("eps4-30.jld2")
   n_values = [4, 10, 15, 20, 25, 30, 35, 40]
   n_4 = [4, 10, 15, 20, 25, 30]
   bit = [1, 2, 4, 8, 16]
   epsilon = [0.01, 0.05, 0.1, 0.3, 0.5]
#    display(bench_bit)
#    println()
#    display(bits4)
#    println()
#    datf = DataFrame(;[Symbol(k)=>v for (k,v) in decompose4]...)
#    display(datf)
#    cn = names(datf)
#    @df datf boxplot(:Variable, :Value)
#    savefig("boxdecompose44.png")


end

function bench2()
    n_values = [4, 10, 15, 20]#, 25, 30, 35, 40]
    attempts = 10
    bnnb = Dict()

    for n in n_values
        println("n ", n)
        filename = "../data/ZKC/ZKC"*string(n)*"_inst.dat"


        bnnb[n] = []
        for a in 1:attempts
            instances = readFile(filename)
            t = @elapsed for instance in instances
                bnb(instance[1], instance[2])
            end
            print(t," ")
            push!(bnnb[n], t)
        end
        println()
        println(bnnb)
        save_object("bnb_zk.jld2", bnnb)
    end


end
function bench3()
    n_values = [4, 10, 15, 20, 25, 30, 35, 40]
    attempts = 100
    greedy = Dict()
    redux = Dict()
    for n in n_values
        println("n ", n)
        filename = "../data/ZKC/ZKC"*string(n)*"_inst.dat"


        greedy[n] = []
        for a in 1:attempts
            instances = readFile(filename)
            t = @elapsed for instance in instances
                simple_greedy(instance[1], instance[2])
            end
            print(t," ")
            push!(greedy[n], t)
        end
        println()
        println(greedy)
        save_object("greedy_zk.jld2", greedy)

        redux[n] = []
        for a in 1:attempts
            instances = readFile(filename)
            t = @elapsed for instance in instances
                redux_greedy(instance[1], instance[2])
            end
            print(t," ")
            push!(redux[n], t)
        end
        println()
        println(redux)
        save_object("redux_zk.jld2", redux)
    end


end

function bench4()
    n_values = [4, 10, 15, 20, 25, 30, 35, 40]
    bit = [1, 2, 4, 8, 16]
    epsilon = [0.01, 0.05, 0.1, 0.3, 0.5]
    simple = Dict()
    redux = Dict()
    ftps_bit = Dict()
    ftps_eps = Dict()

    for n in n_values
        println(n)
        filename = "../data/NK/NK"*string(n)*"_sol.dat"
        solutions = readSolution(filename)

        idx = 1
        cnt = 0
        filename = "../data/NK/NK"*string(n)*"_inst.dat"
        instances = readFile(filename)
        simple[n] = []
        for instance in instances
            max_price = simple_greedy(instance[1], instance[2])#, epsilon_error = 0.01)
            push!(simple[n], abs(max_price - solutions[idx][3]))
            if max_price != solutions[idx][3]
                cnt += 1
            end
            idx += 1
        end
        push!(simple[n], cnt)
        save_object("simple_err_zk.jld2", simple)


        idx = 1
        cnt = 0
        filename = "../data/NK/NK"*string(n)*"_inst.dat"
        instances = readFile(filename)
        redux[n] = []
        for instance in instances
            max_price = redux_greedy(instance[1], instance[2])#, epsilon_error = 0.01)
            push!(redux[n], abs(max_price - solutions[idx][3]))
            if max_price != solutions[idx][3]
                cnt += 1
            end
            idx += 1
        end
        push!(redux[n], cnt)
        save_object("redux_err_zk.jld2", redux)
    end


    for bits in bit
        ftps_bit[bits] = Dict()
        for n in n_values
            println("bit ", n)
            filename = "../data/NK/NK"*string(n)*"_sol.dat"
            solutions = readSolution(filename)

            idx = 1
            cnt = 0
            filename = "../data/NK/NK"*string(n)*"_inst.dat"
            instances = readFile(filename)
            ftps_bit[bits][n] = []
            for instance in instances
                max_price = price_decompose(instance[1], instance[2], bits=bits)#, epsilon_error = 0.01)
                push!(ftps_bit[bits][n], abs(max_price - solutions[idx][3]))
                if max_price != solutions[idx][3]
                    cnt += 1
                end
                idx += 1
            end
            push!(ftps_bit[bits][n], cnt)
        end
        save_object("bits_err_zk.jld2", ftps_bit)
    end

    for eps in epsilon
        ftps_eps[eps] = Dict()
        for n in n_values
            println("eps ", n)
            filename = "../data/NK/NK"*string(n)*"_sol.dat"
            solutions = readSolution(filename)

            idx = 1
            cnt = 0
            filename = "../data/NK/NK"*string(n)*"_inst.dat"
            instances = readFile(filename)
            ftps_eps[eps][n] = []
            for instance in instances
                max_price = price_decompose(instance[1], instance[2], epsilon_error = eps)
                push!(ftps_eps[eps][n], abs(max_price - solutions[idx][3]))
                if max_price != solutions[idx][3]
                    cnt += 1
                end
                idx += 1
            end
            push!(ftps_eps[eps][n], cnt)
        end
        save_object("eps_err_zk.jld2", ftps_eps)
    end

end


#bench()
# bench2()
bench4()