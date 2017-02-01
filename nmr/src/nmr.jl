module nmr
  datadir = "NMR_DATADIR" in keys(ENV) ? ENV["NMR_DATADIR"] : "data"
  splitdir = "NMR_SPLITDIR" in keys(ENV) ? ENV["NMR_SPLITDIR"] : "split"
  outputdir = "NMR_OUTPUTDIR" in keys(ENV) ? ENV["NMR_OUTPUTDIR"] : "output"

  # required for correct module operation
  include("logging_config.jl")
  include("types.jl")
  include("io.jl")
  include("phases.jl")
  include("parallelism.jl")

  # user defined functions and types
  include("udf/types.jl")
  include("udf/mappers.jl")
  include("udf/reducers.jl")
  include("udf/combiners.jl")

  function init()
    create_processes()
  end

  function runjob(j)
    phase_create_area(j)
    phase_map(j)
    phase_reduce(j)
    output = phase_combine(j)
    return output
  end

end # module
