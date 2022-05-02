using Dates

"""
    Myers([timeout::Millisecond])

An implementation of the Myers algorithm as proposed in [1] working on the
character level. A optional timeout can be set, at which point the algorithm
will fall back to a series of deletions followed by insertions.

[1]E. Myers (1986). "An O(ND) Difference Algorithm and Its Variations".
   Algorithmica. 1 (2): 251–266. doi:10.1007/BF01840446. S2CID 6996809.
"""
struct Myers <: StringDiffAlgorithm
    timeout::Union{Millisecond,Nothing}

    Myers() = new(nothing)
end

stringdiff(alg::Myers, a::AbstractString, b::AbstractString) = diff(alg, a, b)

function diff(alg::Myers, a, b)
    start = now()
    trace = ses(a, b; should_timeout = () -> now() - start > alg.timeout)
    moves = backtrack(trace, a, b)
    apply_edits(moves, a, b)
end

"""
    myers(a, b)::Vector{AbstractDiff}

Applies Myers'[1] algorithm to the two iterables a and b and return the
set of differences between them.

[1]E. Myers (1986). "An O(ND) Difference Algorithm and Its Variations".
   Algorithmica. 1 (2): 251–266. doi:10.1007/BF01840446. S2CID 6996809.
"""
function myers(a, b)
    diff(Myers(), a, b)
end

function ses(a, b; should_timeout = () -> false)
    N = length(a)
    M = length(b)
    max = length(a) + length(b)

    trace = Vector{Int}[]
    v = zeros(Int, 2 * max + 2)

    for d = 0:max
        push!(trace, copy(v))
        for k = (-d):2:d
            x = if k == -d || (k != d && v[k + max] < v[k + 2 + max])
                v[k + 2 + max]
            else
                v[k + max] + 1
            end
            y = x - k

            while x < N && y < M && a[x + 1] == b[y + 1]
                x += 1
                y += 1
            end

            v[k + max + 1] = x

            if x >= N && y >= M
                return trace
            end
        end
    end
    throw("length of a ses is greater than max")
end

function backtrack(trace, a, b)
    x, y = length(a), length(b)
    max = length(a) + length(b)

    moves = []
    for (d, v) in reverse(enumerate(trace) |> collect)
        d = d - 1
        k = x - y

        prev_k = if k == -d || (k != d && v[k + max] < v[k + 2 + max])
            k + 1
        else
            k - 1
        end
        prev_x = v[prev_k + 1 + max]
        prev_y = prev_x - prev_k

        while x > prev_x && y > prev_y
            push!(moves, (x - 1, y - 1, x, y))
            x, y = x - 1, y - 1
        end

        d > 0 && push!(moves, (prev_x, prev_y, x, y))

        x, y = prev_x, prev_y
    end

    moves
end

function apply_edits(moves, a, b)
    diffs = AbstractDiff[]
    for (prev_x, prev_y, x, y) in reverse(moves)
        a_line = get(a, prev_x + 1, a[1])
        b_line = get(b, prev_y + 1, a[1])

        if x == prev_x
            push!(diffs, Insertion(b_line))
        elseif y == prev_y
            push!(diffs, Deletion(a_line))
        else
            push!(diffs, Equality(b_line))
        end
    end

    diffs
end

export myers
