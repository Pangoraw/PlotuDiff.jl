module PlotuDiff

abstract type StringDiffAlgorithm end

include("./diffs.jl")
include("./viewer.jl")
include("./myers.jl")

"""
Compute the difference between two input strings and return the result of diffs wrapped
"""
function stringdiff(string1::AbstractString, string2::AbstractString; alg=Myers(), viewer=SimpleDiffViewer)
	stringdiff(alg, string1, string2) |> viewer
end

stringdiff_without_viewer(args...; kwargs...) = stringdiff(args...; kwargs..., viewer=identity)

export stringdiff, merge_diffs, SimpleDiffViewer, LineDiffViewer

end
