using Test
using PlotuDiff: stringdiff

function validate_snapshot(snapshot_path, output)
    should_create = haskey(ENV, "CREATE_SNAPSHOT")
    if should_create
        write(snapshot_path, output)
        return true
    end

    if !isfile(snapshot_path)
        throw(
            "Path $snapshot_path does not exists, run with CREATE_SNAPSHOT=true to create it.",
        )
    end

    content = read(snapshot_path, String)
    if content != output
        diff = if '\n' ∈ content || '\n' ∈ output
            stringdiff(content, output; viewer=PlotuDiff.SimpleLineDiffViewer)
        else
            stringdiff(content, output)
        end
        println(diff)
        return false
    end

    return true
end

"""
Validates that the output of the expression is consistent with the content
of the snapshot file.
"""
macro snapshot(snapshot_name, expr)
    quote
        local res = $(esc(expr)) |> repr
        @test validate_snapshot($(esc(snapshot_name)), res)
    end
end
