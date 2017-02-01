workspace()
using nmr
using FactCheck

facts("initiating test environment") do
  nmr.init()
  @fact nmr.split_raw_data() --> true
  @fact isdir("data") --> true
  @fact isdir("split") --> true
  @fact isdir("output") --> true
end
