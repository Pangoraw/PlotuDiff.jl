# a naive implementation of a terminal color code printer with a Pluto/HTML integration
# there is probably a nice Julia package for that, TODO: use it or at least refactor this piece of code

const PlainOrHtmlMIME = Union{MIME"text/plain",MIME"text/html"}

# It should be more tied to the type of diff to support background color and so-on
@enum Colors Green Red Reset

####
# Terminal colors
# For the diff printer interface implement with_color(f, io, m, col)
####

const color_codes = Dict{Colors,String}(
	Green => "\e[32m",
	Red => "\e[31m",
	Reset => "\e[39m",
)

function with_color(f::Function, io::IO, ::MIME"text/plain", col::Colors)
	write(io, color_codes[col])
	res = f()
	write(io, color_codes[Reset])
	res
end

####
# Pluto colors
# TODO: escaping of the user inputs using HyperTextLiteral?
####

# Colors are shade 400 of red/green from tailwindcss's default color theme
const hex_color_codes = Dict{Colors,String}(
	Green => "#34D399",
	Red => "#F87171",
	# no reset
)

function with_color(f::Function, io::IO, ::MIME"text/html", col::Colors)
	write(io, "<span style=\"color: $(hex_color_codes[col])\">")
	res = f()
	write(io, "</span>")
	res
end

####

function color(io::IO, m::PlainOrHtmlMIME, col::Colors, text)
	with_color(() -> write(io, text), io, m, col)
end

green(io::IO, m::PlainOrHtmlMIME, text) = color(io, m, Green, text)
red(io::IO, m::PlainOrHtmlMIME, text) = color(io, m, Red, text)

with_green(f::Function, io::IO, m::PlainOrHtmlMIME) = with_color(f, io, m, Green)
with_red(f::Function, io::IO, m::PlainOrHtmlMIME) = with_color(f, io, m, Red)

Base.show(io::IO, diff::T) where {T<:AbstractDiff} = Base.show(io, MIME"text/plain"(), diff)
Base.show(io::IO, m::MIME"text/plain", diff::T) where {T<:AbstractDiff} = disp(io, m, diff)
Base.show(io::IO, m::MIME"text/html", diff::T) where {T<:AbstractDiff} = disp(io, m, diff)

disp(io::IO, m::PlainOrHtmlMIME, ins::Insertion) = green(io, m, ins.text)
disp(io::IO, m::PlainOrHtmlMIME, del::Deletion) = red(io, m, del.text)
disp(io::IO, ::PlainOrHtmlMIME, eq::Equality) = write(io, eq.text)

abstract type AbstractDiffViewer end

# how am i supposed to do these things ?
Base.show(io::IO, adv::T) where {T<:AbstractDiffViewer} = Base.show(io, MIME"text/plain"(), adv)
Base.show(io::IO, m::MIME"text/plain", adv::T) where {T<:AbstractDiffViewer} = disp(io, m, adv)
Base.show(io::IO, m::MIME"text/html", adv::T) where {T<:AbstractDiffViewer} = disp(io, m, adv)

struct SimpleDiffViewer <: AbstractDiffViewer
	diffs::Vector{<:AbstractDiff}
end

function disp(io::IO, m::PlainOrHtmlMIME, dv::SimpleDiffViewer)
	for diff in dv.diffs
		show(io, m, diff)
	end
end

newline(io::IO, ::MIME"text/plain") = write(io, '\n')
newline(io::IO, ::MIME"text/html") = write(io, "<br />")
tabulate(io::IO, ::MIME"text/plain") = write(io, '\t')
tabulate(io::IO, ::MIME"text/html") = write(io, "<span style=\"width: 4rem\"></span>")

"Show both initial inputs on top of each other"
struct SimpleLineDiffViewer <: AbstractDiffViewer
	diffs::Vector{<:AbstractDiff}
end

function disp(io::IO, m::PlainOrHtmlMIME, ldv::SimpleLineDiffViewer)
	with_red(io, m) do
		tabulate(io, m)
		write(io, "- ")

		for diff in ldv.diffs
			diff isa Insertion && continue
			write(io, diff.text)
		end
	end
	newline(io, m)

	with_green(io, m) do
		tabulate(io, m)
		write(io, "+ ")
		for diff in ldv.diffs
			diff isa Deletion && continue
			write(io, diff.text)
		end
	end
end
