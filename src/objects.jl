"""
    dictdiff(d1::Dict{String,String}, d2::Dict{String,String})

Returns a dict representing the differences between elements of d1 and d2.
"""
function dictdiff(d1::Dict{String,String}, d2::Dict{String,String})
    keys1 = keys(d1)
    keys2 = keys(d2)
    in1 = setdiff(keys1, keys2)
    in2 = setdiff(keys2, keys1)
    inboth = intersect(keys1, keys2)

    Dict(
        (Deletion(key) => d1[key] for key in in1)...,
        (Insertion(key) => d2[key] for key in in2)...,
        (Equality(key) => stringdiff(d1[key], d2[key]) for key in inboth)...,
    )
end
