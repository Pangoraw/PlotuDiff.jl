using PlotuDiff
using PlotuDiff: Insertion, Deletion, Equality, Myers
using PlotuDiff: stringdiff_without_viewer as sdiff
using Test

@testset "Myers algorithm" begin
	a = "I LIKE PIZZA"
	b = "YOU LIKE MEZZE"

	@testset "Two lines" begin

		diffs = sdiff(a, b; alg=Myers())

		@test diffs == [
			Deletion('I'),
			[Insertion(c) for c in "YOU"]...,
			[Equality(c) for c in " LIKE "]...,
			Deletion('P'),
			Deletion('I'),
			Insertion('M'),
			Insertion('E'),
			Equality('Z'),
			Equality('Z'),
			Deletion('A'),
			Insertion('E'),
		]
	end

	@testset "Merge diffs" begin
		diffs = sdiff(a, b; alg=Myers()) |> PlotuDiff.merge_diffs

		@test diffs == [
			Deletion('I'),
			Insertion("YOU"),
			Equality(" LIKE "),
			Deletion("PI"),
			Insertion("ME"),
			Equality("ZZ"),
			Deletion('A'),
			Insertion('E'),
		]
	end
end
