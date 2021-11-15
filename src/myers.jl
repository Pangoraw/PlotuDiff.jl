# https://blog.jcoglan.com/2017/02/17/the-myers-diff-algorithm-part-3/

# myers("ABCABBA", "CBABAC")
# ^
# this calls fails, see the blog post above
function myers(a, b)
	trace = ses(a, b)
	moves = backtrack(trace, a, b)
	apply_edits(moves, a, b)
end

function ses(a, b)
	N = length(a)
	M = length(b)
	max = length(a) + length(b)

	trace = Vector{Int}[]
	v = zeros(Int, 2*max+2)
	v[max] = 0

	for d in 0:max
		push!(trace, copy(v))
		for k in -d:2:d
			x = if (k == -d || k != d) && (v[k+max] < v[k+2+max])
				v[k+2+max]
			else
				v[k+max]+1
			end
			y = x - k

			while x < N && y < M && a[x+1] == b[y+1]
				x += 1
				y += 1
			end

			v[k+max+1] = x

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
	for (d,v) in reverse(enumerate(trace) |> collect)
		d = d-1
		k = x - y

		prev_k = if k == -d || (k != d && v[k+max] < v[k+2+max])
			k + 1
		else
			k - 1
		end
		prev_x = v[prev_k+1+max]
		prev_y = prev_x - prev_k

		while x > prev_x && y > prev_y
			push!(moves, (x-1, y-1, x, y))
			x, y = x - 1, y - 1
		end

		d > 0 && push!(moves, (prev_x, prev_y, x, y))

		x, y = prev_x, prev_y
	end

	moves
end

abstract type AbstractDiff end

struct Insertion <: AbstractDiff
	text
end
Base.show(io::IO, ins::Insertion) = write(io, "\e[32m", ins.text, "\e[32m\e[39m")

struct Deletion <: AbstractDiff
	text
end
Base.show(io::IO, del::Deletion) = write(io, "\e[31m", del.text, "\e[31m\e[39m")

struct Equality <: AbstractDiff
	text
end
Base.show(io::IO, eq::Equality) = write(io, eq.text)

function apply_edits(moves, a, b)
	diffs = []
	for (prev_x, prev_y, x, y) in moves
		a_line, b_line = a[prev_x+1], b[prev_y+1]

		if x == prev_x
			push!(diffs, Insertion(a_line))
		elseif y == prev_y
			push!(diffs, Deletion(b_line))
		else
			push!(diffs, Equality(b_line))
		end
	end

	diffs
end

export myers
