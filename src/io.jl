function split_raw_data()
  isdir(splitdir) || mkdir(splitdir)
  for filename in readdir(datadir)
    endswith(filename, ".csv") && split_raw_data(filename)
  end
  return true
end

function split_raw_data(filename)
  global process
  global processes

  input_filename = datadir * "/" * filename # the file we're reading
  output_filenames = Array(String, processes)
  for p = 2:processes
    output_dir = "$(splitdir)/$(p)"
    isdir(output_dir) || mkdir(output_dir)
    output_filenames[p] = "$(output_dir)/$(filename)"
    isfile(output_filenames[p]) && rm(output_filenames[p])
  end

  # open the files for writing (1 file per core)
  handles = [open(f, "w") for f in output_filenames[2:processes]]
  handle = 1

  # open the input filename
  f = open(input_filename)

  # read input file line by line
  for ln in eachline(f)
    current_handle = handles[handle]
    write(current_handle, ln) # write line into current handle
    handle += 1 # get next handle
    if handle > length(handles)
      handle = 1 # cycle back to first handle once handles have been exhausted
    end
  end
  close(f) # close the input filename
  map(close, handles) # close all output handles
  return true
end

job_output_dir(j) = "$(outputdir)/$(j.jobid)"

function create_job_area(j)
  joboutputdir = job_output_dir(j)
  isdir(joboutputdir) && rm(joboutputdir, force=true, recursive=true)
  mkdir(joboutputdir)
end

function read_sink(j, phase)
  inputfile = "$(job_output_dir(j))/$(myid()).$(phase)"
  open(inputfile)
end

function read_sink_lines(j, phase)
  fh = read_sink(j, phase)
  lines = readlines(fh)
  close(fh)
  return lines
end

function write_sink(j, phase)
  outputfile = "$(job_output_dir(j))/$(myid()).$(phase)"
  isfile(outputfile) && rm(outputfile)
  open(outputfile, "w")
end

function last_output_phase_before_combiner(j)
  output_dir = job_output_dir(j)
  for phase in ["reduce", "map"]
    phase_filenames = ["$(output_dir)/$(i).$(phase)" for i in 2:processes]
    all(map(isfile, phase_filenames)) && return phase
  end
  error("Could not find neither reduce nor map outputs for the current job")
end
