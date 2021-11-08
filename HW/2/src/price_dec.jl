#=
price_dec:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-10-23
=#


function fptas_preprocess(bag; bits = 0, epsilon_error = 0)
    # approximate prices of items
    # by removing last x bits
    # or by preserving (1-epsilon_error) precision
    n = size(bag)[1]
    items = zeros(Int64, (n, 3))
    P = maximum(maximum(bag, dims=2))
    K = epsilon_error * P / n
    limit_price = 0
    for idx in 1:n
       items[idx, 1]  = bag[idx, 1]
       items[idx, 3]  = bag[idx, 3]

       if bits > 0
           items[idx, 2]  = bag[idx, 2]  >> bits
       end
       if epsilon_error > 0
           items[idx, 2]  = floor(Int64, bag[idx, 2]  /  K)
       end

       limit_price += items[idx, 2]
    end
    return items, limit_price
end


function price_decompose(bag, M; bits = 0, epsilon_error = 0)
    if bits > 0 && epsilon_error > 0
        println("ERROR:")
        println("Choose only one approximation (bit or epsilon error).")
        return 0
    end

    n = size(bag)[1]
    items = zeros(Int64, (n, 3))
    i = 1
    # limit price is the height of table, maximum price of bag is sum of all items
    limit_price = 0
    for item in eachrow(bag)
        items[i, 1] = item[1]
        items[i, 2] = item[2]
        # find maximum possible price
        limit_price += item[2]
        items[i, 3] = item[3]
        i += 1
    end
    if bits > 0 || epsilon_error > 0
        # approximation using FPTAS if present
        items, limit_price = fptas_preprocess(bag, bits = bits, epsilon_error = epsilon_error)
    end
    table = zeros((n + 1, limit_price + 1))
    table[1,:] .= typemax(Int64)
    table[1,1] = 0

    max_price = 0
    for n in 2:(n+1)
        for p in 2:(limit_price+1)
            # weight and price of possibly added item
            wi = items[n-1, 1]
            ci = items[n-1, 2]
            right = typemax(Int64)
            if (p - ci) >= 1
                right = table[n-1, p - ci] + wi
            end
            table[n, p] = min(table[n-1, p], right)
            if table[n, p] <= M  && (p-1) > max_price
                max_price = p - 1
            end
        end
    end
    # calculate real price using table
    real_price = 0
    real_weight = 0
    solution = solution_vector(table, max_price + 1, items)
    for idx in 1:size(bag)[1]
        real_weight += bag[idx, 1] * solution[bag[idx, 3]]
        real_price += bag[idx, 2] * solution[bag[idx, 3]]
    end
    return real_price
end

function solution_vector(table, price, items)
    # calculates decision vector from a decomposition table
    n = size(table)[1]
    solution = zeros(Int8, n - 1)
    weight = table[n, price]
    prev = n
    while weight > 0
        for n_i in reverse(2:prev-1)
            right = table[prev, price]
            left = table[n_i, price]
            if left == right
                prev = n_i
            end
        end
        weight -= items[prev - 1, 1]
        price -= items[prev - 1, 2]
        solution[items[prev - 1, 3]] = 1
    end
    return solution
end