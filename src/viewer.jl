@enum Colors Green Red Reset

const color_codes = Dict{Colors,String}(
	Green => "\e[32m",
	Red => "\e[31m",
	Reset => "\e[39m",
)

color(io::IO, col, text) = write(io, color_codes[col], text, color_codes[Reset])
green(io::IO, text) = color(io, Green, text)
red(io::IO, text) = color(io, Red, text)

function with_color(f::Function, io::IO, col::Colors)
	write(io, color_codes[col])
	f()
	write(io, color_codes[Reset])
end
with_green(f::Function, io::IO) = with_color(f, io, Green)
with_red(f::Function, io::IO) = with_color(f, io, Red)

Base.show(io::IO, ins::Insertion) = green(io, ins.text)
Base.show(io::IO, del::Deletion) = red(io, del.text)
Base.show(io::IO, eq::Equality) = write(io, eq.text)

abstract type AbstractDiffViewer end

struct SimpleDiffViewer <: AbstractDiffViewer
	diffs::Vector{<:AbstractDiff}
end

function Base.show(io::IO, dv::SimpleDiffViewer)
	for diff in dv.diffs
		show(io, diff)
	end
end

"Show both initial inputs on top of each other"
struct LineDiffViewer <: AbstractDiffViewer
	diffs::Vector{<:AbstractDiff}
end

function Base.show(io::IO, ldv::LineDiffViewer)
	with_red(io) do
		write(io, "\t- ")

		for diff in ldv.diffs
			diff isa Insertion && continue
			write(io, diff.text)
		end
	end
	write(io, '\n')

	with_green(io,) do
		write(io, "\t+ ")
		for diff in ldv.diffs
			diff isa Deletion && continue
			write(io, diff.text)
		end
	end
	write(io, '\n');
end
