abstract type AbstractDiff end

struct Insertion <: AbstractDiff
	text
end

struct Deletion <: AbstractDiff
	text
end

struct Equality <: AbstractDiff
	text
end

text(d::AbstractDiff) = d.text
to_string(d::T) where {T<:AbstractDiff} = T(string(text(d)))

"Groups diffs of the same type together using `join`."
function merge_diffs(vec::Vector{<:AbstractDiff}; join_with="")
	out = AbstractDiff[]

	current_diff = vec[1]
	i = 1

	while i < length(vec)
		current_diff_type = typeof(current_diff)

		new_diff = vec[i+1]
		if typeof(new_diff) == current_diff_type
			text = join((current_diff.text, new_diff.text), join_with)
			current_diff = current_diff_type(text)
		else
			push!(out, current_diff)
			current_diff = new_diff
		end

		i += 1
	end
	push!(out, current_diff)

	out
end
