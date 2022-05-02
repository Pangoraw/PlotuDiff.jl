module PlotuDiff

abstract type StringDiffAlgorithm end

include("./diffs.jl")
include("./viewer.jl")
include("./myers.jl")
include("./objects.jl")

"""
Compute the difference between two input strings and return the result of diffs wrapped
"""
function stringdiff(
    string1::AbstractString,
    string2::AbstractString;
    alg = Myers(),
    viewer = SimpleDiffViewer,
)
    stringdiff(alg, string1, string2) |> viewer
end

stringdiff_without_viewer(args...; kwargs...) =
    stringdiff(args...; kwargs..., viewer = identity)

export stringdiff, merge_diffs, SimpleDiffViewer, LineViewer, SimpleLineDiffViewer

using Tokenize

"""
  codediff(c1::AbstractString, c2::AbstractString)

Computes the token differences between two pieces of Julia code.
"""
function code_diff(c1, c2)
    t1 = tokenize(c1) |> collect
    t2 = tokenize(c2) |> collect
    myers(t1, t2)
end

end
