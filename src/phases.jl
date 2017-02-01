function phase_create_area(j)
  create_job_area(j)
end

function phase_map(j)
  r = [@spawnat p runmapper(j) for p = 2:processes]
  for i = 1:length(r)
    wait(r[i])
  end
end

function runmapper(j)
  debug("worker $(myid()) started")
  inputfile = "$(splitdir)/$(myid())/$(j.input_filename)"
  io_input = open(inputfile)
  io_output = write_sink(j, "map")
  for line in eachline(io_input)
    v = j.mapper(line)
    v == "" && continue
    write(io_output, v)
  end
  close(io_input)
  close(io_output)
  debug("worker $(myid()) finished")
  return true
end

function phase_reduce(j)
  r = [@spawnat p runreducer(j) for p = 2:processes]
  for i = 1:length(r)
    wait(r[i])
  end
end

function runreducer(j)
  debug("reducer $(myid()) reducer")

  io_input = read_sink(j, "map")
  io_output = write_sink(j, "reduce")
  write(io_output, j.reducer(readlines(io_input)))

  close(io_input)
  close(io_output)

  debug("reducer $(myid()) finished")
  return true
end

function phase_combine(j)
  last_output_phase = last_output_phase_before_combiner(j)
  r = [@spawnat p read_sink_lines(j, last_output_phase) for p = 2:processes]
  combined = []
  for i = 1:length(r)
    wait(r[i])
    push!(combined, fetch(r[i]))
  end
  combined_output = j.combiner(combined)
  return combined_output
end
