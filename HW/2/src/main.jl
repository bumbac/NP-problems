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
    n_values = [4, 10, 15, 20]#, 25, 30, 35, 40]
    attempts = 1
    bnnb = Dict()
    decompose = Dict()
#     ftps_bit = Dict()
#     ftps_eps = Dict()

    for n in n_values
        println("n ", n)
        filename = "../data/NK/NK"*string(n)*"_inst.dat"

        decompose[n] = []
        instances = readFile(filename)
        for instance in instances
            t = @elapsed price_decompose(instance[1], instance[2])
            print(t," ")
            push!(decompose[n], t)
        end

        bnnb[n] = []
        s = 0
        instances = readFile(filename)
        for instance in instances
            t = @elapsed bnb(instance[1], instance[2])
            print(t," ")
            push!(bnnb[n], t)
        end

#         s = 0
#         for a in 1:attempts
#             instances = readFile(filename)
#             t = @elapsed for instance in instances
#                 price_decompose(instance[1], instance[2], epsilon_error=0.05)
#             end
#             print(t, " ")
#             s += t
#         end
#         ftps_eps[n] = s
#         println()
#         println(ftps_eps)
    end
    save_object("decomposeNKi.jld2", decompose)
    save_object("bnbNKi.jld2", bnnb)
#     save_object("eps2.jld2",ftps_eps)

return

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

function bench2()
    n_values = [4, 10, 15, 20]#, 25, 30, 35, 40]
    attempts = 3
    bnnb = Dict()

    for n in n_values
        bnnb[n] = []
        println("n ", n)
        filename = "../data/NK/NK"*string(n)*"_inst.dat"

        s = 0
        for a in 1:attempts
            instances = readFile(filename)
            t = @elapsed for instance in instances
                bnb(instance[1], instance[2])
            end
            push!(bnnb[n], t)
            print(t," ")
            s += t
        end
        push!(bnnb[n], s/attempts)
        save_object("bnb2_nk_time.jld2", bnnb)
    end

    for n in n_values
        println("n ", n)
        filename = "../data/NK/NK"*string(n)*"_inst.dat"

        s = 0
        for a in 1:attempts
            instances = readFile(filename)
            println(a)
            t = @elapsed for instance in instances
                bnb(instance[1], instance[2])
            end
            print(t," ")
            s += t
        end
        bnnb[n] = s/attempts
        save_object("bnb2.jld2", bnnb)
    end
end


function bench3()
    n_values = [4, 10, 15, 20, 25, 30, 35, 40]
    attempts = 1000
    greedy = Dict()
    redux = Dict()
    greedy_z = Dict()
    redux_z = Dict()
    for n in n_values
        println()
        println("n ", n)
        println()
        filename = "../data/ZKC/ZKC"*string(n)*"_inst.dat"
        s = 0
        instances = readFile(filename)
        for a in 1:attempts
            t = @elapsed for instance in instances
                simple_greedy(instance[1], instance[2])
            end
            s += t
        end
        greedy_z[n] =  s / attempts
        println(n, " ", s)

        s = 0
        for a in 1:attempts
            t = @elapsed for instance in instances
                redux_greedy(instance[1], instance[2])
            end
            s += t
        end
        redux_z[n] = s / attempts
        println(n, " ", s)

        filename = "../data/NK/NK"*string(n)*"_inst.dat"
        s = 0
        instances = readFile(filename)
        for a in 1:attempts
            t = @elapsed for instance in instances
                simple_greedy(instance[1], instance[2])
            end
            s += t
        end
        greedy[n] =  s / attempts
        println(n, " ", s)

        s = 0
        for a in 1:attempts
            t = @elapsed for instance in instances
                redux_greedy(instance[1], instance[2])
            end
            s += t
        end
        redux[n] = s / attempts
        println(n, " ", s)

    end
        save_object("redux2.jld2", redux)
        save_object("greedy2.jld2", greedy)
        save_object("greedy2_zk.jld2", greedy_z)
        save_object("redux2_zk.jld2", redux_z)

end

function bench4()
    n_values = [4, 10, 15, 20, 25, 30, 35, 40]
    bit = [1, 2, 4, 8, 16]
    epsilon = [0.01, 0.05, 0.1, 0.3, 0.5]
    simple = Dict()
    redux = Dict()
    ftps_bit = Dict()
    ftps_eps = Dict()
#
#     for n in n_values
#         println(n)
#         filename = "../data/ZKC/ZKC"*string(n)*"_sol.dat"
#         solutions = readSolution(filename)
#
#         idx = 1
#         cnt = 0
#         filename = "../data/ZKC/ZKC"*string(n)*"_inst.dat"
#         instances = readFile(filename)
#         simple[n] = []
#         for instance in instances
#             max_price = simple_greedy(instance[1], instance[2])#, epsilon_error = 0.01)
#             err = abs(max_price - solutions[idx][3])
#             if err != 0
#                 err = err / max(max_price, solutions[idx][3])
#             end
#
#             push!(simple[n], err)
#             idx += 1
#         end
#
#         save_object("S_err_zk.jld2", simple)
#
#
#         idx = 1
#         cnt = 0
#         filename = "../data/NK/NK"*string(n)*"_inst.dat"
#         instances = readFile(filename)
#         redux[n] = []
#         for instance in instances
#             max_price = redux_greedy(instance[1], instance[2])#, epsilon_error = 0.01)
#             err = abs(max_price - solutions[idx][3])
#             if err != 0
#                 err = err / max(max_price, solutions[idx][3])
#             end
#             push!(redux[n], err)
#             idx += 1
#         end
#
#         save_object("R_err.jld2", redux)
#     end

    for bits in bit
        ftps_bit[bits] = Dict()
        for n in n_values
            println("bit ", n)
            filename = "../data/NK/NK"*string(n)*"_sol.dat"
            solutions = readSolution(filename)

            idx = 1
            cnt = 0
            filename = "../data/ZKC/ZKC"*string(n)*"_inst.dat"
            instances = readFile(filename)
            ftps_bit[bits][n] = []
            for instance in instances
                t = @elapsed max_price = price_decompose(instance[1], instance[2], bits=bits)#, epsilon_error = 0.01)
#                 push!(ftps_bit[bits][n], abs(max_price - solutions[idx][3]))
#                 if max_price != solutions[idx][3]
#                     cnt += 1
#                 end
                idx += 1
                push!(ftps_bit[bits][n], t)
            end
        end
        save_object("bits_time_zk.jld2", ftps_bit)
    end

    for eps in epsilon
        ftps_eps[eps] = Dict()
        for n in n_values
            println("eps ", n)
            filename = "../data/ZKC/ZKC"*string(n)*"_sol.dat"
            solutions = readSolution(filename)

            idx = 1
            cnt = 0
            filename = "../data/NK/NK"*string(n)*"_inst.dat"
            instances = readFile(filename)
            ftps_eps[eps][n] = []
            for instance in instances
                t = @elapsed max_price = price_decompose(instance[1], instance[2], epsilon_error = eps)
#                 push!(ftps_eps[eps][n], abs(max_price - solutions[idx][3]))
#                 if max_price != solutions[idx][3]
#                     cnt += 1
#                 end
                idx += 1
                push!(ftps_eps[eps][n], t)
            end
        end
        save_object("eps_time_zk.jld2", ftps_eps)
    end

end



function bench5()
    n_values = [4, 10, 15, 20, 25, 30, 35, 40]
    bit = [1, 2, 4, 8, 16]
    epsilon = [0.01, 0.05, 0.1, 0.3, 0.5]
    simple = Dict()
    redux = Dict()
    ftps_bit = Dict()
    ftps_eps = Dict()

    for n in n_values
        break
        println(n)
        filename = "../data/NK/NK"*string(n)*"_sol.dat"
        solutions = readSolution(filename)

        idx = 1
        cnt = 0
        max_rel = 0
        filename = "../data/NK/NK"*string(n)*"_inst.dat"
        instances = readFile(filename)
        simple[n] = []
        for instance in instances
            max_price = simple_greedy(instance[1], instance[2])#, epsilon_error = 0.01)
            top = abs(max_price - solutions[idx][3])
            bottom = max(max_price, solutions[idx][3])
            if bottom == 0
                rel = 0
            else
                rel = top / bottom
            end
            max_rel = max(max_rel, rel)
            push!(simple[n], rel)
            if max_price != solutions[idx][3]
                cnt += 1
            end
            idx += 1
        end
        push!(simple[n], sum(simple[n]) / 500 )
        push!(simple[n], max_rel)
        save_object("simple_err.jld2", simple)


        idx = 1
        cnt = 0
        max_rel = 0
        filename = "../data/NK/NK"*string(n)*"_inst.dat"
        instances = readFile(filename)
        redux[n] = []
        for instance in instances
            max_price = redux_greedy(instance[1], instance[2])#, epsilon_error = 0.01)
            top = abs(max_price - solutions[idx][3])
            bottom = max(max_price, solutions[idx][3])
            if bottom == 0
                rel = 0
            else
                rel = top / bottom
            end
            max_rel = max(max_rel, rel)
            push!(redux[n], rel)
            if max_price != solutions[idx][3]
                cnt += 1
            end
            idx += 1
        end
        push!(redux[n], sum(redux[n]) / 500)
        push!(redux[n], max_rel)
        save_object("redux_err.jld2", redux)
    end

    ftps_bit2 = Dict()
    for bits in bit
        ftps_bit[bits] = Dict()
        ftps_bit2[bits] = Dict()
        for n in n_values
            println("bits ", n)
            filename = "../data/NK/NK"*string(n)*"_sol.dat"
            solutions = readSolution(filename)

            idx = 1
            cnt = 0
            max_rel = 0
            filename = "../data/NK/NK"*string(n)*"_inst.dat"
            instances = readFile(filename)
            ftps_bit[bits][n] = []
            ftps_bit2[bits][n] = []
            for instance in instances
                max_price, limit_price = price_decompose(instance[1], instance[2], bits=bits)#, epsilon_error = 0.01)
                top = abs(max_price - solutions[idx][3])
                bottom = max(max_price, solutions[idx][3])
                if bottom == 0
                    rel = 0
                else
                    rel = top / bottom
                end
                expect = 1
                if limit_price > 0
                    expect = (n*(2^bits)/limit_price)
                end
#                 println(bits, "\t", n)
#                 println("\t", rel, "\t", expect, "\t", limit_price)
#                 println(max_price, "\t", solutions[idx][3])
                max_rel = max(max_rel, rel)
                push!(ftps_bit[bits][n], rel)
                push!(ftps_bit2[bits][n], expect)
                if max_price != solutions[idx][3]
                    cnt += 1
                end
                idx += 1
            end
            push!(ftps_bit[bits][n], sum(ftps_bit[bits][n]) / 500)
            push!(ftps_bit[bits][n], max_rel)
        end
        save_object("bits_smh_nk.jld2", ftps_bit)
        save_object("bits_other_nk.jld2", ftps_bit2)
    end
    ftps_eps2 = Dict()
    for eps in epsilon
        ftps_eps[eps] = Dict()
        ftps_eps2[eps] = Dict()
        for n in n_values
            println("eps ", n)
            filename = "../data/NK/NK"*string(n)*"_sol.dat"
            solutions = readSolution(filename)

            idx = 1
            cnt = 0
            max_rel = 0
            filename = "../data/NK/NK"*string(n)*"_inst.dat"
            instances = readFile(filename)
            ftps_eps[eps][n] = []
            ftps_eps2[eps][n] = []
            for instance in instances
                max_price, limit_price = price_decompose(instance[1], instance[2], epsilon_error = eps)
                top = abs(max_price - solutions[idx][3])
                bottom = max(max_price, solutions[idx][3])
                if bottom == 0
                    rel = 0
                else
                    rel = top / bottom
                end
#                 println(eps, "\t", n)
                expect = eps
#                 println(rel, "\t", expect)
                max_rel = max(max_rel, rel)
                push!(ftps_eps[eps][n], rel)
                push!(ftps_eps2[eps][n], expect)
                if max_price != solutions[idx][3]
                    cnt += 1
                end
                idx += 1
            end
            push!(ftps_eps[eps][n], sum(ftps_eps[eps][n]) / 500 )
            push!(ftps_eps[eps][n], max_rel)
        end
#         save_object("eps_err.jld2", ftps_eps)
        save_object("eps_smh_nk.jld2", ftps_eps)
        save_object("eps_other_nk.jld2", ftps_eps2)
    end

end


# bench5()
# bench2()
# bench4()
# bench5()