include("init.jl")

facts("test_example") do
  j = nmr.NMR(1, "Top30_airports_LatLong.csv", nmr.mapper_example, nmr.reducer_example, nmr.combiner_example)
  output = nmr.runjob(j)
  @fact is(typeof(output), Array{Any, 1}) --> true
  @fact length(output) == nprocs() - 1 --> true
end
