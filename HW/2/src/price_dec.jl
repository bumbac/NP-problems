#=
price_dec:
- Julia version: 1.5.3
- Author: sutymate
- Date: 2021-10-23
=#

function price_decompose(bag, M)
    # limit price is the height of table, maximum price of bag is sum of all items
    limit_price = 0
    n = size(bag)[1]
    items = zeros(Int64, (n, 3))
    i = 1
    for item in eachrow(bag)
        items[i, 1] = item[1]
        items[i, 2] = item[2]
        # find maximum possible price
        limit_price += item[2]
        items[i, 3] = item[3]
        i += 1
    end
#     println(M, "\t", items)
#     println(example)
    table = zeros((n + 1, limit_price + 1))
    table[1,:] .= typemax(Float64)
    table[1,1] = 0

#     println(size(table))
#     println(n)
    max_index = 0
    max_price = 0
    for n in 2:(n+1)
        for p in 2:(limit_price+1)
            # weight and price of possibly added item
            wi = items[n-1, 1]
            ci = items[n-1, 2]
            right = typemax(Float64)
            if (p - ci) >= 1
                right = table[n-1, p - ci] + wi
            end
            table[n, p] = min(table[n-1, p], right)
            if table[n, p] <= M  && (p-1) > max_price
                max_price = p - 1
                max_index = n - 1
            end
        end
    end
    return max_price
end

